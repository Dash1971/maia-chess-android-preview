import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:chessground/chessground.dart' as cg;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:maia_chess/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/variation_navigation_game.dart';

const _pane = PageStorageKey('analysis-details-moves');

void main() {
  final font = Platform.environment['MAIA_REPORT_FONT'];
  setUpAll(() async {
    await OpeningNames.load();
    if (font != null) {
      await (FontLoader(
        'Roboto',
      )..addFont(File(font).readAsBytes().then(ByteData.sublistView))).load();
      for (final entry in {
        'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
        'LichessIcons': 'assets/fonts/LichessIcons.ttf',
        'packages/cupertino_icons/CupertinoIcons':
            'packages/cupertino_icons/assets/CupertinoIcons.ttf',
      }.entries) {
        await (FontLoader(
          entry.key,
        )..addFont(rootBundle.load(entry.value))).load();
      }
    }
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(maiaEngineChannel, (_) async => null);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(maiaEngineChannel, null);
  });

  final session = AnalysisSession.fromPgn(variationNavigationPgn);
  Future<void> mount(
    WidgetTester tester,
    Size size, {
    double scale = 1,
    AnalysisSession? replay,
    int initialPly = 2,
    bool editable = false,
    VoidCallback? onEvaluate,
    EdgeInsets padding = const EdgeInsets.only(top: 24, bottom: 16),
  }) async {
    final game = replay ?? session;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final scores = MaiaScoreController();
    addTearDown(scores.dispose);
    await scores.select(true);
    await tester.pumpWidget(
      MaiaScoreScope(
        controller: scores,
        child: RepaintBoundary(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: appTheme(
              const AppAppearance(pureBlack: true),
              Brightness.dark,
            ),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                padding: padding,
                viewPadding: padding,
              ),
              child: child!,
            ),
            home: ReviewPage(
              title: 'Analysis Board',
              positions: game.positions,
              uciMoves: game.uciMoves,
              sanMoves: game.sanMoves,
              pgn: game.pgn,
              initialCurrentFen: game.positions[initialPly],
              onSessionChanged: editable ? (_, _, _) async {} : null,
              playerIsWhite: true,
              maiaElo: 1600,
              secondMaiaElo: 2600,
              onHome: () {},
              classifier: ({
                required scores,
                required positions,
                required uciMoves,
              }) async => const <ClassifiedMove>[],
              // Display fixtures only; these tests do not run native engines/models.
              evaluator: (_) async {
                onEvaluate?.call();
                return const StockfishReview(
                  30,
                  'g1f3',
                  lines: [
                    StockfishLine(
                      evaluation: 30,
                      moves: ['g1f3', 'b8c6', 'f1b5', 'g8f6'],
                    ),
                    StockfishLine(
                      evaluation: 10,
                      moves: ['b1c3', 'g8f6', 'f1c4', 'b8c6'],
                    ),
                  ],
                );
              },
              maiaInferenceEvaluator: (_, elo) async {
                onEvaluate?.call();
                final policy = List<double>.filled(4352, -20);
                policy[MaiaEncoding.moveIndex('g1f3', false)] = elo == 2600
                    ? 3
                    : 4;
                policy[MaiaEncoding.moveIndex('f1c4', false)] = 2;
                policy[MaiaEncoding.moveIndex('b1c3', false)] = 1;
                return MaiaInferenceResult(
                  Float32List.fromList(policy),
                  outcome: MaiaOutcome.fromLogits([
                    0,
                    0,
                    elo == 1600 ? .25 : .12,
                  ]),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder scrollView() => find.byKey(_pane, skipOffstage: false);
  NestedScrollViewState nested(WidgetTester tester) =>
      tester.state<NestedScrollViewState>(find.byType(NestedScrollView));
  ScrollController controller(WidgetTester tester) =>
      nested(tester).innerController;
  ScrollController outer(WidgetTester tester) => nested(tester).outerController;
  double totalOffset(WidgetTester tester) =>
      controller(tester).offset + outer(tester).offset;

  Future<void> capture(WidgetTester tester, String name) async {
    final output = Platform.environment['MAIA_ANALYSIS_CAPTURES'];
    if (output == null) return;
    // SVG piece decoding completes outside the test clock on the first frame.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Directory(output).create(recursive: true);
      final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
        find.byType(RepaintBoundary),
      );
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('$output/$name.png').writeAsBytes(data!.buffer.asUint8List());
      image.dispose();
    });
  }

  ScrollController moveController(WidgetTester tester) =>
      find.byType(NestedScrollView).evaluate().isNotEmpty
      ? nested(tester).innerController
      : tester
            .widget<SingleChildScrollView>(
              find.descendant(
                of: find.byKey(const ValueKey('analysis-move-list')),
                matching: find.byType(SingleChildScrollView),
              ),
            )
            .controller!;

  Rect visibleMoveWindow(WidgetTester tester) {
    if (find.byType(NestedScrollView).evaluate().isNotEmpty) {
      final pane = tester.getRect(find.byType(NestedScrollView));
      return Rect.fromLTRB(pane.left, pane.top + 48, pane.right, pane.bottom);
    }
    return tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('analysis-move-list')),
        matching: find.byType(SingleChildScrollView),
      ),
    );
  }

  void expectEndpoint(WidgetTester tester, {required bool end}) {
    final expectedFen = end ? session.positions.last : session.positions.first;
    final board = tester
        .widget<cg.Chessboard>(find.byType(cg.Chessboard))
        .controller;
    // Ignore only canonical en-passant serialization differences.
    expect(board.fen.split(' ').take(2), expectedFen.split(' ').take(2));
    final selected = find.byKey(const ValueKey('analysis-selected-move'));
    expect(selected, end ? findsOneWidget : findsNothing);
    if (end) {
      expect(
        find.descendant(
          of: selected,
          matching: find.text(session.sanMoves.last),
        ),
        findsOneWidget,
      );
    }
    final row = tester.getRect(
      find.byKey(
        ValueKey('mainline-move-${end ? session.sanMoves.length - 1 : 0}'),
      ),
    );
    final window = visibleMoveWindow(tester);
    expect(
      row.top,
      greaterThanOrEqualTo(window.top - 1),
      reason: 'Row $row in window $window',
    );
    expect(
      row.bottom,
      lessThanOrEqualTo(window.bottom + 1),
      reason: 'Row $row in window $window',
    );
  }

  for (final (name, size) in [
    ('portrait phone', const Size(393, 873)),
    ('landscape phone', const Size(873, 393)),
    ('portrait tablet', const Size(800, 1280)),
    ('landscape tablet', const Size(1280, 800)),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        '$name at $scale long-press endpoints reveal and re-reveal the list without rotation',
        (tester) async {
          var evaluations = 0;
          await mount(
            tester,
            size,
            scale: scale,
            onEvaluate: () => evaluations++,
          );
          final next = find.byKey(const ValueKey('next-move-button'));
          final previous = find.byKey(const ValueKey('previous-move-button'));
          await tester.longPress(next);
          await tester.pumpAndSettle();
          expectEndpoint(tester, end: true);
          final endBoard = tester.element(find.byType(cg.Chessboard));
          final endEvaluations = evaluations;
          // Browse away without selecting a different move.
          moveController(tester).jumpTo(0);
          if (find.byType(NestedScrollView).evaluate().isNotEmpty) {
            outer(tester).jumpTo(0);
          }
          await tester.pumpAndSettle();
          expect(tester.widget<InkWell>(next).onTap, isNull);
          await tester.longPress(next);
          await tester.pumpAndSettle();
          expectEndpoint(tester, end: true);
          expect(tester.element(find.byType(cg.Chessboard)), same(endBoard));
          expect(
            evaluations,
            endEvaluations,
            reason: 'Repeated hold must not restart engines',
          );
          await tester.longPress(previous);
          await tester.pumpAndSettle();
          expectEndpoint(tester, end: false);
          final startBoard = tester.element(find.byType(cg.Chessboard));
          final startEvaluations = evaluations;
          moveController(tester)
              .jumpTo(moveController(tester).position.maxScrollExtent);
          await tester.pumpAndSettle();
          expect(tester.widget<InkWell>(previous).onTap, isNull);
          await tester.longPress(previous);
          await tester.pumpAndSettle();
          expectEndpoint(tester, end: false);
          expect(tester.element(find.byType(cg.Chessboard)), same(startBoard));
          expect(evaluations, startEvaluations);
          // A late score/header rebuild must not undo the explicit reveal.
          final scores = MaiaScoreScope.maybeOf(
            tester.element(find.byType(ReviewPage)),
          )!;
          await scores.select(false);
          await tester.pumpAndSettle();
          expectEndpoint(tester, end: false);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final (name, size) in [
    ('portrait', const Size(393, 873)),
    ('landscape', const Size(873, 393)),
  ]) {
    testWidgets(
      '$name saved game opened at end and graph-tab holds reveal endpoints',
      (tester) async {
        await mount(
          tester,
          size,
          initialPly: session.sanMoves.length,
          editable: true,
        );
        final next = find.byKey(const ValueKey('next-move-button'));
        final previous = find.byKey(const ValueKey('previous-move-button'));
        await tester.longPress(next);
        await tester.pumpAndSettle();
        expectEndpoint(tester, end: true);
        await tester.ensureVisible(find.byKey(const ValueKey('graph-tab')));
        await tester.tap(find.byKey(const ValueKey('graph-tab')));
        await tester.pumpAndSettle();
        await tester.longPress(previous);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const ValueKey('moves-tab')));
        await tester.tap(find.byKey(const ValueKey('moves-tab')));
        await tester.pumpAndSettle();
        expectEndpoint(tester, end: false);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('an empty analysis position keeps endpoint controls disabled', (
    tester,
  ) async {
    await mount(
      tester,
      const Size(393, 873),
      initialPly: 0,
      replay: AnalysisSession.fromFen(session.positions.first),
    );
    for (final key in ['previous-move-button', 'next-move-button']) {
      final control = tester.widget<InkWell>(find.byKey(ValueKey(key)));
      expect(control.onTap, isNull);
      expect(control.onLongPress, isNull);
    }
    expect(tester.takeException(), isNull);
  });

  for (final (name, size) in [
    ('phone', const Size(873, 393)),
    ('small-tablet', const Size(1024, 600)),
    ('tablet', const Size(1280, 800)),
    ('tablet-4x3', const Size(1024, 768)),
    ('split-window', const Size(800, 600)),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        '$name at $scale coordinates moves and header without trapping reverse drags',
        (tester) async {
          await mount(tester, size, scale: scale);
          final scroll = scrollView();
          expect(scroll, findsOneWidget);
          expect(
            find.descendant(
              of: find.byKey(const ValueKey('analysis-move-list')),
              matching: find.byType(Scrollable),
            ),
            findsNothing,
          );
          final scroller = controller(tester);
          expect(
            scroller.offset,
            closeTo(0, 0.1),
            reason: 'Open at the engine output',
          );
          final board = tester.getRect(find.byType(cg.Chessboard));
          final boardController = tester
              .widget<cg.Chessboard>(find.byType(cg.Chessboard))
              .controller;
          final initialFen = boardController.fen;
          expect(board.width, closeTo(board.height, 0.1));
          expect(board.width, greaterThan(size.height > 600 ? 550 : 300));
          final controls = tester.getRect(
            find.byKey(const ValueKey('analysis-controls')),
          );
          expect(controls.bottom, lessThanOrEqualTo(size.height - 16));
          expect(
            find.byKey(const ValueKey('analysis-controls')).hitTestable(),
            findsOneWidget,
          );
          if (scale == 1) await capture(tester, '$name-initial');

          final pane = tester.getRect(find.byType(NestedScrollView));
          await tester.dragFrom(pane.center, Offset(0, -pane.height * 0.8));
          await tester.pumpAndSettle();
          expect(totalOffset(tester), greaterThan(0));
          if (name == 'phone' && scale == 1) {
            await tester.dragFrom(pane.center, const Offset(0, -80));
            await tester.pumpAndSettle();
            await capture(tester, 'phone-moves');
          }
          expect(boardController.fen, initialFen);
          expect(tester.getRect(find.byType(cg.Chessboard)), board);
          expect(
            tester.getRect(find.byKey(const ValueKey('analysis-controls'))),
            controls,
          );
          // The drag starts in the move rows, not in a separate header strip.
          for (var i = 0; i < 10 && totalOffset(tester) > 0.1; i++) {
            await tester.dragFrom(pane.center, Offset(0, pane.height * 0.8));
            await tester.pumpAndSettle();
          }
          expect(totalOffset(tester), closeTo(0, 0.1));
          expect(
            find.byKey(const ValueKey('review-opening-name')).hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('a reverse drag inside deep moves reveals the header first', (
    tester,
  ) async {
    await mount(tester, const Size(873, 393));
    final pane = tester.getRect(find.byType(NestedScrollView));
    await tester.dragFrom(pane.center, const Offset(0, -650));
    await tester.pumpAndSettle();
    expect(controller(tester).offset, greaterThan(200));
    final before = controller(tester).offset;
    expect(outer(tester).offset, outer(tester).position.maxScrollExtent);
    // Start in the moves, and hold the pointer to check the drag itself,
    // independently of any ballistic fling that follows release.
    final gesture = await tester.startGesture(
      Offset(pane.center.dx, pane.bottom - 20),
    );
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 110));
    await tester.pump();
    expect(
      outer(tester).offset,
      lessThan(outer(tester).position.maxScrollExtent - 50),
    );
    expect(controller(tester).offset, closeTo(before, .1));
    await gesture.up();
    await tester.pumpAndSettle();
    await capture(tester, 'phone-return-to-engines');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'short games can expand moves and return from the inner boundary',
    (tester) async {
      await mount(
        tester,
        const Size(873, 393),
        replay: AnalysisSession.fromPgn('1. e4 e5 *'),
      );
      final pane = tester.getRect(find.byType(NestedScrollView));
      await tester.dragFrom(pane.center, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(outer(tester).offset, greaterThan(0));
      expect(controller(tester).offset, closeTo(0, .1));
      await tester.dragFrom(
        Offset(pane.center.dx, pane.bottom - 20),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();
      expect(totalOffset(tester), closeTo(0, .1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('stepping one move reveals a row below the expanded header', (
    tester,
  ) async {
    await mount(tester, const Size(873, 393));
    await tester.tap(find.byTooltip('Next move'));
    await tester.pumpAndSettle();
    final selected = tester.getRect(
      find.byKey(const ValueKey('analysis-selected-move')),
    );
    final pane = tester.getRect(find.byType(NestedScrollView));
    expect(selected.top, greaterThanOrEqualTo(pane.top + 48 - 1));
    expect(selected.bottom, lessThanOrEqualTo(pane.bottom + 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'previous moves stay below pinned tabs after returning to engines',
    (tester) async {
      await mount(tester, const Size(873, 393));
      await tester.longPress(find.byTooltip('Next move'));
      await tester.pumpAndSettle();
      final pane = tester.getRect(find.byType(NestedScrollView));
      await tester.dragFrom(
        Offset(pane.center.dx, pane.bottom - 20),
        const Offset(0, 130),
      );
      await tester.pumpAndSettle();
      for (var i = 0; i < 14; i++) {
        await tester.tap(find.byTooltip('Previous move'));
        await tester.pumpAndSettle();
        final selected = tester.getRect(
          find.byKey(const ValueKey('analysis-selected-move')),
        );
        final tabs = tester.getRect(find.byKey(const ValueKey('moves-tab')));
        expect(
          selected.top,
          greaterThanOrEqualTo(tabs.bottom - 1),
          reason: 'Previous step $i',
        );
        expect(
          selected.bottom,
          lessThanOrEqualTo(pane.bottom + 1),
          reason: 'Previous step $i',
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'manual scroll stays put; stepping reveals selection and rotation keeps the board',
    (tester) async {
      await mount(tester, const Size(873, 393));
      final board = tester
          .widget<cg.Chessboard>(find.byType(cg.Chessboard))
          .controller;
      final scroller = controller(tester);
      await tester.longPress(find.byTooltip('Next move'));
      await tester.pumpAndSettle();
      expect(totalOffset(tester), greaterThan(0));
      final viewport = tester.getRect(scrollView());
      final selected = tester.getRect(
        find.byKey(const ValueKey('analysis-selected-move')),
      );
      expect(selected.top, greaterThanOrEqualTo(viewport.top - 1));
      expect(selected.bottom, lessThanOrEqualTo(viewport.bottom + 1));
      outer(tester).jumpTo(0);
      await tester.pumpAndSettle();
      final scores = MaiaScoreScope.maybeOf(
        tester.element(find.byType(ReviewPage)),
      )!;
      await scores.select(false);
      await tester.pumpAndSettle();
      await scores.select(true);
      await tester.pumpAndSettle();
      expect(
        scroller.offset,
        0,
        reason:
            'A score-setting rebuild must not reveal the selected move again',
      );
      final fen = board.fen;
      tester.view.physicalSize = const Size(800, 1280);
      await tester.pumpAndSettle();
      expect(
        tester.widget<cg.Chessboard>(find.byType(cg.Chessboard)).controller,
        same(board),
      );
      expect(board.fen, fen);
      final portraitViewport = tester.getRect(
        find.descendant(
          of: find.byKey(const ValueKey('analysis-move-list')),
          matching: find.byType(SingleChildScrollView),
        ),
      );
      final portraitSelected = tester.getRect(
        find.byKey(const ValueKey('analysis-selected-move')),
      );
      expect(
        portraitSelected.top,
        greaterThanOrEqualTo(portraitViewport.top - 1),
      );
      expect(
        portraitSelected.bottom,
        lessThanOrEqualTo(portraitViewport.bottom + 1),
      );
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpAndSettle();
      expect(
        tester.widget<cg.Chessboard>(find.byType(cg.Chessboard)).controller,
        same(board),
      );
      expect(board.fen, fen);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tabs restore the independent move position with a coordinated header',
    (tester) async {
      await mount(tester, const Size(873, 393));
      final paneRect = tester.getRect(find.byType(NestedScrollView));
      await tester.dragFrom(paneRect.center, const Offset(0, -450));
      await tester.pumpAndSettle();
      final before = controller(tester).offset;
      expect(before, greaterThan(0));
      await tester.tap(find.byKey(const ValueKey('graph-tab')));
      await tester.pumpAndSettle();
      final graphPane = find.byType(NestedScrollView);
      expect(
        find.descendant(of: graphPane, matching: find.byType(Scrollable)),
        findsNWidgets(2),
      );
      await tester.ensureVisible(find.byKey(const ValueKey('moves-tab')));
      await tester.tap(find.byKey(const ValueKey('moves-tab')));
      await tester.pumpAndSettle();
      expect(controller(tester).offset, closeTo(before, 0.1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'completed computer analysis scrolls with the engine header on tablet',
    (tester) async {
      await mount(
        tester,
        const Size(1024, 600),
        replay: AnalysisSession.fromPgn(
          '1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 *',
        ),
      );
      await tester.ensureVisible(find.byKey(const ValueKey('graph-tab')));
      await tester.tap(find.byKey(const ValueKey('graph-tab')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('run-computer-analysis')),
      );
      await tester.tap(find.byKey(const ValueKey('run-computer-analysis')));
      await tester.pumpAndSettle();
      expect(find.byType(AnalysisGraph), findsOneWidget);
      final pane = find.byType(NestedScrollView);
      expect(
        find.descendant(of: pane, matching: find.byType(Scrollable)),
        findsNWidgets(2),
      );
      final scroll = find
          .descendant(of: pane, matching: find.byType(CustomScrollView))
          .last;
      final viewport = tester.getRect(scroll);
      await tester.dragFrom(viewport.center, const Offset(0, -250));
      await tester.pumpAndSettle();
      expect(totalOffset(tester), greaterThan(0));
      for (var i = 0; i < 10 && totalOffset(tester) > 0; i++) {
        await tester.dragFrom(viewport.center, const Offset(0, 250));
        await tester.pumpAndSettle();
      }
      expect(totalOffset(tester), closeTo(0, .1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('very short windows can scroll to controls without overflow', (
    tester,
  ) async {
    await mount(tester, const Size(480, 200));
    expect(find.byType(NestedScrollView), findsNothing);
    await tester.ensureVisible(
      find.byTooltip('Next move', skipOffstage: false),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Next move').hitTestable(), findsOneWidget);
    expect(find.byTooltip('Previous move').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'side cutouts and gesture insets preserve board and pane access',
    (tester) async {
      await mount(
        tester,
        const Size(873, 393),
        padding: const EdgeInsets.only(left: 32, right: 24, bottom: 24),
      );
      final board = tester.getRect(find.byType(cg.Chessboard));
      final controls = tester.getRect(
        find.byKey(const ValueKey('analysis-controls')),
      );
      expect(board.left, greaterThanOrEqualTo(40));
      expect(board.bottom, closeTo(393 - 24 - 8, 1));
      expect(controls.right, lessThanOrEqualTo(873 - 24));
      expect(controls.bottom, lessThanOrEqualTo(393 - 24));
      final pane = tester.getRect(find.byType(NestedScrollView));
      await tester.dragFrom(pane.center, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(totalOffset(tester), greaterThan(0));
      await tester.dragFrom(pane.center, const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(totalOffset(tester), closeTo(0, .1));
      expect(tester.takeException(), isNull);
    },
  );
}
