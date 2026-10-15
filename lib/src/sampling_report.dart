part of '../main.dart';

/// A compact projection of capture data: no tensors/logits reach the UI.
class SamplingReport {
  SamplingReport(this.decisions, {required this.incomplete});
  final List<SamplingReportDecision> decisions;
  final bool incomplete;

  /// Streaming and checksum-verified. Call on a worker isolate.
  static Future<SamplingReport> read(File file) async {
    if (await file.length() > 70 * 1024 * 1024) {
      throw const FormatException('Sampling export too large');
    }
    final hashes = <crypto.Digest>[];
    final sink = crypto.sha256.startChunkedConversion(
      _SamplingDigestSink(hashes),
    );
    final decisions = <SamplingReportDecision>[];
    var header = false;
    var footer = false;
    var incomplete = false;
    await for (final bytes in _samplingReportLines(file)) {
      if (footer) throw const FormatException('Invalid sampling export');
      final line = utf8.decode(bytes);
      final envelope = jsonDecode(line) as Map<String, dynamic>;
      if (!header) {
        if (envelope['type'] != 'manifest' ||
            envelope['schema'] != 1 ||
            envelope['algorithm'] != 'mobile-maia-sampler-v1') {
          throw const FormatException('Unsupported sampling report');
        }
        incomplete =
            envelope['storageErrorObserved'] == true ||
            (envelope['droppedRecords'] as num) > 0 ||
            (envelope['prunedGames'] as num) > 0;
        header = true;
      } else if (envelope['type'] == 'footer') {
        sink.close();
        if (envelope['records'] != decisions.length ||
            envelope['contentSha256'] != hashes.single.toString()) {
          throw const FormatException('Sampling export checksum mismatch');
        }
        footer = true;
        continue;
      } else {
        final payload = envelope['record'] as String;
        if (crypto.sha256.convert(utf8.encode(payload)).toString() !=
            envelope['sha256']) {
          throw const FormatException('Sampling record checksum mismatch');
        }
        if (decisions.length >= 8192) {
          throw const FormatException('Too many sampling decisions');
        }
        decisions.add(
          SamplingReportDecision.fromJson(
            jsonDecode(payload) as Map<String, dynamic>,
          ),
        );
      }
      sink.add(bytes);
    }
    if (!footer) throw const FormatException('Incomplete sampling export');
    return SamplingReport(List.unmodifiable(decisions), incomplete: incomplete);
  }

  Map<String, List<SamplingReportDecision>> get games {
    final result = <String, List<SamplingReportDecision>>{};
    for (final decision in decisions) {
      (result[decision.gameId] ??= []).add(decision);
    }
    return result;
  }
}

/// Preserve exact bytes for the footer hash, with a bounded line buffer.
Stream<Uint8List> _samplingReportLines(File file) async* {
  final line = BytesBuilder(copy: false);
  await for (final input in file.openRead()) {
    final chunk = input is Uint8List ? input : Uint8List.fromList(input);
    var start = 0;
    for (var i = 0; i < chunk.length; i++) {
      if (chunk[i] != 10) continue;
      line.add(Uint8List.sublistView(chunk, start, i + 1));
      if (line.length > 1024 * 1024) {
        throw const FormatException('Report line too large');
      }
      yield line.takeBytes();
      start = i + 1;
    }
    if (start < chunk.length) line.add(Uint8List.sublistView(chunk, start));
    if (line.length > 1024 * 1024) {
      throw const FormatException('Report line too large');
    }
  }
  if (line.length != 0) throw const FormatException('Unterminated report line');
}

class SamplingReportMove {
  const SamplingReportMove(this.uci, this.san, this.probability);
  final String uci, san;
  final double probability;
}

class SamplingReportDecision {
  SamplingReportDecision({
    required this.gameId,
    required this.requestId,
    required this.fen,
    required this.number,
    required this.white,
    required this.elo,
    required this.history,
    required this.temperature,
    required this.topP,
    required this.played,
    required this.alternatives,
    required this.startedAt,
  });
  final String gameId, requestId, fen;
  final int number, elo;
  final bool white, history;
  final double? temperature, topP;
  final SamplingReportMove? played;
  final List<SamplingReportMove> alternatives;
  final DateTime startedAt;
  String get moveNumber => '$number${white ? '.' : '…'}';

