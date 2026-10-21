// The notifier drives the actual board painter, including legal-move dots.
// ignore_for_file: invalid_use_of_internal_member

import 'dart:async';
import 'dart:io';

import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart' as dc;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(OpeningNames.load);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final session = AnalysisSession.fromPgn(
    File('test/fixtures/analysis-selection.pgn').readAsStringSync(),
  );
  final boardFinder = find.byType(cg.Chessboard);

  cg.Chessboard board(WidgetTester tester) =>
      tester.widget<cg.Chessboard>(boardFinder);

  Future<void> touch(WidgetTester tester, dc.Square square) async {
    final widget = board(tester);
    final size = widget.size / 8;
    final file = square.file;
    final rank = square.rank;
    await tester.tapAt(
      tester.getTopLeft(boardFinder) +
          Offset((file + 0.5) * size, (7 - rank + 0.5) * size),
    );
    await tester.pumpAndSettle();
  }

  void expectCleared(WidgetTester tester) {
    final highlights = board(tester).controller.highlightNotifier;
    expect(highlights.selected, isNull);
    expect(highlights.moveDests, isEmpty);
    expect(highlights.premoveDests, isEmpty);
  }

  void expectQueenSelected(WidgetTester tester) {
    final controller = board(tester).controller;
    expect(controller.highlightNotifier.selected, dc.Square.e5);
    expect(controller.highlightNotifier.moveDests, isNotEmpty);
    expect(
      controller.highlightNotifier.moveDests,
      controller.game.validMoves[dc.Square.e5],
    );
  }

  void usePortraitSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(576, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  for (final imported in [false, true]) {
    testWidgets(
      'seeking clears selection and legal moves (${imported ? "imported PGN" : "game review"})',
      (tester) async {
        usePortraitSize(tester);
        expect(session.sanMoves.sublist(39, 42), ['Kf8', 'Bc4', 'Nd7']);
        final pendingReview = Completer<StockfishReview>();
        Future<StockfishReview> evaluate(String fen) =>
            fen == session.positions[40]
            ? pendingReview.future
            : Future.value(const StockfishReview(0, 'e5b8'));
        await tester.pumpWidget(
          MaterialApp(
            home: imported
                ? AnalysisBoardPage(
                    initialSession: session,
                    initialCurrentFen: session.positions[40],
                    maiaElo: 1600,
                    evaluator: evaluate,
                    maiaEvaluator: (_, _) async => null,
                  )
                : ReviewPage(
                    positions: session.positions,
                    uciMoves: session.uciMoves,
                    sanMoves: session.sanMoves,
                    pgn: session.pgn,
                    playerIsWhite: true,
                    initialCurrentFen: session.positions[40],
                    onHome: () {},
                    evaluator: evaluate,
                    maiaEvaluator: (_, _) async => null,
                  ),
          ),
        );
        await tester.pumpAndSettle();
        expectCleared(tester);
        final controller = board(tester).controller;

        // Analysis results/rebuilds at the same position must preserve a touch.
        await touch(tester, dc.Square.e5);
        expectQueenSelected(tester);
        final selectedBoardState = tester.state(boardFinder);
        pendingReview.complete(const StockfishReview(0, 'e5b8'));
        await tester.pumpAndSettle();
        expectQueenSelected(tester);
        expect(tester.state(boardFinder), same(selectedBoardState));

        // Previously selection survived Black's turn and the dots reappeared
        // at 21...Nd7 without another touch of the queen.
        for (final ply in [41, 42]) {
          await tester.tap(find.byKey(const ValueKey('next-move-button')));
          await tester.pumpAndSettle();
          expect(controller.fen, session.positions[ply]);
          expect(controller.lastMove?.uci, session.uciMoves[ply - 1]);
          expectCleared(tester);
        }
        expect(board(tester).controller, same(controller));

        await touch(tester, dc.Square.e5);
        expectQueenSelected(tester);
        for (final ply in [41, 40]) {
          await tester.tap(find.byKey(const ValueKey('previous-move-button')));
          await tester.pumpAndSettle();
          expect(controller.fen, session.positions[ply]);
          expectCleared(tester);
        }

        // Direct move-list seeking also requires a new touch.
        await touch(tester, dc.Square.e5);
        expectQueenSelected(tester);
        final target = find.descendant(
          of: find.byKey(const ValueKey('analysis-move-list')),
          matching: find.text('Nd7'),
        );
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pumpAndSettle();
        expect(controller.fen, session.positions[42]);
        expectCleared(tester);

        // Jumping to an interactive endpoint must clear selection too; this
        // does not rely on the existing automatic reset at checkmate.
        await touch(tester, dc.Square.e5);
        expectQueenSelected(tester);
        await tester.longPress(
          find.byKey(const ValueKey('previous-move-button')),
        );
        await tester.pumpAndSettle();
        expect(controller.fen, session.positions.first);
        expectCleared(tester);
        await touch(tester, dc.Square.e2);
        expect(controller.highlightNotifier.selected, dc.Square.e2);
        expect(controller.highlightNotifier.moveDests, isNotEmpty);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets('playing analysis moves keeps tap and drag interaction', (
    tester,
  ) async {
    usePortraitSize(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: AnalysisBoardPage(
          initialSession: AnalysisSession.fromFen(session.positions[40]),
          maiaElo: 1600,
          evaluator: (_) async => const StockfishReview(0, 'e5b8'),
          maiaEvaluator: (_, _) async => null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final state = tester.state(boardFinder);
    await touch(tester, dc.Square.e5);
    await touch(tester, dc.Square.e4);
    expect(board(tester).controller.lastMove?.uci, 'e5e4');
    expect(tester.state(boardFinder), same(state));
    expectCleared(tester);

    final rect = tester.getRect(boardFinder);
    final size = board(tester).size / 8;
    final from = rect.topLeft + Offset(1.5 * size, 2.5 * size);
    await tester.dragFrom(from, Offset(size, 0));
    await tester.pumpAndSettle();
    expect(board(tester).controller.lastMove?.uci, 'b6c6');
    expect(tester.state(boardFinder), same(state));
    expectCleared(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
