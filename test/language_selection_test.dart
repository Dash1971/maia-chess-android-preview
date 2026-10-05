import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/l10n/app_localizations.dart';
import 'package:maia_chess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Japanese can be selected and is retained on restart', (
    tester,
  ) async {
    await tester.pumpWidget(const MaiaChessApp());
    await tester.pumpAndSettle();
    expect(find.text('Start game'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-settings-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('app-language-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('日本語').last);
    await tester.pumpAndSettle();

    expect(find.text('対局設定'), findsOneWidget);
    expect(find.text('人間らしい思考時間'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('settings-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('対局開始'), findsOneWidget);
    expect(find.text('解析ボード'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const MaiaChessApp());
    await tester.pumpAndSettle();
    expect(find.text('対局開始'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('home-settings-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('app-language-ja')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    expect(find.text('Game settings'), findsOneWidget);
  });

  for (final (code, label) in [
    ('zh', '简体中文'),
    ('ko', '한국어'),
    ('es', 'Español'),
    ('de', 'Deutsch'),
    ('fr', 'Français'),
    ('ru', 'Русский'),
    ('hi', 'हिन्दी'),
    ('pt', 'Português (Brasil)'),
  ]) {
    testWidgets('$label can be selected and is retained on restart', (
      tester,
    ) async {
      final strings = await AppLocalizations.delegate.load(Locale(code));
      await tester.pumpWidget(const MaiaChessApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('home-settings-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('app-language-system')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(label),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(find.text(strings.gameSettings), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('settings-back-button')));
      await tester.pumpAndSettle();
      expect(find.text(strings.startGame), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(const MaiaChessApp());
      await tester.pumpAndSettle();
      expect(find.text(strings.startGame), findsOneWidget);
      expect(
        (await SharedPreferences.getInstance()).getString('appLanguageV1'),
        code,
      );
    });
  }
}
