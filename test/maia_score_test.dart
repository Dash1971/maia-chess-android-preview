import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:chessground/chessground.dart' as cg;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:maia_chess/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

MaiaInferenceResult result(double loss, double draw, double win) =>
    MaiaInferenceResult(
      Float32List(4352),
      outcome: MaiaOutcome.fromLogits([log(loss), log(draw), log(win)]),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Loss/Draw/Win normalization, half draws and side-to-move perspective',
    () {
      final outcome = MaiaOutcome.fromLogits([log(.2), log(.4), log(.4)])!;
      expect(outcome.loss, closeTo(.2, 1e-12));
      expect(outcome.draw, closeTo(.4, 1e-12));
      expect(outcome.win, closeTo(.4, 1e-12));
      expect(
        outcome.whiteScore('8/8/8/8/8/8/8/8 w - - 0 1'),
        closeTo(.6, 1e-12),
      );
      expect(
        outcome.whiteScore('8/8/8/8/8/8/8/8 b - - 0 1'),
        closeTo(.4, 1e-12),
      );
      expect(
        MaiaOutcome.fromLogits([-1000, 1000, -1000])!
            .whiteScore('8/8/8/8/8/8/8/8 w - - 0 1'),
        .5,
      );
      final shifted = MaiaOutcome.fromLogits([
        1000 + log(.2),
        1000 + log(.4),
        1000 + log(.4),
      ])!;
      expect(shifted.win, closeTo(.4, 1e-12));
      for (final logits in [
        <double>[],
        [1.0, 2.0],
        [1.0, 2.0, 3.0, 4.0],
        [double.nan, 0.0, 0.0],
        [double.infinity, 0.0, 0.0],
      ])
        expect(MaiaOutcome.fromLogits(logits), isNull);
    },
  );
  test(
    'mixed protocol keeps move-only compatibility without inventing an outcome',
    () {
      final moves = Float32List(4352);
      expect(MaiaInferenceResult.decode(moves)!.outcome, isNull);
      expect(
        MaiaInferenceResult.decode({
          'move_logits': moves,
          'value_logits': Float32List.fromList([0, 1, 2]),
        })!.outcome,
        isNotNull,
      );
      expect(
        MaiaInferenceResult.decode({
          'move_logits': moves,
          'value_logits': Float32List(4),
        })!.outcome,
        isNull,
      );
      expect(
        MaiaInferenceResult.decode({'move_logits': Float32List(3)}),
        isNull,
      );
    },
  );
  test(
    'visible preference defaults off, validates types and survives reload',
    () async {
      for (final value in [null, 7, 'true', false]) {
        SharedPreferences.setMockInitialValues({
          if (value != null) maiaScorePreferenceKey: value,
        });
        final controller = MaiaScoreController();
        await controller.initialize();
        expect(controller.enabled, isFalse);
        controller.dispose();
      }
      final controller = MaiaScoreController();
      await controller.select(true);
      controller.dispose();
      final restarted = MaiaScoreController();
      await restarted.initialize();
      expect(restarted.enabled, isTrue);
      await restarted.select(false);
      expect(
        (await SharedPreferences.getInstance()).getBool(maiaScorePreferenceKey),
        isFalse,
      );
      restarted.dispose();
    },
  );
  test('analysis requests outcome and move logits on the same serialized native call', () async {
    MaiaInferenceQueue.resetForTesting();
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(maiaEngineChannel, (call) async {
          calls.add(call);
          return call.arguments['includeValue'] == true
              ? {
                  'move_logits': Float32List(4352),
                  'value_logits': Float32List.fromList([0, 0, 0]),
                }
              : Float32List(4352);
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(maiaEngineChannel, null),
    );
    final output = await MaiaInferenceQueue.analyze({
      'tokens': Float32List(6208),
      'selfElo': 1500,
      'opponentElo': 1500,
    });
    expect(output!.outcome!.draw, closeTo(1 / 3, 1e-8));
    expect(calls.single.method, 'predict');
    expect(calls.single.arguments['includeValue'], true);
    expect(
      await MaiaInferenceQueue.predict({
        'tokens': Float32List(6208),
        'selfElo': 1500,
        'opponentElo': 1500,
      }),
      hasLength(4352),
    );
  });

  final session = AnalysisSession.fromPgn('1. e4 e5 2. Nf3 Nc6 *');
  Widget app(
    MaiaScoreController controller, {
    int elo = 1500,
    int? second = 2600,
    Locale locale = const Locale('en'),
    double scale = 1,
    Future<MaiaInferenceResult?> Function(List<String>, int)? infer,
  }) => MaiaScoreScope(
    controller: controller,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: ReviewPage(
        positions: session.positions,
        uciMoves: session.uciMoves,
        sanMoves: session.sanMoves,
        pgn: session.pgn,
        playerIsWhite: true,
        onHome: () {},
        maiaElo: elo,
        secondMaiaElo: second,
        evaluator: (_) async => const StockfishReview(0, 'e2e4'),
        maiaInferenceEvaluator:
            infer ??
            (_, rating) async =>
                rating == 1500 ? result(.2, .4, .4) : result(.6, .2, .2),
      ),
    ),
  );
  testWidgets(
    'each engine has its own rating-conditioned score and board size is unchanged',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = MaiaScoreController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(app(controller));
      await tester.pumpAndSettle();
      final before = tester
          .widget<cg.Chessboard>(find.byType(cg.Chessboard))
          .size;
      expect(find.byKey(const ValueKey('maia-score-primary')), findsNothing);
      await controller.select(true);
      await tester.pumpAndSettle();
      expect(find.text('M1500 White 60%'), findsOneWidget);
      expect(find.text('M2600 Black 70%'), findsOneWidget);
      expect(
        tester.widget<cg.Chessboard>(find.byType(cg.Chessboard)).size,
        before,
      );
      expect(find.byType(EvaluationBar), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('analysis-flip-button')));
      await tester.pumpAndSettle();
      expect(find.text('M1500 White 60%'), findsOneWidget);
      expect(find.text('M2600 Black 70%'), findsOneWidget);
    },
  );
  testWidgets('late results cannot replace the selected rating and position', (
    tester,
  ) async {
    final controller = MaiaScoreController();
    addTearDown(controller.dispose);
    await controller.select(true);
    final old = Completer<MaiaInferenceResult?>(),
        current = Completer<MaiaInferenceResult?>();
    Future<MaiaInferenceResult?> infer(List<String> _, int elo) =>
        elo == 1500 ? old.future : current.future;
    await tester.pumpWidget(app(controller, second: null, infer: infer));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      app(controller, elo: 1800, second: null, infer: infer),
    );
    await tester.pumpAndSettle();
    old.complete(result(.05, .1, .85));
    await tester.pumpAndSettle();
    expect(find.textContaining('90%'), findsNothing);
    current.complete(result(.2, .2, .6));
    await tester.pumpAndSettle();
    expect(find.text('M1800 White 70%'), findsOneWidget);
    expect(find.textContaining('M1500 White'), findsNothing);
  });
  testWidgets(
    'selected-position change converts Black perspective and clears stale values',
    (tester) async {
      final controller = MaiaScoreController();
      addTearDown(controller.dispose);
      await controller.select(true);
      final after = Completer<MaiaInferenceResult?>();
      await tester.pumpWidget(
        app(
          controller,
          second: null,
          infer: (history, _) async =>
              history.length == 1 ? result(.2, .4, .4) : after.future,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('M1500 White 60%'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('next-move-button')));
      await tester.pumpAndSettle();
      expect(find.text('M1500 White 60%'), findsNothing);
      after.complete(result(.2, .4, .4));
      await tester.pumpAndSettle();
      expect(find.text('M1500 Black 60%'), findsOneWidget);
    },
  );
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      '${locale.languageCode} two scores and settings fit at 200% narrow/landscape',
      (tester) async {
        final controller = MaiaScoreController();
        addTearDown(controller.dispose);
        await controller.select(true);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final size in [const Size(320, 640), const Size(640, 320)]) {
          tester.view.physicalSize = size;
          await tester.pumpWidget(app(controller, locale: locale, scale: 2));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(
            MaiaScoreScope(
              controller: controller,
              child: MaterialApp(
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
                home: const Scaffold(
                  body: SingleChildScrollView(child: MaiaScoreSetting()),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}
