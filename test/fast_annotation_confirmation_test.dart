import 'dart:convert';
import 'dart:io';

import 'package:chess/chess.dart' as chess;
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'stockfish_failure_test.dart' show FakeStockfish;

const before =
    'r2q1rk1/pp2ppbp/2p2np1/2Q3B1/n2PP1b1/2N2N2/PP3PPP/3RKB1R w K - 7 12';
const after =
    'r2q1rk1/pp2ppbp/2p2np1/6B1/n2PP1b1/Q1N2N2/PP3PPP/3RKB1R b K - 8 12';
const unstable = StockfishReview(
  300,
  'c5a3',
  lines: [
    StockfishLine(evaluation: 300, moves: ['c5a3']),
    StockfishLine(evaluation: -10, moves: ['c5b4']),
  ],
  evidence: StockfishSearchEvidence(
    depth: 12,
    nodes: 100,
    timeMs: 20,
    complete: true,
    reset: true,
    quality: GameAnalysisQuality.fast,
    previousLines: [
      StockfishLine(evaluation: 0, moves: ['c5a3']),
      StockfishLine(evaluation: -10, moves: ['c5b4']),
    ],
  ),
);
const next = StockfishReview(300, 'a4c3');

StockfishReview fastReview({
  int evaluation = 280,
  String bestMove = 'c5a3',
  String secondMove = 'c5b4',
  List<StockfishLine> previousLines = const [],
}) => StockfishReview(
  evaluation,
  bestMove,
  lines: [
    StockfishLine(evaluation: evaluation, moves: [bestMove]),
    StockfishLine(evaluation: -15, moves: [secondMove]),
  ],
  evidence: StockfishSearchEvidence(
    depth: 14,
    nodes: 200,
    timeMs: 100,
    complete: true,
    reset: true,
    quality: GameAnalysisQuality.fast,
    previousLines: previousLines,
  ),
);

