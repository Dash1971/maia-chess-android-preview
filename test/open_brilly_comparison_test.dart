import 'dart:convert';
import 'dart:io';

import 'package:chess/chess.dart' as chess;
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';

import 'open_brilly_integration_test.dart' as fixture;

void main() {
  test('old/new awards on recorded Mobile Maia engine evidence; other grades unchanged', () {
    final totals = <String, int>{
      'runs': 0,
      'moves': 0,
      'legacyBrilliant': 0,
      'exchangeBrilliant': 0,
      'added': 0,
      'removed': 0,
      'strictBeforeConfirmation': 0,
    };
    final changed = <Map<String, Object?>>[];
    final elapsed = <String, int>{
      'legacyMicroseconds': 0,
      'exchangeMicroseconds': 0,
    };
    for (final file in [
      'stockfish18-fast',
      'stockfish18-balanced-thorough',
      'stockfish-light-fast',
      'stockfish-light-balanced-thorough',
    ]) {
      final data = jsonDecode(
        File('test/fixtures/classification/$file.json').readAsStringSync(),
      );
      for (final dynamic run in data['runs']) {
        final positions = (run['positions'] as List).cast<String>();
        final moves = (run['moves'] as List).cast<String>();
        final scores = <StockfishReview>[], production = <StockfishReview>[];
        for (var i = 0; i < positions.length; i++) {
          final dynamic row = run['scores'][i];
          final lines = [
            for (final dynamic l in row['lines'])
              StockfishLine(
                evaluation: l['cp'] as int,
                mate: l['mate'] as int?,
                moves: (l['moves'] as List).cast<String>(),
              ),
          ];
          final raw = StockfishReview(
            row['cp'] as int,
            lines.isEmpty ? '(none)' : lines.first.moves.first,
            mate: row['mate'] as int?,
            lines: lines,
          );
          scores.add(raw);
          final game = chess.Chess.fromFEN(positions[i]);
          final parser = StockfishSearchSnapshots(
            legalMoves: game
                .moves({'asObjects': true})
                .cast<chess.Move>()
                .map(MaiaEncoding.uci)
                .toSet(),
          );
          for (final text in row['raw'] as List) {
            parser.add(text as String);
          }
          final snapshot = parser.completed;
          production.add(
            StockfishReview(
              raw.evaluation,
              raw.bestMove,
              mate: raw.mate,
              lines: lines,
              evidence: snapshot == null
                  ? null
                  : StockfishSearchEvidence(
                      depth: snapshot.depth,
                      nodes: snapshot.nodes,
                      timeMs: snapshot.timeMs,
                      complete: true,
                      reset: false,
                      quality: GameAnalysisQuality.fromStoredName(
                        run['quality'] as String?,
                      ),
                      previousLines:
                          parser.previous?.lines
                              .map(
                                (l) =>
                                    l.forWhite(game.turn == chess.Color.BLACK),
                              )
                              .toList() ??
                          const [],
                    ),
            ),
          );
        }
        final watch = Stopwatch()..start();
        final old = MoveClassifier.classify(
          scores: scores,
          positions: positions,
          uciMoves: moves,
        );
        elapsed['legacyMicroseconds'] =
            elapsed['legacyMicroseconds']! + watch.elapsedMicroseconds;
        watch.reset();
        final next = MoveClassifier.classify(
          scores: scores,
          positions: positions,
          uciMoves: moves,
          exchangeModelJson: fixture.modelJson,
        );
        elapsed['exchangeMicroseconds'] =
            elapsed['exchangeMicroseconds']! + watch.elapsedMicroseconds;
        watch.stop();
        final strict = MoveClassifier.classify(
          scores: production,
          positions: positions,
          uciMoves: moves,
          exchangeModelJson: fixture.modelJson,
        );
        final oldBy = {for (final m in old) m.ply: m.classification},
            newBy = {for (final m in next) m.ply: m.classification};
        final oldB = old
            .where((m) => m.classification == MoveClassification.brilliant)
            .map((m) => m.ply)
            .toSet();
        final newB = next
            .where((m) => m.classification == MoveClassification.brilliant)
            .map((m) => m.ply)
            .toSet();
        totals['runs'] = totals['runs']! + 1;
        totals['moves'] = totals['moves']! + moves.length;
        totals['legacyBrilliant'] = totals['legacyBrilliant']! + oldB.length;
        totals['exchangeBrilliant'] =
            totals['exchangeBrilliant']! + newB.length;
        totals['added'] = totals['added']! + newB.difference(oldB).length;
        totals['removed'] = totals['removed']! + oldB.difference(newB).length;
        totals['strictBeforeConfirmation'] =
            totals['strictBeforeConfirmation']! +
            strict
                .where((m) => m.classification == MoveClassification.brilliant)
                .length;
        for (var ply = 1; ply <= moves.length; ply++) {
          if (oldBy[ply] == newBy[ply]) continue;
          expect(
            oldBy[ply] == MoveClassification.brilliant ||
                newBy[ply] == MoveClassification.brilliant,
            isTrue,
            reason: 'Unrelated grade changed: $file ${run['name']} $ply',
          );
          changed.add({
            'corpus': file,
            'game': run['name'],
            'quality': run['quality'],
            'ply': ply,
            'move': moves[ply - 1],
            'old': oldBy[ply]?.name,
            'new': newBy[ply]?.name,
          });
        }
      }
    }
    stdout.writeln(
      'MOBILE_MAIA_COMPARISON ${jsonEncode({'totals': totals, 'hostTiming': elapsed, 'changed': changed, 'limitation': 'Recorded engine snapshots; no independent Brilliant ground truth. Strict column excludes new confirmation searches.'})}',
    );
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('labeled parity subset comparison, without treating it as a holdout accuracy estimate', () {
    final counts = <String, int>{
      'cases': 0,
      'referenceBrilliant': 0,
      'oldAwards': 0,
      'oldMatching': 0,
      'oldOutsideLabels': 0,
      'newAwards': 0,
      'newMatching': 0,
      'newOutsideLabels': 0,
      'recoveredLabels': 0,
      'lostLabels': 0,
      'addedOutsideLabels': 0,
      'removedOutsideLabels': 0,
    };
    for (final row in fixture.rows) {
      final w = fixture.window(row);
      final cache = <String, int>{};
      final old = MoveClassifier.classify(
        scores: w.scores,
        positions: w.positions,
        uciMoves: w.moves,
        materialCache: cache,
      );
      final next = MoveClassifier.classify(
        scores: w.scores,
        positions: w.positions,
        uciMoves: w.moves,
        materialCache: cache,
        exchangeModelJson: fixture.modelJson,
      );
      final a = old.any(
        (m) => m.ply == 2 && m.classification == MoveClassification.brilliant,
      );
      final b = next.any(
        (m) => m.ply == 2 && m.classification == MoveClassification.brilliant,
      );
      final gold = row['label'] as bool;
      counts['cases'] = counts['cases']! + 1;
      if (gold) {
        counts['referenceBrilliant'] = counts['referenceBrilliant']! + 1;
      }
      if (a) {
        counts['oldAwards'] = counts['oldAwards']! + 1;
        final k = gold ? 'oldMatching' : 'oldOutsideLabels';
        counts[k] = counts[k]! + 1;
      }
      if (b) {
        counts['newAwards'] = counts['newAwards']! + 1;
        final k = gold ? 'newMatching' : 'newOutsideLabels';
        counts[k] = counts[k]! + 1;
      }
      if (b && !a && gold) {
        counts['recoveredLabels'] = counts['recoveredLabels']! + 1;
      }
      if (a && !b && gold) counts['lostLabels'] = counts['lostLabels']! + 1;
      if (b && !a && !gold) {
        counts['addedOutsideLabels'] = counts['addedOutsideLabels']! + 1;
      }
      if (a && !b && !gold) {
        counts['removedOutsideLabels'] = counts['removedOutsideLabels']! + 1;
      }
    }
    stdout.writeln('LABELED_PARITY_COMPARISON ${jsonEncode(counts)}');
    expect(counts['cases'], 360);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
