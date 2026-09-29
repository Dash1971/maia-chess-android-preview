import 'package:chess/chess.dart' as chess;
import 'package:chessground/chessground.dart' as cg;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';

void main() {
  for (final secondary in [false, true]) {
    for (final size in [
      const Size(640, 360),
      const Size(360, 720),
      const Size(320, 568),
      const Size(1200, 800),
    ]) {
      for (final scale in [1.0, 1.6, 2.0]) {
        testWidgets(
          'probabilities are readable and reachable (secondary=$secondary) at $size and scale $scale',
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
                  secondMaiaElo: secondary ? 2400 : null,
                  evaluator: (_) async => const StockfishReview(0, 'e2e4'),
                  maiaPolicyEvaluator: (_, elo) async {
                    final policy = List<double>.filled(4352, 0);
                    policy[MaiaEncoding.moveIndex(
                          elo == 1600 ? 'e2e4' : 'g1f3',
                          false,
                        )] =
                        5;
                    return policy;
                  },
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final before = tester
                .widget<cg.Chessboard>(find.byType(cg.Chessboard))
                .controller
                .fen;
            final line = find.byKey(
              ValueKey(
                secondary ? 'second-maia-engine-line' : 'maia-engine-line',
              ),
            );
            final other = find.byKey(
              ValueKey(secondary ? 'second-maia-other' : 'maia-other'),
            );
            await tester.ensureVisible(other);
            await tester.pumpAndSettle();
            final texts = find.descendant(
              of: line,
              matching: find.byType(RichText),
            );
            if (scale == 1 && size.width == 1200) {
              final labels = find.descendant(
                of: line,
                matching: find.byType(RichText),
              );
              final centers = [
                for (var i = 0; i < labels.evaluate().length; i++)
                  tester.getCenter(labels.at(i)).dy,
              ]..sort();
              expect(
                centers.last - centers.first,
                lessThan(1),
                reason: 'Keep one line when all entries fit',
              );
            }
            // Check painted text, not just the untransformed widget/font size:
            // a FittedBox could otherwise silently undo accessibility scaling.
            final move = tester.renderObject<RenderParagraph>(texts.at(1));
            final otherText = tester.renderObject<RenderParagraph>(
              find.descendant(of: other, matching: find.byType(RichText)),
            );
            final fontSize = (move.text as TextSpan).style!.fontSize!;
            for (final paragraph in [move, otherText]) {
              final ownFontSize = (paragraph.text as TextSpan).style!.fontSize!;
              expect(
                ownFontSize,
                fontSize,
                reason: 'Other uses the move text size',
              );
              final effectiveSize =
                  paragraph.textScaler.scale(ownFontSize) *
                  paragraph.getTransformTo(null).entry(0, 0);
              expect(effectiveSize, closeTo(fontSize * scale, 0.01));
            }
            final target = tester.renderObject<RenderBox>(other);
            final targetRect = MatrixUtils.transformRect(
              target.getTransformTo(null),
              Offset.zero & target.size,
            );
            expect(targetRect.width, greaterThanOrEqualTo(48 - 0.01));
            expect(targetRect.height, greaterThanOrEqualTo(48 - 0.01));
            expect(other.hitTestable(), findsOneWidget);
            await tester.tap(other);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(
              find.text('Maia ${secondary ? 2400 : 1600} move probabilities'),
              findsOneWidget,
            );
            final last = find.byKey(const ValueKey('maia-probability-h2h4'));
            final scrollable = find.descendant(
              of: find.byType(DraggableScrollableSheet),
              matching: find.byType(Scrollable),
            );
            final first = find.byKey(
              ValueKey('maia-probability-${secondary ? 'g1f3' : 'e2e4'}'),
            );
            await tester.scrollUntilVisible(
              first,
              100,
              scrollable: scrollable,
              maxScrolls: 40,
            );
            await tester.pumpAndSettle();
            expect(
              find.descendant(of: first, matching: find.text('89%')),
              findsOneWidget,
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
}