class ConfirmationEngine extends FakeStockfish {
  final commands = <String>[];
  int searches = 0;
  int? failAt;
  void Function(int)? onSearch;
  @override
  set stdin(String command) {
    commands.add(command);
    if (command.startsWith('go ')) {
      searches++;
      onSearch?.call(searches);
      if (searches == failAt) {
        throw StateError('test failure');
      }
      // Deliberately refutes the initial standout gap; White then Black.
      searchOutput = searches.isOdd
          ? [
              'info depth 14 multipv 1 score cp -190 pv c5a3',
              'info depth 14 multipv 2 score cp -200 pv c5b4',
              'bestmove c5a3',
            ]
          : [
              'info depth 14 multipv 1 score cp 190 pv a4c3',
              'info depth 14 multipv 2 score cp 10 pv b7b5',
              'bestmove a4c3',
            ];
    }
    super.stdin = command;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  List<ClassifiedMove> classify(StockfishReview review) =>
      MoveClassifier.classify(
        scores: [review, next],
        positions: [before, after],
        uciMoves: ['c5a3'],
      );
  test('one-iteration spike cannot earn Brilliant in Fast', () {
    expect(classify(unstable), isEmpty);
    expect(
      MoveClassifier.fastConfirmationPlies(
        scores: [unstable, next],
        positions: [before, after],
        uciMoves: ['c5a3'],
      ),
      [1],
    );
  });
  test('agreement with independent exact search permits upstream rule', () {
    final confirmed = fastReview().confirmedAgainst(unstable);
    expect(
      classify(confirmed).single.classification,
      MoveClassification.brilliant,
    );
    expect(
      MoveClassifier.fastConfirmationPlies(
        scores: [confirmed, next],
        positions: [before, after],
        uciMoves: ['c5a3'],
      ),
      isEmpty,
    );
  });
  test(
    'two completed iterations agreeing on the unique best permit Brilliant',
    () {
      final stable = fastReview(previousLines: unstable.lines);
      expect(
        classify(stable).single.classification,
        MoveClassification.brilliant,
      );
      expect(
        MoveClassifier.fastConfirmationPlies(
          scores: [stable, next],
          positions: [before, after],
          uciMoves: ['c5a3'],
        ),
        isEmpty,
      );
    },
  );
  test(
    'independent confirmation with a different best root refuses the award',
    () {
      final changed = fastReview().confirmedAgainst(
        fastReview(bestMove: 'c5b4', secondMove: 'c5a3'),
      );
      expect(MoveClassifier.hasReliableComparison(changed, true), isFalse);
      expect(classify(changed), isEmpty);
    },
  );
  test('Good uses the same conservative gate as Brilliant', () {
    final game = chess.Chess()..move('e4');
    final review = fastReview(bestMove: 'e2e4', secondMove: 'd2d4');
    List<ClassifiedMove> labels(
      StockfishReview score, {
      bool requireReliableComparisons = true,
    }) => MoveClassifier.classify(
      scores: [score, const StockfishReview(280, 'e7e5')],
      positions: [chess.Chess.DEFAULT_POSITION, game.fen],
      uciMoves: ['e2e4'],
      requireReliableComparisons: requireReliableComparisons,
    );
    expect(labels(review), isEmpty);
    expect(
      labels(review, requireReliableComparisons: false).single.classification,
      MoveClassification.good,
    );
    final independent = fastReview(
      evaluation: 300,
      bestMove: 'e2e4',
      secondMove: 'd2d4',
    );
    expect(
      labels(independent.confirmedAgainst(review)).single.classification,
      MoveClassification.good,
    );
  });
  test('provisional worker returns reusable per-run material and default gate stays conservative', () async {
    final inputCache = <String, int>{};
    final provisional = MoveClassifier.startOffMainIsolate(
      scores: [unstable, next],
      positions: [before, after],
      uciMoves: ['c5a3'],
      requireReliableComparisons: false,
      materialCache: inputCache,
    );
    expect(
      (await provisional.result).single.classification,
      MoveClassification.brilliant,
    );
    await provisional.terminated;
    expect(inputCache, isEmpty, reason: 'the worker owns its cache copy');
    expect(provisional.materialCache.keys, unorderedEquals([before, after]));
    expect(() => provisional.materialCache[before] = 0, throwsUnsupportedError);
    final finalJob = MoveClassifier.startOffMainIsolate(
      scores: [unstable, next],
      positions: [before, after],
      uciMoves: ['c5a3'],
      materialCache: provisional.materialCache,
    );
    expect(await finalJob.result, isEmpty);
    await finalJob.terminated;
    expect(finalJob.materialCache, provisional.materialCache);
  });
  test(
    'cancelled provisional worker returns no partial material cache',
    () async {
      final inputCache = {before: 100};
      final job = MoveClassifier.startOffMainIsolate(
        scores: [unstable, next],
        positions: [before, after],
        uciMoves: ['c5a3'],
        requireReliableComparisons: false,
        materialCache: inputCache,
      );
      final cancelled = expectLater(
        job.result,
        throwsA(isA<MoveClassificationCancelled>()),
      );
      job.cancel();
      await cancelled;
      await job.started.timeout(const Duration(seconds: 3));
      await job.terminated.timeout(const Duration(seconds: 3));
      expect(job.materialCache, isEmpty);
      expect(inputCache, {before: 100});
    },
  );
  test('non-award source moves cannot starve a later Brilliant of the cap', () {
    final corpus = jsonDecode(
      File('test/fixtures/classification/stockfish18-fast.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final source = (corpus['runs'] as List).first as Map<String, dynamic>;
    final positions = (source['positions'] as List).cast<String>();
    final moves = (source['moves'] as List).cast<String>();
    // Actual source candidates are quiet non-awards. Simulate incomplete
    // agreement at these three roots and at the later 17...Be6 sacrifice.
    const unstablePlies = {13, 24, 25, 34};
    final scores = <StockfishReview>[];
    for (final (index, dynamic value) in (source['scores'] as List).indexed) {
      final score = value as Map<String, dynamic>;
      final lines = [
        for (final dynamic line in score['lines'] as List)
          StockfishLine(
            evaluation: line['cp'] as int,
            mate: line['mate'] as int?,
            moves: (line['moves'] as List).cast<String>(),
          ),
      ];
      scores.add(
        StockfishReview(
          score['cp'] as int,
          lines.isEmpty ? '(none)' : lines.first.moves.first,
          mate: score['mate'] as int?,
          lines: lines,
          evidence: StockfishSearchEvidence(
            depth: score['depth'] as int,
            nodes: null,
            timeMs: null,
            complete: lines.isNotEmpty,
            reset: index == 0,
            quality: GameAnalysisQuality.fast,
            previousLines: unstablePlies.contains(index + 1) ? [] : lines,
          ),
        ),
      );
    }
    final provisional = MoveClassifier.classify(
      scores: scores,
      positions: positions,
      uciMoves: moves,
      requireReliableComparisons: false,
      materialCache: {
        for (var i = 0; i < positions.length; i++)
          positions[i]: source['material'][i] as int,
      },
    );
    expect(
      [
        for (final ply in [13, 24, 25]) source['annotations'][ply - 1],
      ],
      ['', '', ''],
    );
    expect(source['annotations'][33], '!!');
    expect(
      MoveClassifier.fastConfirmationPlies(
        scores: scores,
        positions: positions,
        uciMoves: moves,
      ),
      [13, 24, 25],
      reason: 'the old broad selection exhausts the cap',
    );
    expect(
      MoveClassifier.fastConfirmationPlies(
        scores: scores,
        positions: positions,
        uciMoves: moves,
        classifiedMoves: provisional,
      ),
      [34],
    );
  });
  test(
    'reference inputs without search evidence preserve upstream semantics',
    () {
      final reference = StockfishReview(
        unstable.evaluation,
        unstable.bestMove,
        lines: unstable.lines,
      );
      expect(
        classify(reference).single.classification,
        MoveClassification.brilliant,
      );
    },
  );
  test('confirmation is capped at three pairs, regardless of game length', () {
    final scores = <StockfishReview>[];
    final positions = <String>[];
    final moves = <String>[];
    for (var i = 0; i < 20; i++) {
      scores.addAll([unstable, next]);
      positions.addAll([before, after]);
      moves.addAll(['c5a3', 'a4c3']);
    }
    scores.add(unstable);
    positions.add(before);
    expect(
      MoveClassifier.fastConfirmationPlies(
        scores: scores,
        positions: positions,
        uciMoves: moves,
        classifiedMoves: [
          for (var ply = 1; ply <= moves.length; ply += 2)
            ClassifiedMove(
              ply: ply,
              classification: MoveClassification.brilliant,
            ),
        ],
      ),
      [1, 3, 5],
    );
  });
  test('actual queue confirms a before/after pair with 500ms ceiling and fresh state', () async {
    final engine = ConfirmationEngine();
    final analyzer = StockfishAnalyzer.withFactory(engine.create);
    try {
      final scores = await analyzer.confirmFastAnnotations(
        scores: [unstable, next],
        positions: [before, after],
        uciMoves: ['c5a3'],
        classifiedMoves: const [
          ClassifiedMove(ply: 1, classification: MoveClassification.brilliant),
        ],
        scope: MaiaInferenceScope(),
        isCurrent: () => true,
      );
      expect(engine.commands.where((c) => c.startsWith('go ')), [
        'go depth 14 movetime 500',
        'go depth 14 movetime 500',
      ]);
      expect(engine.commands.where((c) => c == 'ucinewgame').length, 1);
      expect(scores.map((s) => s.evaluation), [-190, -190]);
      expect(
        MoveClassifier.classify(
          scores: scores,
          positions: [before, after],
          uciMoves: ['c5a3'],
        ).where((m) => m.classification == MoveClassification.brilliant),
        isEmpty,
      );
      expect(unstable.evaluation, 300, reason: 'input list is unchanged');
    } finally {
      await analyzer.close();
      await engine.output.close();
    }
  });
  test('failure of second search keeps both original scores', () async {
    final engine = ConfirmationEngine()..failAt = 2;
    final analyzer = StockfishAnalyzer.withFactory(engine.create);
    try {
      final result = await analyzer.confirmFastAnnotations(
        scores: [unstable, next],
        positions: [before, after],
        uciMoves: ['c5a3'],
        classifiedMoves: const [
          ClassifiedMove(ply: 1, classification: MoveClassification.brilliant),
        ],
        scope: MaiaInferenceScope(),
        isCurrent: () => true,
      );
      expect(result, [unstable, next]);
      expect(classify(result.first), isEmpty);
    } finally {
      await analyzer.close();
      await engine.output.close();
    }
  });
  test(
    'cancellation after first search starts no successor or stale annotation',
    () async {
      var current = true;
      final engine = ConfirmationEngine()..onSearch = (_) => current = false;
      final analyzer = StockfishAnalyzer.withFactory(engine.create);
      try {
        final result = await analyzer.confirmFastAnnotations(
          scores: [unstable, next],
          positions: [before, after],
          uciMoves: ['c5a3'],
          classifiedMoves: const [
            ClassifiedMove(
              ply: 1,
              classification: MoveClassification.brilliant,
            ),
          ],
          scope: MaiaInferenceScope(),
          isCurrent: () => current,
        );
        expect(result, [unstable, next]);
        expect(engine.searches, 1);
      } finally {
        await analyzer.close();
        await engine.output.close();
      }
    },
  );
  test(
    'terminal material is finite and mating move is not a sacrifice award',
    () {
      const fen = '7k/5Q2/6K1/8/8/8/8/8 w - - 0 1';
      final game = chess.Chess.fromFEN(fen)..move('Qg7#');
      expect(MoveClassifier.materialEvaluation(game.fen), -10000);
      final labels = MoveClassifier.classify(
        scores: const [
          StockfishReview(
            1000,
            'f7g7',
            mate: 1,
            lines: [
              StockfishLine(evaluation: 0, mate: 1, moves: ['f7g7']),
              StockfishLine(evaluation: 0, moves: ['f7f1']),
            ],
          ),
          StockfishReview(0, '(none)', mate: 1),
        ],
        positions: [fen, game.fen],
        uciMoves: ['f7g7'],
      );
      expect(
        labels.where((m) => m.classification == MoveClassification.brilliant),
        isEmpty,
      );
    },
  );
}
