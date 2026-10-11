import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/l10n/app_localizations.dart';
import 'package:maia_chess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final code in [
    'en',
    'ja',
    'zh',
    'ko',
    'es',
    'de',
    'fr',
    'ru',
    'hi',
    'pt',
  ]) {
    testWidgets('history and sampling help remain usable at 200% in $code', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'temperatureV2': 0.5,
        'topPV2': 0.9,
      });
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        maiaEngineChannel,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          maiaEngineChannel,
          null,
        ),
      );
      final strings = await AppLocalizations.delegate.load(Locale(code));
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(code),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const GamePage(),
        ),
      );
      await tester.pumpAndSettle();
      final settings = find.byKey(const ValueKey('home-settings-button'));
      await tester.ensureVisible(settings);
      await tester.tap(settings);
      await tester.pumpAndSettle();
      final toggle = find.byKey(const ValueKey('maia-history-setting'));
      await tester.ensureVisible(toggle);
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      expect(tester.takeException(), isNull);
      final help = find.byKey(const ValueKey('sampling-help'));
      await tester.ensureVisible(help);
      await tester.tap(help);
      await tester.pumpAndSettle();
      expect(find.text(strings.samplingExampleLikely), findsOneWidget);
      expect(find.text(strings.samplingExampleReduced), findsOneWidget);
      expect(find.text(strings.samplingExampleFull), findsOneWidget);
      expect(find.text(strings.maiaHistoryHelp), findsOneWidget);
      for (final (key, path) in [
        ('sampling-research-link', 'studies/maia3-sampling/REPORT.md'),
        ('history-research-link', 'studies/move-history-2026-10-09/REPORT.md'),
      ]) {
        final link = find.byKey(ValueKey(key));
        await Scrollable.ensureVisible(tester.element(link), alignment: 0.5);
        await tester.pumpAndSettle();
        expect(link.hitTestable(), findsOneWidget);
        await tester.tap(link);
        await tester.pumpAndSettle();
        expect(calls.lastWhere((call) => call.method == 'openUrl').arguments, {
          'url':
              'https://github.com/Dash1971/mobile-maia-research/blob/main/$path',
        });
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.text(strings.close));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
