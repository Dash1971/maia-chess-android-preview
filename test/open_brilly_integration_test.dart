import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartchess/dartchess.dart' as dc;
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:maia_chess/src/brilliant_exchange.dart';

final modelJson = File('assets/classifiers/mute-exchange-model.json')
    .readAsStringSync();
final rows =
    (jsonDecode(
              File('test/fixtures/brilly-exchange-parity.json')
                  .readAsStringSync(),
            )['cases']
            as List)
        .cast<Map<String, dynamic>>();

StockfishReview review(
  List<dynamic> data, {
  bool provenance = false,
  bool stable = true,
}) {
  final lines = [
    for (final dynamic l in data)
      StockfishLine(
        evaluation: (l['cp'] as num?)?.toInt() ?? 0,
        mate: l['mate'] as int?,
        moves: (l['moves'] as List).cast<String>(),
      ),
  ];
  return StockfishReview(
    lines.first.evaluation,
    lines.first.moves.first,
    mate: lines.first.mate,
    lines: lines,
    evidence: provenance
        ? StockfishSearchEvidence(
            depth: 12,
            nodes: 10000,
            timeMs: 500,
            complete: true,
            reset: true,
            quality: GameAnalysisQuality.fast,
            previousLines: stable ? lines : const [],
          )
        : null,
  );
}

({List<String> positions, List<String> moves, List<StockfishReview> scores})
window(
  Map<String, dynamic> row, {
  bool provenance = false,
  bool stable = true,
}) {
  final w = row['window'] as Map<String, dynamic>;
  final positions = (w['positions'] as List).cast<String>().toList();
  final p = dc.Chess.fromSetup(dc.Setup.parseFen(positions.first));
  dc.Move? previous;
  for (final e in p.legalMoves.entries) {
    for (final to in e.value.squares) {
      for (final role
          in p.board.roleAt(e.key) == dc.Role.pawn && (to < 8 || to >= 56)
              ? <dc.Role?>[
                  dc.Role.queen,
                  dc.Role.rook,
                  dc.Role.bishop,
                  dc.Role.knight,
                ]
              : <dc.Role?>[null]) {
        final m = dc.NormalMove(from: e.key, to: to, promotion: role);
        if (p.playUnchecked(m).board.fen == positions[1].split(' ').first) {
          previous = m;
        }
      }
    }
  }
  return (
    positions: positions,
    moves: [previous!.uci, row['uci'] as String],
    scores: [
      // The preceding engine score is irrelevant to the Exchange decision.
      const StockfishReview(0, ''),
      review(w['beforeLines'] as List, provenance: provenance, stable: stable),
      review(w['afterLines'] as List, provenance: provenance, stable: stable),
    ],
  );
}

List<ClassifiedMove> classify(
  ({List<String> positions, List<String> moves, List<StockfishReview> scores})
  w, {
  bool reliable = true,
}) => MoveClassifier.classify(
  scores: w.scores,
  positions: w.positions,
  uciMoves: w.moves,
  exchangeModelJson: modelJson,
  requireReliableComparisons: reliable,
);

