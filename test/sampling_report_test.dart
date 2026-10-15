import 'dart:convert';
import 'dart:io';

import 'package:chess/chess.dart' as chess;
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:maia_chess/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

Map<String, dynamic> reportRecord({
  String fen = chess.Chess.DEFAULT_POSITION,
  String move = 'e2e4',
  String outcome = 'committed',
  String id = 'one',
}) {
  final board = chess.Chess.fromFEN(fen);
  final moves = board.moves({'asObjects': true}).cast<chess.Move>();
  return {
    'schema': 1,
    'algorithm': 'mobile-maia-sampler-v1',
    'gameId': 'game',
    'requestId': id,
    'fen': fen,
    'selfElo': 1600,
    'historyEnabled': false,
    'startedAt': '2026-10-15T00:00:00Z',
    'outcome': outcome,
    if (outcome == 'committed') 'committedMove': move,
    'sampling': {'effectiveTemperature': 0.5, 'effectiveTopP': 0.9},
    'rawLegalPolicy': [
      for (final m in moves)
        {'uci': MaiaEncoding.uci(m), 'probability': 1 / moves.length},
    ],
  };
}

String exportText(List<Map<String, dynamic>> records, {int pruned = 0}) {
  final lines = [
    jsonEncode({
      'type': 'manifest',
      'schema': 1,
      'algorithm': 'mobile-maia-sampler-v1',
      'prunedGames': pruned,
      'droppedRecords': 0,
      'storageErrorObserved': false,
    }),
    for (final r in records)
      jsonEncode({
        'record': jsonEncode(r),
        'sha256': sha256.convert(utf8.encode(jsonEncode(r))).toString(),
      }),
  ];
  final body = '${lines.join('\n')}\n';
  return '$body${jsonEncode({'type': 'footer', 'records': records.length, 'contentSha256': sha256.convert(utf8.encode(body)).toString()})}\n';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('maia-report-test');
  });
  tearDown(() async {
    await dir.delete(recursive: true);
  });
  Future<SamplingReport> read(String text) async {
    final f = await File('${dir.path}/export.jsonl').writeAsString(text);
    return SamplingReport.read(f);
  }

  test('notation for both colors, castling, en passant, promotion, check and disambiguation', () {
    for (final example in [
      (chess.Chess.DEFAULT_POSITION, 'g1f3', 'Nf3'),
      (
        'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1',
        'g8f6',
        'Nf6',
      ),
      ('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1', 'e1g1', 'O-O'),
      ('r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1', 'e8c8', 'O-O-O'),
      ('7k/8/8/3pP3/8/8/8/7K w - d6 0 1', 'e5d6', 'exd6'),
      ('7k/P7/8/8/8/8/8/7K w - - 0 1', 'a7a8q', 'a8=Q+'),
      ('7k/8/8/8/8/8/p7/7K b - - 0 1', 'a2a1n', 'a1=N'),
      ('7k/8/8/8/8/8/8/1N1N3K w - - 0 1', 'b1c3', 'Nbc3'),
    ]) {
      final d = SamplingReportDecision.fromJson(
        reportRecord(fen: example.$1, move: example.$2),
      );
      expect(d.played!.san, example.$3);
      expect(d.alternatives, hasLength(3));
      expect(d.alternatives.any((m) => m.uci == d.played!.uci), false);
    }
  });
  test(
    'verifies checksums and retains settings, takebacks and unplayed attempts',
    () async {
      final records = [
        reportRecord(),
        reportRecord(id: 'retry'),
        for (final state in [
          'pending',
          'timeout',
          'cancelled-or-stale',
          'clock-expired',
          'error',
          'invalid-output',
        ])
          reportRecord(id: state, outcome: state),
      ];
      records[1]['sampling'] = {
        'effectiveTemperature': 0.0,
        'effectiveTopP': 0.0,
      };
      records[1]['historyEnabled'] = true;
      records[2].remove('sampling');
      records[2].remove('rawLegalPolicy');
      final report = await read(exportText(records, pruned: 1));
      expect(report.games, hasLength(1));
      expect(report.decisions, hasLength(8));
      expect(report.incomplete, true);
      expect(report.decisions[1].temperature, 0);
      expect(report.decisions[1].history, true);
      expect(report.decisions[2].temperature, isNull);
      expect(report.decisions.skip(2).every((d) => d.played == null), true);
      expect(report.decisions.first.played!.probability, closeTo(0.05, 0.0001));
    },
  );
  test(
    'rejects corruption, unsupported schema, truncation and trailing data',
    () async {
      final valid = exportText([reportRecord()]);
      for (final bad in [
        valid.replaceFirst('1600', '1700'),
        valid.replaceFirst('"schema":1', '"schema":2'),
        valid.substring(0, valid.lastIndexOf('{"type":"footer"')),
        '$valid{}\n',
        valid.replaceFirst('"records":1', '"records":0'),
        valid.replaceAll('\n', '\r\n'),
        valid.substring(0, valid.length - 1),
      ]) {
        await expectLater(read(bad), throwsFormatException);
      }
      expect(
        () => SamplingReportDecision.fromJson(
          reportRecord()..['committedMove'] = 'a1a8',
        ),
        throwsFormatException,
      );
      expect(
        () =>
            SamplingReportDecision.fromJson(reportRecord()..['fen'] = 'broken'),
        throwsFormatException,
      );
      final duplicate = reportRecord();
      (duplicate['rawLegalPolicy'] as List).add(duplicate['rawLegalPolicy'][0]);
      expect(
        () => SamplingReportDecision.fromJson(duplicate),
        throwsFormatException,
      );
    },
  );
  test(
    'localized HTML is offline, escaped, small, and includes bundled diagrams',
    () async {
      final report = await read(
        exportText([
          reportRecord(),
          reportRecord(outcome: 'pending', id: 'pending'),
        ]),
      );
      final strings = await AppLocalizations.delegate.load(const Locale('en'));
      final labels = samplingReportText(strings)
        ..['title'] = '<script>alert("x")</script>';
      final pieces = await samplingPieceImages();
      expect(pieces, hasLength(12));
      final f = File('${dir.path}/report.html');
      await writeSamplingReportHtml(report, f, labels, 'en', pieces);
      final html = await f.readAsString();
      expect(html, contains('&lt;script&gt;'));
      expect(html, isNot(contains('<script>')));
      expect(html, isNot(contains('src="https://')));
      expect(html, isNot(contains('url(https://')));
      expect(html, contains('data:image/webp;base64,'));
      expect(html, contains('Not recorded as played'));
      expect(html, contains('e4'));
      expect(html, contains('Position before the move'));
      expect(html, contains('CC BY-SA 3.0'));
      expect(html.length, lessThan(150000));
      expect(samplingPercent(0.0061, 'de'), '0,61%');
    },
  );
  test('large raw payloads are discarded from the compact report', () async {
    final f = File('${dir.path}/large.jsonl');
    final record = reportRecord()
      ..['tokens'] = {'data': List.filled(60000, 'A').join()};
    final content = exportText([
      for (var i = 0; i < 900; i++) {...record, 'requestId': '$i'},
    ]);
    await f.writeAsString(content);
    expect(await f.length(), greaterThan(50 * 1024 * 1024));
    final watch = Stopwatch()..start();
    final report = await SamplingReport.read(f);
    expect(report.decisions, hasLength(900));
    expect(report.decisions.last.alternatives, hasLength(3));
    // Evidence, not a brittle speed assertion on shared CI hosts.
    // ignore: avoid_print
    print(
      'Large report: ${await f.length()} bytes, ${watch.elapsedMilliseconds} ms',
    );
  });
}