  factory SamplingReportDecision.fromJson(Map<String, dynamic> r) {
    if (r['schema'] != 1 || r['algorithm'] != 'mobile-maia-sampler-v1') {
      throw const FormatException('Unsupported decision');
    }
    final fen = r['fen'] as String;
    if (chess.Chess.validate_fen(fen)['valid'] != true) {
      throw const FormatException('Invalid report position');
    }
    final game = chess.Chess.fromFEN(fen);
    final moves = {
      for (final m in game.moves({'asObjects': true}).cast<chess.Move>())
        MaiaEncoding.uci(m): m,
    };
    final policy = <String, double>{};
    for (final candidate in (r['rawLegalPolicy'] as List? ?? const [])) {
      final uci = candidate['uci'] as String;
      final p = (candidate['probability'] as num).toDouble();
      if (!moves.containsKey(uci) ||
          !p.isFinite ||
          p < 0 ||
          p > 1 ||
          policy.containsKey(uci)) {
        throw const FormatException('Invalid move probability');
      }
      policy[uci] = p;
    }
    if (policy.isNotEmpty &&
        ((policy.values.fold(0.0, (a, b) => a + b) - 1).abs() > 0.0001 ||
            policy.length != moves.length)) {
      throw const FormatException('Incomplete move probability distribution');
    }
    SamplingReportMove describe(String uci) =>
        SamplingReportMove(uci, game.move_to_san(moves[uci]!), policy[uci]!);
    final committed = r['outcome'] == 'committed';
    final chosen = r['committedMove'] as String?;
    if (committed && (chosen == null || !policy.containsKey(chosen))) {
      throw const FormatException('Played move missing from policy');
    }
    final ranked = policy.keys.toList()
      ..sort((a, b) {
        final order = policy[b]!.compareTo(policy[a]!);
        return order == 0 ? a.compareTo(b) : order;
      });
    final trace = r['sampling'] as Map?;
    double? setting(String name) {
      final v = (trace?[name] as num?)?.toDouble();
      if (v != null && (!v.isFinite || v < 0 || v > 1)) {
        throw const FormatException('Invalid sampler setting');
      }
      return v;
    }

    final fields = fen.split(' ');
    return SamplingReportDecision(
      gameId: r['gameId'] as String,
      requestId: r['requestId'] as String,
      fen: fen,
      number: int.parse(fields[5]),
      white: fields[1] == 'w',
      elo: r['selfElo'] as int,
      history: r['historyEnabled'] as bool,
      temperature: setting('effectiveTemperature'),
      topP: setting('effectiveTopP'),
      startedAt: DateTime.parse(r['startedAt'] as String).toUtc(),
      played: committed ? describe(chosen!) : null,
      alternatives: ranked
          .where((u) => !committed || u != chosen)
          .take(3)
          .map(describe)
          .toList(growable: false),
    );
  }
}

/// Plain strings only: safe to send to the report-generation isolate.
Map<String, String> samplingReportText(AppLocalizations s) => {
  'title': s.samplingSummary,
  'explanation': s.samplingReportExplanation,
  'partial': s.samplingReportPartial,
  'missing': s.samplingReportMissing,
  'played': s.samplingPlayed,
  'notPlayed': s.samplingNotPlayed,
  'alternatives': s.samplingAlternatives,
  'before': s.samplingPositionBefore,
  'white': s.white,
  'black': s.black,
  'temperature': s.temperature,
  'topP': s.topP,
  'historyOn': s.maiaHistoryOn,
  'historyOff': s.maiaHistoryOff,
  'game': s.samplingGame('{number}'),
  'records': s.samplingRecords('{count}'),
};

String samplingPercent(double p, String locale) => p > 0 && p < 0.0001
    ? '<${NumberFormat('0.##', locale).format(0.01)}%'
    : '${NumberFormat('0.##', locale).format(p * 100)}%';

String samplingSettings(
  SamplingReportDecision d,
  Map<String, String> t,
  String locale,
) {
  String n(double? v) =>
      v == null ? '—' : NumberFormat('0.##', locale).format(v);
  return 'Maia ${d.elo} · ${d.white ? t['white'] : t['black']}\n'
      '${t['temperature']}: ${n(d.temperature)} · ${t['topP']}: ${n(d.topP)}\n'
      '${d.history ? t['historyOn'] : t['historyOff']}';
}