void main() {
  final positive = rows.firstWhere((r) => r['key'] == '147572300744:23');
  for (final color in ['w', 'b']) {
    test('new Brilliant award and complete evidence for $color', () {
      final row = rows.firstWhere(
        (r) =>
            r['score'] >= .9 &&
            (r['fenBefore'] as String).split(' ')[1] == color,
      );
      final w = window(row, provenance: true);
      final result = classify(w);
      expect(result.last.ply, 2);
      expect(result.last.classification, MoveClassification.brilliant);
      expect(result.last.whiteMoved, color == 'w');
      expect(
        MoveClassifier.confirmationPlies(
          scores: w.scores,
          positions: w.positions,
          uciMoves: w.moves,
          classifiedMoves: result,
        ),
        isEmpty,
      );
    });
  }
  test(
    'provisional new award uses the existing two-search confirmation budget',
    () {
      final w = window(positive, provenance: true, stable: false);
      final provisional = classify(w, reliable: false);
      expect(provisional.last.classification, MoveClassification.brilliant);
      expect(provisional.last.annotationReliable, false);
      expect(
        classify(w)
            .where((m) => m.classification == MoveClassification.brilliant),
        isEmpty,
      );
      expect(
        MoveClassifier.confirmationPlies(
          scores: w.scores,
          positions: w.positions,
          uciMoves: w.moves,
          classifiedMoves: provisional,
        ),
        [2],
      );
      w.scores[1] = w.scores[1].withAnnotationConfirmation(
        StockfishAnnotationConfirmation(
          before: w.scores[1],
          after: w.scores[2],
        ),
      );
      expect(classify(w).last.classification, MoveClassification.brilliant);
    },
  );
  test('a counterexample overrides apparent iterative stability without changing graph scores', () {
    final w = window(positive, provenance: true);
    final bad = review([
      {
        'cp': -9000,
        'moves': [w.scores[2].bestMove],
      },
    ], provenance: true);
    w.scores[1] = w.scores[1].withAnnotationConfirmation(
      StockfishAnnotationConfirmation(before: w.scores[1], after: bad),
    );
    expect(
      classify(w)
          .where((m) => m.classification == MoveClassification.brilliant),
      isEmpty,
    );
    expect(w.scores[2].evaluation, 0);
  });
  for (final missing in [
    'before',
    'after',
    'second',
    'duplicate',
    'illegal',
    'mismatch',
    'incomplete',
    'mixed quality',
  ]) {
    test('$missing evidence never fabricates a Brilliant', () {
      final w = window(positive, provenance: true);
      switch (missing) {
        case 'before':
          w.scores[1] = const StockfishReview(0, '');
        case 'after':
          w.scores[2] = const StockfishReview(0, '');
        case 'second':
          w.scores[1] = StockfishReview(
            0,
            w.scores[1].bestMove,
            lines: [w.scores[1].lines.first],
          );
        case 'duplicate':
          w.scores[1] = StockfishReview(
            0,
            w.scores[1].bestMove,
            lines: [w.scores[1].lines.first, w.scores[1].lines.first],
          );
        case 'illegal':
          w.scores[2] = const StockfishReview(
            0,
            'a1a8',
            lines: [
              StockfishLine(evaluation: 0, moves: ['a1a8']),
            ],
          );
        case 'mismatch':
          w.positions[2] = dc.Chess.initial.fen;
        case 'incomplete':
          w.scores[2] = StockfishReview(
            0,
            w.scores[2].bestMove,
            lines: w.scores[2].lines,
            evidence: const StockfishSearchEvidence(
              depth: 12,
              nodes: null,
              timeMs: 500,
              complete: false,
              reset: true,
              quality: GameAnalysisQuality.fast,
            ),
          );
        case 'mixed quality':
          w.scores[2] = StockfishReview(
            0,
            w.scores[2].bestMove,
            lines: w.scores[2].lines,
            evidence: StockfishSearchEvidence(
              depth: 14,
              nodes: null,
              timeMs: 1000,
              complete: true,
              reset: true,
              quality: GameAnalysisQuality.balanced,
              previousLines: w.scores[2].lines,
            ),
          );
      }
      expect(
        classify(w)
            .where((m) => m.classification == MoveClassification.brilliant),
        isEmpty,
      );
    });
  }
  test(
    'mate conversion matches the reference, including mate zero and both POVs',
    () {
      expect(BrilliantExchange.lineCp(cp: 999999, moverIsWhite: true), 9000);
      expect(BrilliantExchange.lineCp(cp: 200, moverIsWhite: false), -200);
      expect(
        BrilliantExchange.lineCp(cp: 0, mate: 3, moverIsWhite: true),
        9970,
      );
      expect(
        BrilliantExchange.lineCp(cp: 0, mate: 3, moverIsWhite: false),
        -9970,
      );
      expect(
        BrilliantExchange.lineCp(cp: 0, mate: -200, moverIsWhite: false),
        9010,
      );
      expect(
        BrilliantExchange.lineCp(cp: 0, mate: 0, moverIsWhite: true),
        -10000,
      );
      expect(
        BrilliantExchange.lineCp(cp: 0, mate: 0, moverIsWhite: false),
        -10000,
      );
    },
  );
  test(
    'model-backed worker cancels before spawn, then a replacement completes',
    () async {
      final w = window(positive);
      final job = MoveClassifier.startOffMainIsolate(
        scores: w.scores,
        positions: w.positions,
        uciMoves: w.moves,
        exchangeModelJson: modelJson,
      );
      final cancelled = expectLater(
        job.result,
        throwsA(isA<MoveClassificationCancelled>()),
      );
      job.cancel();
      await cancelled;
      await job.terminated.timeout(const Duration(seconds: 3));
      final replacement = MoveClassifier.startOffMainIsolate(
        scores: w.scores,
        positions: w.positions,
        uciMoves: w.moves,
        exchangeModelJson: modelJson,
      );
      expect(
        (await replacement.result).last.classification,
        MoveClassification.brilliant,
      );
      await replacement.terminated.timeout(const Duration(seconds: 3));
    },
  );
  test('running model worker keeps the event loop free and cancels without partial output', () async {
    final corpus = jsonDecode(
      File('test/fixtures/classification/stockfish18-fast.json')
          .readAsStringSync(),
    );
    final run = corpus['runs'].first;
    final positions = (run['positions'] as List).cast<String>();
    final moves = (run['moves'] as List).cast<String>();
    final scores = [
      for (final row in run['scores'] as List)
        (row['lines'] as List).isEmpty
            ? StockfishReview(
                row['cp'] as int,
                '(none)',
                mate: row['mate'] as int?,
              )
            : review(row['lines'] as List),
    ];
    final job = MoveClassifier.startOffMainIsolate(
      scores: scores,
      positions: positions,
      uciMoves: moves,
      exchangeModelJson: modelJson,
    );
    final cancelled = expectLater(
      job.result,
      throwsA(isA<MoveClassificationCancelled>()),
    );
    try {
      await job.started.timeout(const Duration(seconds: 5));
      final tick = Completer<void>();
      Timer.run(tick.complete);
      await tick.future.timeout(const Duration(seconds: 1));
      job.cancel();
      await cancelled;
      await job.terminated.timeout(const Duration(seconds: 5));
      expect(job.materialCache, isEmpty);
    } finally {
      job.cancel();
      await job.terminated;
    }
  });
  test('new award persists as one standard NAG; reanalysis and stripped export replace it', () {
    final w = window(positive);
    final awarded = classify(w).last;
    final source =
        '[SetUp "1"]\n[FEN "${positive['fenBefore']}"]\n\n12. ${positive['san']} {note [%clk 0:05:00]} *';
    final session = AnalysisSession.fromPgn(source);
    String write(String pgn, List<ClassifiedMove> marks) =>
        PgnAnalysisAnnotations.write(
          pgn,
          scores: w.scores.sublist(1),
          positions: session.positions,
          uciMoves: session.uciMoves,
          classifications: marks,
        );
    final annotated = write(source, [
      ClassifiedMove(ply: 1, classification: awarded.classification),
    ]);
    expect(RegExp(r'\$3\b').allMatches(annotated), hasLength(1));
    final restored = PgnAnalysisAnnotations.read(annotated);
    expect(
      restored.classifications.single.classification,
      MoveClassification.brilliant,
    );
    expect(restored.scores, hasLength(2));
    for (final clean in [
      write(annotated, []),
      PgnAnalysisAnnotations.withoutAnalysis(annotated),
    ]) {
      expect(clean, contains('note'));
      expect(clean, contains('[%clk 0:05:00]'));
      expect(PgnAnalysisAnnotations.read(clean).classifications, isEmpty);
    }
  });
}
