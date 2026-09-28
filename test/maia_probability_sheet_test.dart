import 'package:chess/chess.dart' as chess;
import 'package:chessground/chessground.dart' as cg;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';

void main() {
  for (final size in [
    const Size(640, 360),
    const Size(360, 720),
    const Size(320, 568),
  ]) {
    for (final scale in [1.0, 1.6, 2.0]) {
      testWidgets(
        'all probabilities remain reachable at $size and text scale $scale',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: ReviewPage(
                positions: const [chess.Chess.DEFAULT_POSITION],
                uciMoves: const [],
                sanMoves: const [],
                playerIsWhite: true,
                pgn: '*',
                onHome: () {},
                evaluator: (_) async => const StockfishReview(0, 'e2e4'),
                maiaPolicyEvaluator: (_, _) async =>
                    List<double>.filled(4352, 0),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final before = tester
              .widget<cg.Chessboard>(find.byType(cg.Chessboard))
              .controller
              .fen;
          await tester.ensureVisible(
            find.byKey(const ValueKey('maia-engine-line')),
          );
          await tester.tap(find.byKey(const ValueKey('maia-engine-line')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final last = find.byKey(const ValueKey('maia-probability-h2h4'));
          final scrollable = find.descendant(
            of: find.byType(DraggableScrollableSheet),
            matching: find.byType(Scrollable),
          );
          await tester.scrollUntilVisible(
            last,
            150,
            scrollable: scrollable,
            maxScrolls: 40,
          );
          await tester.pumpAndSettle();
          expect(last.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
          Navigator.of(tester.element(last)).pop();
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<cg.Chessboard>(find.byType(cg.Chessboard))
                .controller
                .fen,
            before,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
