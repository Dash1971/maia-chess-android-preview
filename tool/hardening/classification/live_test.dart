// ignore_for_file: invalid_use_of_visible_for_testing_member
// Optional native CLI qualification; not part of the routine Flutter suite.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CliEngine implements StockfishEngineHandle {
  CliEngine(this.process) {
    output = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .asBroadcastStream();
  }
  final Process process;
  late final Stream<String> output;
  final commands = <String>[];
  @override
  Stream<String> get stdout => output;
  @override
  set stdin(String command) {
    commands.add(command);
    process.stdin.writeln(command);
  }

  @override
  Future<void> dispose() async {
    stdin = 'quit';
    await process.exitCode.timeout(const Duration(seconds: 5));
    await process.stdin.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('actual analyzer: cold Fast→Thorough→Fast, annotations and full provenance', () async {
    SharedPreferences.setMockInitialValues({});
    final path = Platform.environment['MAIA_STOCKFISH']!;
    final corpus = jsonDecode(
      File('test/fixtures/classification/stockfish18-fast.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final game = (corpus['runs'] as List).first as Map<String, dynamic>;
    final positions = (game['positions'] as List).cast<String>();
    final moves = (game['moves'] as List).cast<String>();
    final engines = <CliEngine>[];
    final analyzer = StockfishAnalyzer.withFactory(() async {
      final engine = CliEngine(await Process.start(path, []));
      engines.add(engine);
      return engine;
    });
    final runs = <Map<String, Object?>>[];
    try {
      final qualities =
          Platform.environment['MAIA_SEQUENCE']
              ?.split(',')
              .map(GameAnalysisQuality.fromStoredName)
              .toList() ??
          [
            GameAnalysisQuality.fast,
            GameAnalysisQuality.thorough,
            GameAnalysisQuality.fast,
          ];
      for (final quality in qualities) {
        final scope = MaiaInferenceScope();
        final session = Object();
        final watch = Stopwatch()..start();
        final raw = <StockfishReview>[];
        for (final fen in positions) {
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
        final searchMs = watch.elapsedMilliseconds;
        var materialCache = <String, int>{};
        var provisional = <ClassifiedMove>[];
        if (quality == GameAnalysisQuality.fast) {
          final preflight = MoveClassifier.startOffMainIsolate(
            scores: raw,
            positions: positions,
            uciMoves: moves,
            requireReliableComparisons: false,
          );
          provisional = await preflight.result;
          materialCache = Map.of(preflight.materialCache);
          await preflight.terminated;
        }
        final preflightMs = watch.elapsedMilliseconds - searchMs;
        final candidates = MoveClassifier.fastConfirmationPlies(
          scores: raw,
          positions: positions,
          uciMoves: moves,
          classifiedMoves: provisional,
        );
        final scores = quality == GameAnalysisQuality.fast
            ? await analyzer.confirmFastAnnotations(
                scores: raw,
                positions: positions,
                uciMoves: moves,
                classifiedMoves: provisional,
                scope: scope,
                isCurrent: () => true,
              )
            : raw;
        final confirmedMs = watch.elapsedMilliseconds - searchMs - preflightMs;
        final job = MoveClassifier.startOffMainIsolate(
          scores: scores,
          positions: positions,
          uciMoves: moves,
          materialCache: materialCache,
        );
        final labels = await job.result;
        await job.terminated;
        final traces = <Map<String, Object?>>[];
        MoveClassifier.classify(
          scores: scores,
          positions: positions,
          uciMoves: moves,
          trace: traces.add,
          materialCache: materialCache,
        );
        final result = <String, Object?>{
          'quality': quality.name,
          'searchMs': searchMs,
          'preflightMs': preflightMs,
          'confirmationMs': confirmedMs,
          'totalMs': watch.elapsedMilliseconds,
          'candidates': candidates,
          'trace': traces,
          'scores': [
            for (final s in scores)
              {
                'cp': s.evaluation,
                'mate': s.mate,
                'depth': s.evidence?.depth,
                'nodes': s.evidence?.nodes,
                'timeMs': s.evidence?.timeMs,
                'reset': s.evidence?.reset,
                'lines': [
                  for (final l in s.lines)
                    {'cp': l.evaluation, 'mate': l.mate, 'moves': l.moves},
                ],
                'previousLines': [
                  for (final l
                      in s.evidence?.previousLines ?? <StockfishLine>[])
                    {'cp': l.evaluation, 'mate': l.mate, 'moves': l.moves},
                ],
                'confirmationLines': [
                  for (final l in s.confirmationLines)
                    {'cp': l.evaluation, 'mate': l.mate, 'moves': l.moves},
                ],
                'confirmed': s.confirmationLines.isNotEmpty,
              },
          ],
          'labels': [
            for (final m in labels)
              {'ply': m.ply, 'label': m.classification.name},
          ],
        };
        runs.add(result);
        // ignore: avoid_print
        print(
          'LIVE ${quality.name}: ${result['labels']} search=${searchMs}ms confirmation=${confirmedMs}ms',
        );
        if (quality == GameAnalysisQuality.fast) {
          expect(
            labels
                .where((m) => m.classification == MoveClassification.brilliant)
                .map((m) => m.ply),
            [22, 34, 38],
          );
        }
      }
    } finally {
      await analyzer.close();
      final output = Platform.environment['MAIA_LIVE_REPORT'];
      if (output != null) {
        File(output).writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert({
            'engine': path,
            'runs': runs,
            'commands': [for (final e in engines) ...e.commands],
          }),
        );
      }
    }
  }, timeout: const Timeout(Duration(minutes: 10)));
}
