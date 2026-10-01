part of '../main.dart';

enum GameAnalysisQuality {
  fast(label: 'Fast', depth: 12, moveTimeMs: 500),
  balanced(label: 'Balanced', depth: 14, moveTimeMs: 1000),
  thorough(label: 'Thorough', depth: 16, moveTimeMs: 1500);

  const GameAnalysisQuality({
    required this.label,
    required this.depth,
    required this.moveTimeMs,
  });

  final String label;
  final int depth;
  final int moveTimeMs;

  String get stockfishCommand => 'go depth $depth movetime $moveTimeMs';

  String get description => switch (this) {
    fast => 'Depth 12 · up to 0.5 seconds per position, plus up to 3 seconds checking standout moves.',
    balanced => 'Depth 14 · up to 1 second per position.',
    thorough => 'Depth 16 · up to 1.5 seconds per position. Most consistent.',
  };

  static GameAnalysisQuality fromStoredName(String? name) =>
      values.firstWhere((value) => value.name == name, orElse: () => fast);
}

abstract interface class StockfishEngineHandle {
  Stream<String> get stdout;

  set stdin(String command);

  Future<void> dispose();
}

final class _MultistockfishHandle implements StockfishEngineHandle {
  _MultistockfishHandle(this._engine);

  final Stockfish _engine;

  @override
  Stream<String> get stdout => _engine.stdout;

  @override
  set stdin(String command) => _engine.stdin = command;

  @override
  Future<void> dispose() => _engine.dispose();
}

typedef StockfishEngineFactory = Future<StockfishEngineHandle> Function();

class StockfishAnalyzer {
  StockfishAnalyzer._()
    : this.withFactory(
        () async => _MultistockfishHandle(await Stockfish.create()),
      );

  /// Allows deterministic native failure tests without loading a chess engine.
  StockfishAnalyzer.withFactory(
    this._createEngine, {
    this.searchTimeout = const Duration(seconds: 20),
    this.drainTimeout = const Duration(seconds: 2),
  });

  static final instance = StockfishAnalyzer._();
  final StockfishEngineFactory _createEngine;
  final Duration searchTimeout;
  final Duration drainTimeout;
  StockfishEngineHandle? _engine;
  Future<void>? _startup;
  bool _searching = false;
  Future<void>? _closing;
  Object? _analysisSession;
  late final EngineWorkQueue<StockfishReview, _StockfishRequest> _queue =
      EngineWorkQueue(
        run: (fen, background, configuration) =>
            _evaluateNow(fen, background: background, request: configuration),
        stop: () {
          if (_searching) _engine?.stdin = 'stop';
        },
        onStopError: (error, stackTrace) => unawaited(
          AppDiagnostics.record('stockfish-stop', error, stackTrace),
        ),
      );

  void cancel(MaiaInferenceScope scope) => _queue.cancel(scope);

  Future<void> _ensureStarted() async {
    final startup = _startup ??= _startEngine();
    try {
      await startup;
    } catch (_) {
      if (identical(_startup, startup)) _startup = null;
      rethrow;
    }
  }

  Future<void> _startEngine() async {
    StockfishEngineHandle? engine;
    try {
      engine = await _createEngine();
      _engine = engine;
      final ready = Completer<void>();
      // A synchronous write failure can abandon the handshake before its
      // future is awaited. Still consume any simultaneous stream error.
      ready.future.ignore();
      final subscription = engine.stdout.listen(
        (line) {
          if (line == 'readyok' && !ready.isCompleted) ready.complete();
        },
        onError: (Object error, StackTrace stack) {
          if (!ready.isCompleted) ready.completeError(error, stack);
        },
        onDone: () {
          if (!ready.isCompleted) {
            ready.completeError(StateError('Stockfish closed during startup'));
          }
        },
      );
      try {
        engine.stdin = 'setoption name Threads value 2';
        engine.stdin = 'setoption name Hash value 64';
        engine.stdin = 'setoption name MultiPV value 2';
        engine.stdin = 'isready';
        await ready.future.timeout(const Duration(seconds: 5));
      } finally {
        await subscription.cancel();
      }
    } catch (_) {
      // start() can succeed while option writes/readiness fail. The native
      // library refuses a second start until that running process is quit.
      await _resetEngine();
      rethrow;
    }
  }

