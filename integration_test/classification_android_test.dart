import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maia_chess/main.dart';

import 'fixtures/classification_game.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native Light Fast→Thorough→Fast has coherent scores and no Qa3 Brilliant',
    (tester) async {
      final analyzer = StockfishAnalyzer.instance;
      final fastBrilliancies = <List<int>>[];
      try {
        for (final quality in [
          GameAnalysisQuality.fast,
          GameAnalysisQuality.thorough,
          GameAnalysisQuality.fast,
        ]) {
          final session = Object();
          final scope = MaiaInferenceScope();
          final raw = <StockfishReview>[];
          final watch = Stopwatch()..start();
          for (final fen in classificationPositions) {
            raw.add(
              await analyzer.evaluate(
                fen,
                scope: scope,
                background: true,
                gameAnalysisQuality: quality,
                analysisSession: session,
              ),
            );
          }
          var materialCache = <String, int>{};
          var provisional = <ClassifiedMove>[];
          if (quality == GameAnalysisQuality.fast) {
            final preflight = MoveClassifier.startOffMainIsolate(
              scores: raw,
              positions: classificationPositions,
              uciMoves: classificationMoves,
              requireReliableComparisons: false,
            );
            provisional = await preflight.result;
            materialCache = Map.of(preflight.materialCache);
            await preflight.terminated;
          }
          final scores = quality == GameAnalysisQuality.fast
              ? await analyzer.confirmFastAnnotations(
                  scores: raw,
                  positions: classificationPositions,
                  uciMoves: classificationMoves,
                  classifiedMoves: provisional,
                  scope: scope,
                  isCurrent: () => true,
                )
              : raw;
          final job = MoveClassifier.startOffMainIsolate(
            scores: scores,
            positions: classificationPositions,
            uciMoves: classificationMoves,
            materialCache: materialCache,
          );
          final labels = await job.result;
          await job.terminated;
          // ignore: avoid_print
          print(
            'ANDROID CLASSIFICATION ${quality.name} ${watch.elapsedMilliseconds}ms: ${labels.map((m) => '${m.ply}:${m.classification.name}').join(' ')}',
          );
          for (final score in scores.where((s) => s.lines.isNotEmpty)) {
            expect(score.evaluation, score.lines.first.evaluation);
            expect(score.mate, score.lines.first.mate);
          }
          for (final index in [20, 21, 22, 23, 33, 34, 37, 38]) {
            final score = scores[index];
            // ignore: avoid_print
            print(
              'ANDROID SCORE ${quality.name} $index ${jsonEncode({
                'depth': score.evidence?.depth,
                'nodes': score.evidence?.nodes,
                'timeMs': score.evidence?.timeMs,
                'cp': score.evaluation,
                'lines': [
                  for (final l in score.lines) [l.evaluation, l.mate, l.moves],
                ],
                'previous': [
                  for (final l in score.evidence?.previousLines ?? <StockfishLine>[]) [l.evaluation, l.mate, l.moves],
                ],
                'confirmed': score.confirmationLines.isNotEmpty,
              })}',
            );
          }
          if (quality == GameAnalysisQuality.fast) {
            fastBrilliancies.add(
              labels
                  .where(
                    (m) => m.classification == MoveClassification.brilliant,
                  )
                  .map((m) => m.ply)
                  .toList(),
            );
          }
        }
      } finally {
        await analyzer.close();
      }
      for (final plies in fastBrilliancies) {
        expect(plies, [22, 34, 38]);
      }
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