Future<Map<String, String>> samplingPieceImages() async {
  final images = <String, String>{};
  for (final entry in cg.PieceSet.cburnettAssets.entries) {
    final image = entry.value;
    final bytes = await rootBundle.load(image.keyName);
    images[dc.Piece(
      color: entry.key.side,
      role: entry.key.role,
    ).fenChar] = base64Encode(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
  }
  return images;
}

/// Self-contained HTML. The only images are the app's bundled chess pieces.
/// No scripts, external URLs, fonts, engine calls or raw numerical arrays.
Future<void> writeSamplingReportHtml(
  SamplingReport report,
  File target,
  Map<String, String> text,
  String locale,
  Map<String, String> pieceImages,
) async {
  const escape = HtmlEscape();
  String e(String value) => escape.convert(value);
  String t(String key) => e(text[key]!);
  final out = target.openWrite();
  try {
    out.write('''<!doctype html><html lang="${e(locale)}"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; img-src data:; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'">
<title>${t('title')}</title><style>
:root{color-scheme:light dark}body{font:16px/1.5 system-ui,sans-serif;max-width:860px;margin:auto;padding:20px;background:#171e16;color:#e0e8df}h1{font-size:28px}h2{font-size:22px;margin-top:36px}small,.muted{color:#bbc9b8}article{padding:16px;margin:12px 0;background:#253026;border-radius:12px}.headline{display:flex;justify-content:space-between;gap:12px;flex-wrap:wrap}.headline strong{font-size:21px}.probability{color:#a7dca4}details{margin-top:12px}summary{cursor:pointer}.board{display:grid;grid-template-columns:repeat(8,1fr);width:min(100%,288px);aspect-ratio:1;margin:12px 0}.square{background:#f0d9b5;background-size:contain;position:relative}.dark{background-color:#b58863}.square b{position:absolute;font:10px system-ui;left:2px;bottom:0;color:#222}.note{border-left:3px solid #a7dca4;padding-left:12px}.settings{white-space:pre-line}.alternatives{margin:8px 0}.option{display:inline-block;margin-right:18px}footer{font-size:12px;margin-top:24px}
''');
    for (final entry in pieceImages.entries) {
      // Only known piece codes and validated base64 supplied by bundled assets.
      if (!RegExp(r'^[prnbqkPRNBQK]$').hasMatch(entry.key) ||
          !RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(entry.value)) {
        throw const FormatException('Invalid embedded piece');
      }
      out.write(
        '.p${entry.key.codeUnitAt(0)}{background-image:url(data:image/webp;base64,${entry.value})}',
      );
    }
    out.write(
      '</style><h1>${t('title')}</h1><p>${t('explanation')}</p><p class="note">${t('partial')}</p>',
    );
    if (report.incomplete) out.write('<p class="note">${t('missing')}</p>');
    var gameIndex = 0;
    var recordIndex = 0;
    for (final game in report.games.values) {
      gameIndex++;
      out.write(
        '<h2>${e(text['game']!.replaceAll('{number}', '$gameIndex'))}</h2><p class="muted">${e(text['records']!.replaceAll('{count}', '${game.length}'))}</p>',
      );
      for (final d in game) {
        final move = d.played;
        out.write(
          '<article><div class="headline"><strong>${e(d.moveNumber)} ${move == null ? t('notPlayed') : '${t('played')}: ${e(move.san)}'}</strong>',
        );
        if (move != null) {
          out.write(
            '<span class="probability">${e(samplingPercent(move.probability, locale))}</span>',
          );
        }
        out.write(
          '</div><p class="settings muted">${e(samplingSettings(d, text, locale))}</p>',
        );
        if (d.alternatives.isNotEmpty) {
          out.write('<div class="alternatives">${t('alternatives')}:<br>');
          for (final m in d.alternatives) {
            out.write(
              '<span class="option">${e(m.san)} <span class="probability">${e(samplingPercent(m.probability, locale))}</span></span>',
            );
          }
          out.write('</div>');
        }
        out.write(
          '<details><summary>${t('before')}</summary><div class="board" role="img" aria-label="${e(d.fen)}">',
        );
        final squares = <String>[];
        for (final ch in d.fen.split(' ').first.replaceAll('/', '').split('')) {
          final count = int.tryParse(ch);
          if (count != null) {
            squares.addAll(List.filled(count, ''));
          } else {
            squares.add(ch);
          }
        }
        for (var i = 0; i < squares.length; i++) {
          final piece = squares[i];
          final rank = 8 - i ~/ 8, file = String.fromCharCode(97 + i % 8);
          final label = i >= 56 ? file : (i % 8 == 0 ? '$rank' : '');
          out.write(
            '<span class="square ${(i ~/ 8 + i % 8).isOdd ? 'dark' : ''} ${piece.isEmpty ? '' : 'p${piece.codeUnitAt(0)}'}"><b>$label</b></span>',
          );
        }
        out.write(
          '</div><small>${e(d.startedAt.toIso8601String())}</small></details></article>',
        );
        if (++recordIndex % 32 == 0) await out.flush();
      }
    }
    out.write(
      '<footer>Mobile Maia · Chess pieces: Colin M. L. Burnett, via Lichess / chessground (WebP conversion). <a href="https://creativecommons.org/licenses/by-sa/3.0/">CC BY-SA 3.0</a> · <a href="https://commons.wikimedia.org/wiki/Category:SVG_chess_pieces">Original artwork</a>.</footer></html>',
    );
    await out.flush();
  } finally {
    await out.close();
  }
}