  Future<StockfishReview> evaluate(
    String fen, {
    MaiaInferenceScope? scope,
    bool background = false,
    GameAnalysisQuality? gameAnalysisQuality,
    Object? analysisSession,
    bool verifyAnnotation = false,
  }) => _queue.add(
    fen,
    scope: scope,
    background: background,
    configuration: _StockfishRequest(
      gameAnalysisQuality,
      analysisSession,
      verifyAnnotation,
    ),
  );

  /// At most six additional 500ms searches; a cancelled generation starts
  /// no more work. Each pair is applied atomically, so a failed after-search
  /// cannot combine a confirmation score with an unconfirmed successor.
  Future<List<StockfishReview>> confirmFastAnnotations({
    required List<StockfishReview> scores,
    required List<String> positions,
    required List<String> uciMoves,
    required List<ClassifiedMove> classifiedMoves,
    required MaiaInferenceScope scope,
    required bool Function() isCurrent,
  }) async {
    final result = scores.toList();
    final plies = MoveClassifier.fastConfirmationPlies(
      scores: scores,
      positions: positions,
      uciMoves: uciMoves,
      classifiedMoves: classifiedMoves,
    );
    try {
      for (final ply in plies) {
        if (!isCurrent()) return result;
        final session = Object();
        final before = await evaluate(
          positions[ply - 1],
          scope: scope,
          background: true,
          gameAnalysisQuality: GameAnalysisQuality.fast,
          analysisSession: session,
          verifyAnnotation: true,
        );
        if (!isCurrent()) return result;
        final after = await evaluate(
          positions[ply],
          scope: scope,
          background: true,
          gameAnalysisQuality: GameAnalysisQuality.fast,
          analysisSession: session,
          verifyAnnotation: true,
        );
        if (!isCurrent()) return result;
        result[ply - 1] = before.confirmedAgainst(scores[ply - 1]);
        result[ply] = after;
      }
    } catch (error, stackTrace) {
      if (isCurrent()) {
        unawaited(
          AppDiagnostics.record(
            'stockfish-annotation-check',
            error,
            stackTrace,
          ),
        );
      }
      // Completed original scores remain useful. Unconfirmed standout labels
      // are withheld by the classifier, including candidates beyond the cap.
    }
    return result;
  }

