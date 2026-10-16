import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:maia_chess/l10n/app_localizations.dart';

const longName =
    'D00 · Queen’s Pawn Game: Accelerated London System, Steinitz Countergambit, Morris Countergambit Accepted';
final action = find.byKey(const ValueKey('review-opening-details'));
final label = find.byKey(const ValueKey('review-opening-name'));
Widget app({
  double width = 320,
  double scale = 1,
  bool bold = false,
  bool rtl = false,
  String? name = longName,
  Locale locale = const Locale('en'),
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(scale), boldText: bold),
    child: child!,
  ),
  home: Scaffold(
    body: Center(
      child: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: SizedBox(
          width: width,
          child: ReviewOpeningName(name: name),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'info uses full available width and follows resize, text size and name',
    (tester) async {
      const short = 'C60 · Ruy Lopez';
      await tester.pumpWidget(app(width: 700, name: short));
      await tester.pumpAndSettle();
      expect(action, findsNothing);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: label, matching: find.byType(RichText)),
      );
      final exactWidth = paragraph.getMaxIntrinsicWidth(double.infinity) + 24;
      // An icon must not steal the space needed by a name that otherwise fits.
      await tester.pumpWidget(app(width: exactWidth + 1, name: short));
      await tester.pumpAndSettle();
      expect(action, findsNothing);
      expect(find.byIcon(Icons.info_outline), findsNothing);
      await tester.pumpWidget(app(width: exactWidth - 1, name: short));
      await tester.pumpAndSettle();
      expect(action, findsOneWidget);
      await tester.pumpWidget(
        app(width: exactWidth + 1, name: short, scale: 2),
      );
      await tester.pumpAndSettle();
      expect(action, findsOneWidget);
      await tester.pumpWidget(app(width: 700, name: short));
      await tester.pumpAndSettle();
      expect(action, findsNothing);
      await tester.pumpWidget(app(width: 320));
      await tester.pumpAndSettle();
      expect(action, findsOneWidget);
      await tester.pumpWidget(app(name: null));
      await tester.pumpAndSettle();
      expect(action, findsNothing);
      expect(label, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final dismissal in ['Close', 'Back', 'outside']) {
    testWidgets('dialog dismisses via $dismissal without changing the label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        final rect = tester.getRect(label);
        expect(tester.getSemantics(action).label, longName);
        await tester.tap(label);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text(longName), findsNWidgets(2));
        if (dismissal == 'Close') {
          await tester.tap(find.text('Close'));
        } else if (dismissal == 'Back') {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tapAt(const Offset(5, 5));
        }
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.getRect(label), rect);
      } finally {
        semantics.dispose();
      }
    });
  }
  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('localized details ${locale.languageCode} at large text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final strings = await AppLocalizations.delegate.load(locale);
      await tester.pumpWidget(
        app(locale: locale, scale: 2, bold: true, rtl: true),
      );
      await tester.pumpAndSettle();
      await tester.tap(action);
      await tester.pumpAndSettle();
      expect(find.text(strings.phaseOpening), findsOneWidget);
      expect(find.text(strings.close).hitTestable(), findsOneWidget);
      final full = find.byKey(const ValueKey('review-opening-full-name'));
      await tester.ensureVisible(full);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(strings.close));
      await tester.pumpAndSettle();
    });
  }
}
