import 'dart:io';
import 'dart:typed_data';

import 'package:chess/chess.dart' as chess;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/l10n/app_localizations.dart';
import 'package:maia_chess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late SamplingCapture capture;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('maia-capture-ui-');
    capture = SamplingCapture(directory: directory);
    SamplingCapture.instance = capture;
    await capture.setEnabled(true);
    capture
        .begin(
          gameId: SamplingCapture.newId(),
          generation: 0,
          ply: 0,
          fen: chess.Chess.DEFAULT_POSITION,
          positions: [chess.Chess.DEFAULT_POSITION],
          prefix: [],
          history: false,
          elo: 1600,
          tokens: Float32List(6208),
          backend: 'test',
        )!
        .finish('timeout');
    await capture.flush();
    await capture.setEnabled(false);
  });
  tearDown(() async {
    await capture.flush();
    capture.dispose();
    SamplingCapture.instance = SamplingCapture();
    await directory.delete(recursive: true);
  });
  testWidgets(
    'retained data controls and scrollable help in every locale at large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final locale in AppLocalizations.supportedLocales) {
        final strings = await AppLocalizations.delegate.load(locale);
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const Scaffold(
              body: SingleChildScrollView(child: SamplingCaptureSettings()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final toggle = find.byKey(const ValueKey('sampling-data-toggle'));
        expect(tester.widget<SwitchListTile>(toggle).value, false);
        expect(find.text(strings.exportSamplingData), findsOneWidget);
        expect(find.text(strings.clearSamplingData), findsOneWidget);
        await tester.tap(find.byTooltip(strings.saveMaiaSamplingData));
        await tester.pumpAndSettle();
        expect(find.text(strings.samplingDataHelp), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(strings.close));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
