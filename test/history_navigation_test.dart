import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';

void main() {
  testWidgets('navigator exposes explicit accessible 48dp controls', (
    tester,
  ) async {
    var selected = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MoveHistoryNavigator(
            firstKey: const ValueKey('first'),
            previousKey: const ValueKey('previous'),
            nextKey: const ValueKey('next'),
            lastKey: const ValueKey('last'),
            statusKey: const ValueKey('status'),
            status: 'History · 3 / 8',
            statusSemanticsLabel: 'History position, move 3 of 8',
            canGoBack: true,
            canGoForward: true,
            onFirst: () => selected = 'first',
            onPrevious: () => selected = 'previous',
            onNext: () => selected = 'next',
            onLast: () => selected = 'last',
          ),
        ),
      ),
    );

    for (final key in const ['first', 'previous', 'next', 'last']) {
      expect(tester.getSize(find.byKey(ValueKey(key))), const Size(48, 48));
    }
    expect(find.bySemanticsLabel('Beginning'), findsOneWidget);
    expect(find.bySemanticsLabel('Previous move'), findsOneWidget);
    expect(find.bySemanticsLabel('Next move'), findsOneWidget);
    expect(find.bySemanticsLabel('Latest position'), findsOneWidget);
    expect(
      find.bySemanticsLabel('History position, move 3 of 8'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('first')));
    expect(selected, 'first');
    await tester.tap(find.byKey(const ValueKey('previous')));
    expect(selected, 'previous');
    await tester.tap(find.byKey(const ValueKey('next')));
    expect(selected, 'next');
    await tester.tap(find.byKey(const ValueKey('last')));
    expect(selected, 'last');
  });

  testWidgets('navigator uses two rows for narrow or large-text layouts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(280, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: Scaffold(
            body: MoveHistoryNavigator(
              firstKey: const ValueKey('first'),
              previousKey: const ValueKey('previous'),
              nextKey: const ValueKey('next'),
              lastKey: const ValueKey('last'),
              statusKey: const ValueKey('status'),
              status: 'Variation · 12 / 37',
              statusSemanticsLabel: 'Variation position, move 12 of 37',
              canGoBack: true,
              canGoForward: true,
              onFirst: () {},
              onPrevious: () {},
              onNext: () {},
              onLast: () {},
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getCenter(find.byKey(const ValueKey('status'))).dy,
      lessThan(tester.getCenter(find.byKey(const ValueKey('previous'))).dy),
    );
    expect(tester.takeException(), isNull);
  });
}
