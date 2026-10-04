import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    expect(find.text('人間らしい指し手の間'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('settings-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('対局開始'), findsOneWidget);
    expect(find.text('解析盤'), findsOneWidget);

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
}