  Future<StockfishReview> _evaluateNow(
    String fen, {
    bool background = false,
    _StockfishRequest? request,
  }) async {
    final position = chess.Chess.fromFEN(fen);
    if (position.in_checkmate) {
      final whiteToMove = fen.split(' ')[1] == 'w';
      return StockfishReview(0, '(none)', mate: whiteToMove ? -1 : 1);
    }
    if (position.game_over) return const StockfishReview(0, '(none)');

    await _ensureStarted();
    final engine = _engine;
    if (engine == null) throw StateError('Stockfish did not start');
    if (!_queue.canRunActive) throw const AnalysisCancelled();
    final completer = Completer<void>();
    completer.future.ignore();
    var bestMove = '';
    final snapshots = StockfishSearchSnapshots(
      legalMoves: position
          .moves({'asObjects': true})
          .cast<chess.Move>()
          .map(MaiaEncoding.uci)
          .toSet(),
    );
    late StreamSubscription<String> subscription;
    subscription = engine.stdout.listen(
      (line) {
        if (completer.isCompleted) return;
        snapshots.add(line);
        if (line.startsWith('bestmove ') && !completer.isCompleted) {
          final fields = line.trim().split(RegExp(r'\s+'));
          final candidate = fields.length > 1 ? fields[1] : '(none)';
          bestMove =
              RegExp(r'^[a-h][1-8][a-h][1-8][qrbn]?$').hasMatch(candidate)
              ? candidate
              : '(none)';
          if (bestMove == '(none)' && candidate != '(none)') {
            unawaited(
              AppDiagnostics.recordEvent(
                'stockfish-invalid-bestmove:$candidate',
              ),
            );
          }
          completer.complete();
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!completer.isCompleted) completer.completeError(error, stack);
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(StateError('Stockfish closed during search'));
        }
      },
    );
    try {
      // This runs inside the serial queue, after the previous search drained.
      // A foreground interruption changes ownership too, so resuming a batch
      // cannot inherit the browsing search's transposition table.
      final reset = !identical(_analysisSession, request?.session);
      if (reset) {
        engine.stdin =
            'setoption name Threads value ${request?.session == null ? 2 : 1}';
        engine.stdin = 'ucinewgame';
        await _ready(engine);
        _analysisSession = request?.session;
      }
      if (!_queue.canRunActive) throw const AnalysisCancelled();
      engine.stdin = 'position fen $fen';
      _searching = true;
      engine.stdin =
          (request?.verifyAnnotation == true
              ? 'go depth 14 movetime 500'
              : request?.quality?.stockfishCommand) ??
          (background
              ? 'go depth 16 movetime 1500'
              : 'go depth 16 movetime 350');
      await completer.future.timeout(searchTimeout);
      // An early stop can legitimately return only bestmove or score bounds.
      // Drain it, then let the queue cancel/retry without reporting a failure.
      if (!_queue.canRunActive) throw const AnalysisCancelled();
      final snapshot = snapshots.completed ?? snapshots.primary;
      if (snapshot == null) {
        throw StateError(
          'Stockfish returned no exact scored principal variation',
        );
      }
      final blackToMove = position.turn == chess.Color.BLACK;
      final lines = snapshot.lines
          .map((line) => line.forWhite(blackToMove))
          .toList(growable: false);
      return StockfishReview(
        lines.first.evaluation,
        bestMove == '(none)' ? bestMove : lines.first.moves.first,
        mate: lines.first.mate,
        lines: lines,
        evidence: StockfishSearchEvidence(
          depth: snapshot.depth,
          nodes: snapshot.nodes,
          timeMs: snapshot.timeMs,
          complete: snapshots.completed != null,
          reset: reset,
          quality: request?.quality,
          previousLines:
              snapshots.previous?.lines
                  .map((line) => line.forWhite(blackToMove))
                  .toList(growable: false) ??
              const [],
        ),
      );
    } on AnalysisCancelled {
      // No search started, or bestmove already acknowledged the stop. The
      // engine is healthy; preemption can resume without a native restart.
      rethrow;
    } on TimeoutException {
      // Keep consuming output until stop is acknowledged. A dead native
      // process can also reject stop, so reset it on either failure path.
      try {
        engine.stdin = 'stop';
        await completer.future.timeout(drainTimeout);
      } catch (_) {
        await subscription.cancel();
        await _resetEngine();
      }
      rethrow;
    } catch (_) {
      await subscription.cancel();
      await _resetEngine();
      rethrow;
    } finally {
      _searching = false;
      await subscription.cancel();
    }
  }

  Future<void> _ready(StockfishEngineHandle engine) async {
    final ready = Completer<void>();
    ready.future.ignore();
    final subscription = engine.stdout.listen(
      (line) {
        if (line == 'readyok' && !ready.isCompleted) ready.complete();
      },
      onError: (Object error, StackTrace stack) {
        if (!ready.isCompleted) ready.completeError(error, stack);
      },
      onDone: () {
        if (!ready.isCompleted) {
          ready.completeError(StateError('Stockfish closed during reset'));
        }
      },
    );
    try {
      engine.stdin = 'isready';
      await ready.future.timeout(drainTimeout);
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> _resetEngine() async {
    _analysisSession = null;
    _startup = null;
    final engine = _engine;
    _engine = null;
    if (engine == null) return;
    try {
      await engine.dispose().timeout(const Duration(seconds: 6));
    } catch (error, stackTrace) {
      unawaited(AppDiagnostics.record('stockfish-reset', error, stackTrace));
    }
  }

  Future<void> close() =>
      _closing ??= _closeNow().whenComplete(() => _closing = null);

  Future<void> _closeNow() async {
    try {
      await _queue.suspend();
      final engine = _engine;
      _engine = null;
      if (engine != null) {
        await engine.dispose().timeout(const Duration(seconds: 6));
      }
    } finally {
      _startup = null;
      _analysisSession = null;
      _queue.resume();
    }
  }
}

class StockfishReview {
  const StockfishReview(
    this.evaluation,
    this.bestMove, {
    this.mate,
    this.lines = const [],
    this.evidence,
    this.confirmationLines = const [],
  });

  final int evaluation;
  final String bestMove;
  final int? mate;
  final List<StockfishLine> lines;
  final StockfishSearchEvidence? evidence;
  final List<StockfishLine> confirmationLines;

  StockfishReview confirmedAgainst(StockfishReview original) => StockfishReview(
    evaluation,
    bestMove,
    mate: mate,
    lines: lines,
    evidence: evidence,
    confirmationLines: original.lines,
  );

  double get whiteWinningChances {
    final value = mate == null
        ? evaluation.clamp(-1000, 1000)
        : (21 - min(10, mate!.abs())) * 100 * (mate! > 0 ? 1 : -1);
    return 2 / (1 + exp(-0.00368208 * value)) - 1;
  }

  double get whiteWinPercent => 50 + 50 * whiteWinningChances;
}

class StockfishLine {
  const StockfishLine({
    required this.evaluation,
    required this.moves,
    this.mate,
  });

  final int evaluation;
  final int? mate;
  final List<String> moves;

  StockfishLine forWhite(bool blackToMove) => StockfishLine(
    evaluation: blackToMove ? -evaluation : evaluation,
    mate: mate == null ? null : (blackToMove ? -mate! : mate),
    moves: moves,
  );
}

class _StockfishRequest {
  const _StockfishRequest(this.quality, this.session, this.verifyAnnotation);
  final GameAnalysisQuality? quality;
  final Object? session;
  final bool verifyAnnotation;
}

/// Search provenance stays in memory; full FEN/PV traces are test tooling only.
class StockfishSearchEvidence {
  const StockfishSearchEvidence({
    required this.depth,
    required this.nodes,
    required this.timeMs,
    required this.complete,
    required this.reset,
    required this.quality,
    this.previousLines = const [],
  });
  final int depth;
  final int? nodes;
  final int? timeMs;
  final bool complete;
  final bool reset;
  final GameAnalysisQuality? quality;
  final List<StockfishLine> previousLines;
}

class StockfishSnapshot {
  const StockfishSnapshot(this.depth, this.lines, this.nodes, this.timeMs);
  final int depth;
  final List<StockfishLine> lines;
  final int? nodes;
  final int? timeMs;
}

/// Keep exact, complete MultiPV iterations, never independently updated ranks.
/// Reordered ranks at one depth are accepted; a repeated rank starts a new set.
class StockfishSearchSnapshots {
  StockfishSearchSnapshots({required this.legalMoves});
  final Set<String> legalMoves;
  final Map<int, StockfishLine> _pending = {};
  int _depth = -1;
  StockfishSnapshot? completed;
  StockfishSnapshot? previous;
  StockfishSnapshot? primary;

  void add(String line) {
    if (!line.startsWith('info ')) return;
    int? number(String field) => int.tryParse(
      RegExp(' $field (-?\\d+)').firstMatch(line)?.group(1) ?? '',
    );
    final depth = number('depth');
    final rank = number('multipv') ?? 1;
    if (depth == null || depth < 1 || rank < 1 || rank > 2) return;
    if (depth < _depth) return;
    if (depth != _depth || _pending.containsKey(rank)) {
      _pending.clear();
      _depth = depth;
    }
    if (line.contains(' lowerbound') || line.contains(' upperbound')) {
      _pending.clear();
      return;
    }
    final cp = number('score cp');
    final mate = number('score mate');
    final moves = RegExp(r' pv (.+)$')
        .firstMatch(line)
        ?.group(1)
        ?.trim()
        .split(RegExp(r'\s+'));
    if ((cp == null && mate == null) ||
        moves == null ||
        moves.isEmpty ||
        !legalMoves.contains(moves.first) ||
        moves.any(
          (move) => !RegExp(r'^[a-h][1-8][a-h][1-8][qrbn]?$').hasMatch(move),
        )) {
      _pending.clear();
      return;
    }
    final value = StockfishLine(
      evaluation: cp ?? 0,
      mate: mate,
      moves: List.unmodifiable(moves),
    );
    if (rank == 1) {
      primary = StockfishSnapshot(
        depth,
        [value],
        number('nodes'),
        number('time'),
      );
    }
    _pending[rank] = value;
    final count = min(2, legalMoves.length);
    if (_pending.length != count || !_pending.containsKey(1)) return;
    final lines = [for (var i = 1; i <= count; i++) _pending[i]!];
    if (lines.map((line) => line.moves.first).toSet().length != count) {
      _pending.clear();
      return;
    }
    if (completed == null || depth >= completed!.depth) {
      if (completed != null && depth > completed!.depth) previous = completed;
      completed = StockfishSnapshot(
        depth,
        List.unmodifiable(lines),
        number('nodes'),
        number('time'),
      );
    }
    _pending.clear();
  }
}
