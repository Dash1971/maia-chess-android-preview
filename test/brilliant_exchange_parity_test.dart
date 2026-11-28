import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/src/brilliant_exchange.dart';

void main() {
  final model = BrilliantExchangeModel.fromJson(
    File('assets/classifiers/mute-exchange-model.json').readAsStringSync(),
  );
  final data = jsonDecode(
    File('test/fixtures/brilly-exchange-parity.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final cases = (data['cases'] as List).cast<Map<String, dynamic>>();
  test('reference vector has all 91 features and 360 cases', () {
    expect(model.features, data['model_features']);
    expect(cases, hasLength(360));
  });
  for (final row in cases) {
    test('all features and score: ${row['key']} ${row['san']}', () {
      final evaluator = BrilliantExchange(model);
      final before = (row['before'] as List).cast<Map<String, dynamic>>();
      final after = row['after'] as Map<String, dynamic>;
      final evidence = ExchangeEvidence(
        [
          for (final line in before)
            ExchangeLine(line['uci'] as String, line['cp'] as num),
        ],
        after['cp'] as num,
        after['reply'] as String?,
      );
      final actual = evaluator.features(
        row['fenPrev'] as String?,
        row['fenBefore'] as String,
        row['uci'] as String,
        evidence,
      );
      expect(actual, isNotNull);
      final expected = (row['features'] as Map).cast<String, num>();
      expect(actual!.keys.toSet(), expected.keys.toSet());
      for (final name in model.features) {
        expect(
          actual[name],
          closeTo(expected[name]!, 1e-10),
          reason: '${row['key']}: $name',
        );
      }
      final score = model.score(actual);
      expect(score, closeTo(row['score'] as num, 1e-9));
      expect(score >= model.cutoff, (row['score'] as num) >= model.cutoff);
    }, timeout: const Timeout(Duration(minutes: 2)));
  }
  final edges =
      (jsonDecode(
                File('test/fixtures/brilly-exchange-edges.json')
                    .readAsStringSync(),
              )['cases']
              as List)
          .cast<Map<String, dynamic>>();
  for (final row in edges) {
    test('reference edge: ${row['name']}', () {
      final evidence = ExchangeEvidence(
        [
          for (final l in row['before'] as List)
            ExchangeLine(l['uci'] as String, l['cp'] as num),
        ],
        row['after']['cp'] as num,
        row['after']['reply'] as String?,
      );
      final evaluator = BrilliantExchange(model);
      final actual = evaluator.features(
        row['fenPrev'] as String?,
        row['fenBefore'] as String,
        row['uci'] as String,
        evidence,
      );
      if (row['features'] == null) {
        expect(actual, isNull);
        return;
      }
      final expected = (row['features'] as Map).cast<String, num>();
      expect(actual, isNotNull);
      for (final k in model.features) {
        expect(actual![k], closeTo(expected[k]!, 1e-10), reason: k);
      }
      final score = model.score(actual!);
      expect(score, closeTo(row['score'] as num, 1e-9));
      expect(score >= model.cutoff, row['brilliant']);
    });
  }
}
