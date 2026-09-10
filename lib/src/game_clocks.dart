part of '../main.dart';

/// Unknown entries keep their ply rather than shifting later snapshots forward.
List<ClockSnapshot?> restoreClockHistory(Object? saved, int positions) {
  final entries = saved is List ? saved : const [];
  return List.generate(positions, (ply) {
    final entry = ply < entries.length ? entries[ply] : null;
    if (entry is! List || entry.length != 2) return null;
    final white = entry[0];
    final black = entry[1];
    if (white is! int || black is! int || white < 0 || black < 0) return null;
    return ClockSnapshot(white, black);
  });
}

class PgnClockExporter {
  static String format(int milliseconds) {
    final value = max(0, milliseconds);
    final hours = value ~/ 3600000;
    final minutes = (value ~/ 60000 % 60).toString().padLeft(2, '0');
    final seconds = (value ~/ 1000 % 60).toString().padLeft(2, '0');
    final millis = (value % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds.$millis';
  }

  /// Annotate only played moves. Imported clock tags are authoritative.
  static String export(
    String pgn, {
    required List<ClockSnapshot?> history,
    int? baseSeconds,
    int incrementSeconds = 0,
  }) {
    if (baseSeconds == null) return pgn;
    final game = dc.PgnGame.parsePgn(pgn, initHeaders: dc.PgnGame.emptyHeaders);
    game.headers.putIfAbsent(
      'TimeControl',
      () => '$baseSeconds+$incrementSeconds',
    );
    var side = dc.Setup.parseFen(
      game.headers['FEN'] ?? chess.Chess.DEFAULT_POSITION,
    ).turn;
    var ply = 0;
    for (final move in game.moves.mainline()) {
      ply++;
      final snapshot = ply < history.length ? history[ply] : null;
      if (snapshot != null &&
          !(move.comments ?? const []).any((text) => text.contains('[%clk '))) {
        final millis = side == dc.Side.white
            ? snapshot.whiteMillis
            : snapshot.blackMillis;
        move.comments = [...?move.comments, '[%clk ${format(millis)}]'];
      }
      side = side.opposite;
    }
    return game.makePgn().trim();
  }
}
