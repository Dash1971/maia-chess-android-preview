import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:chess/chess.dart' as chess;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:maia_chess/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/electronic_board.dart';

class ResetBoard extends SimulatedElectronicBoard {
  @override
  void status(ElectronicBoardConnectionState state) => controller.add(
    ElectronicBoardEvent(
      type: 'status',
      connectionState: state,
      connectionSession: 'reset-board-session',
      boardId: 'reset-board',
    ),
  );
  void newGame() => controller.add(
    const ElectronicBoardEvent(
      type: 'newGame',
      connectionSession: 'reset-board-session',
      boardId: 'reset-board',
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late ResetBoard board;
  late WidgetTester currentTester;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    board = ResetBoard();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(maiaEngineChannel, (_) async => null);
  });
  tearDown(() async {
    ActiveSessionStore.setTestRepository(null);
    await board.close();
    await currentTester.runAsync(() => directory.delete(recursive: true));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(maiaEngineChannel, null);
  });

  Future<void> flush(WidgetTester tester) async {
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  Future<void> initialize(WidgetTester tester) async {
    currentTester = tester;
    directory = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('maia-reset-widget-'),
    ))!;
    final repository = (await tester.runAsync(
      () async => SessionRepository(directory),
    ))!;
    ActiveSessionStore.setTestRepository(repository);
  }

  Future<void> launch(
    WidgetTester tester, {
    bool playerIsWhite = true,
    Future<Float32List> Function(List<String>, int)? evaluator,
  }) async {
    await initialize(tester);
    await tester.runAsync(
      () => ActiveSessionStore.save({
        'type': 'game',
        'pgn': '1. d4 d5 *',
        'playerIsWhite': true,
      }),
    );
    await tester.runAsync(() => ActiveSessionStore.startNew());
    await tester.runAsync(
      () => ActiveSessionStore.save({
        'type': 'game',
        'pgn': playerIsWhite ? '1. e4 e5 *' : '1. e4 *',
        'playerIsWhite': playerIsWhite,
        'elo': 1800,
        'maiaUseMoveHistory': true,
        'electronicBoard': 'chessnut-go',
        'clockPaused': true,
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(
          electronicBoardTransport: board,
          maiaEvaluator: evaluator,
        ),
      ),
    );
    await flush(tester);
    await tester.pumpAndSettle();
    board.status(ElectronicBoardConnectionState.ready);
    final position = chess.Chess()..move('e4');
    if (playerIsWhite) position.move('e5');
    board.position(position.fen);
    await flush(tester);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'first board press and Cancel preserve active and unrelated games',
    (tester) async {
      await launch(tester);
      final active = await tester.runAsync<Map<String, dynamic>?>(
        () => SessionRepository(directory).load(),
      );
      board.newGame();
      board.newGame();
      await flush(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('Press NEW GAME again'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        (await tester.runAsync<Map<String, dynamic>?>(
          () => SessionRepository(directory).load(),
        ))!['pgn'],
        active!['pgn'],
      );
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await flush(tester);
      await tester.pumpAndSettle();
      expect(
        (await tester.runAsync<Map<String, dynamic>?>(
          () => SessionRepository(directory).load(),
        ))!['pgn'],
        active['pgn'],
      );
      expect(
        await tester.runAsync(() => SessionRepository(directory).recent()),
        hasLength(2),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await flush(tester);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('phone confirmation discards only active game and guides setup', (
    tester,
  ) async {
    await launch(tester);
    await tester.tap(find.byKey(const ValueKey('new-game-button')));
    await flush(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await flush(tester);
    await tester.pumpAndSettle();
    expect(
      await tester.runAsync<Map<String, dynamic>?>(
        () => SessionRepository(directory).load(),
      ),
      containsPair('uciMoves', isEmpty),
    );
    final recent = (await tester.runAsync(
      () => SessionRepository(directory).recent(),
    ))!;
    expect(recent, hasLength(1));
    expect(
      recent.where((g) => g.data['pgn'].toString().contains('d4')),
      hasLength(1),
    );
    expect(board.leds.last.toSet(), {'e2', 'e4', 'e7', 'e5'});
    // Intermediate physical placements belong to setup and cannot create moves.
    final partial = chess.Chess()..move('e4');
    board.position(partial.fen);
    await flush(tester);
    await tester.pumpAndSettle();
    expect(
      await tester.runAsync<Map<String, dynamic>?>(
        () => SessionRepository(directory).load(),
      ),
      containsPair('uciMoves', isEmpty),
    );
    expect(board.leds.last.toSet(), {'e2', 'e4'});
    board.position(chess.Chess.DEFAULT_POSITION);
    await flush(tester);
    await tester.pumpAndSettle();
    expect(board.leds.last, isEmpty);
    expect(
      await tester.runAsync<Map<String, dynamic>?>(
        () => SessionRepository(directory).load(),
      ),
      containsPair('uciMoves', isEmpty),
    );
    expect(find.widgetWithText(FilledButton, 'Start game'), findsNothing);
    expect(find.byKey(const ValueKey('new-game-button')), findsOneWidget);
    final started = (await tester.runAsync<Map<String, dynamic>?>(
      () => SessionRepository(directory).load(),
    ))!;
    expect(started['chessnutResetPending'], isNull);
    expect(started['clockPaused'], false);
    await tester.pumpWidget(const SizedBox.shrink());
    await flush(tester);
    await tester.pumpAndSettle();
  });
  testWidgets('completed reset retains its result and unrelated archives', (
    tester,
  ) async {
    await initialize(tester);
    await tester.runAsync(
      () => ActiveSessionStore.save({
        'type': 'game',
        'pgn': '1. d4 d5 *',
        'playerIsWhite': true,
      }),
    );
    await tester.runAsync(() => ActiveSessionStore.startNew());
    await tester.runAsync(
      () => ActiveSessionStore.save({
        'type': 'game',
        'pgn': '1. f3 e5 2. g4 Qh4# 0-1',
        'recentState': 'completed',
        'playerIsWhite': true,
      }),
    );
    await tester.pumpWidget(
      MaterialApp(home: GamePage(electronicBoardTransport: board)),
    );
    await flush(tester);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await flush(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('new-game-button')));
    await flush(tester);
    await tester.pumpAndSettle();
    expect(
      find.text(
        (await AppLocalizations.delegate.load(const Locale('en')))
            .yourCompletedGameWillRemainInRecentGames,
      ),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Start new game'));
    await flush(tester);
    await tester.pumpAndSettle();
    final recent = (await tester.runAsync(
      () => SessionRepository(directory).recent(),
    ))!;
    expect(
      recent.where((game) => game.data['pgn'].toString().contains('Qh4#')),
      hasLength(1),
    );
    expect(
      recent.where((game) => game.data['pgn'].toString().contains('d4')),
      hasLength(1),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await flush(tester);
    await tester.pumpAndSettle();
  });

  testWidgets('reset rejects a delayed Maia completion and its LED guidance', (
    tester,
  ) async {
    await initialize(tester);
    final pending = Completer<Float32List>();
    var requests = 0;
    await tester.runAsync(
      () => ActiveSessionStore.save({
        'type': 'game',
        'pgn': '1. e4 *',
        'playerIsWhite': true,
        'electronicBoard': 'chessnut-go',
        'clockPaused': false,
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(
          electronicBoardTransport: board,
          maiaEvaluator: (_, _) {
            requests++;
            return pending.future;
          },
        ),
      ),
    );
    await flush(tester);
    await tester.pumpAndSettle();
    board.status(ElectronicBoardConnectionState.ready);
    final physical = chess.Chess()..move('e4');
    board.position(physical.fen);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    expect(requests, 1);
    await tester.tap(find.byKey(const ValueKey('new-game-button')));
    await flush(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await flush(tester);
    await tester.pumpAndSettle();
    final guidance = List<String>.of(board.leds.last);
    pending.complete(Float32List(4352));
    await flush(tester);
    await tester.pumpAndSettle();
    expect(
      await tester.runAsync<Map<String, dynamic>?>(
        () => SessionRepository(directory).load(),
      ),
      containsPair('uciMoves', isEmpty),
    );
    expect(board.leds.last, guidance);
    expect(requests, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await flush(tester);
    await tester.pumpAndSettle();
  });
  testWidgets(
    'completion while reset is open refreshes dialog and keeps result',
    (tester) async {
      await initialize(tester);
      await tester.runAsync(
        () => ActiveSessionStore.save({
          'type': 'game',
          'pgn': '1. f3 e5 2. g4 *',
          'playerIsWhite': false,
          'electronicBoard': 'chessnut-go',
          'clockPaused': false,
        }),
      );
      await tester.pumpWidget(
        MaterialApp(home: GamePage(electronicBoardTransport: board)),
      );
      await flush(tester);
      await tester.pumpAndSettle();
      board.status(ElectronicBoardConnectionState.ready);
      final physical = chess.Chess()
        ..move('f3')
        ..move('e5')
        ..move('g4');
      board.position(physical.fen);
      await flush(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('new-game-button')));
      await flush(tester);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Reset'), findsOneWidget);
      physical.move('Qh4#');
      board.position(physical.fen);
      await flush(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Start new game'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Start new game'));
      await flush(tester);
      await tester.pumpAndSettle();
      final recent = (await tester.runAsync(
        () => SessionRepository(directory).recent(),
      ))!;
      expect(
        recent.where((game) => game.data['pgn'].toString().contains('Qh4#')),
        hasLength(1),
      );
      // Completed-game archival and new-session persistence are asynchronous.
      // Wait for the committed checkpoint, not a fixed number of widget frames.
      Map<String, dynamic>? reset;
      for (var attempt = 0; attempt < 50; attempt++) {
        reset = await tester.runAsync<Map<String, dynamic>?>(() async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return SessionRepository(directory).load();
        });
        await tester.pump();
        if (reset?['chessnutResetPending'] == true) break;
      }
      expect(reset, isNotNull);
      expect(reset!['chessnutResetPending'], true);
      expect(reset['uciMoves'], isEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
      await flush(tester);
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'second deliberate hardware press confirms the existing dialog once',
    (tester) async {
      await launch(tester);
      board.newGame();
      await flush(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      board.newGame();
      board.newGame();
      await flush(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Start game'), findsNothing);
      expect(
        find.byKey(const ValueKey('chessnut-status-banner')),
        findsOneWidget,
      );
      expect(board.leds.last.toSet(), {'e2', 'e4', 'e7', 'e5'});
      expect(
        await tester.runAsync<Map<String, dynamic>?>(
          () => SessionRepository(directory).load(),
        ),
        containsPair('uciMoves', isEmpty),
      );
      final recent = (await tester.runAsync(
        () => SessionRepository(directory).recent(),
      ))!;
      expect(recent, hasLength(1));
      expect(
        recent.where((g) => g.data['pgn'].toString().contains('d4')),
        hasLength(1),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await flush(tester);
      await tester.pumpAndSettle();
    },
  );

  for (final playerIsWhite in [true, false]) {
    testWidgets(
      'reset keeps ${playerIsWhite ? "White" : "Black"}, rating and history; starts only after setup',
      (tester) async {
        // A contrary home preference must not change the restored player's side.
        SharedPreferences.setMockInitialValues({
          maiaPlaySidePreferenceKey: playerIsWhite ? 'black' : 'white',
        });
        var requests = 0;
        await launch(
          tester,
          playerIsWhite: playerIsWhite,
          evaluator: (_, _) async {
            requests++;
            return Float32List(4352);
          },
        );
        board.newGame();
        await flush(tester);
        await tester.pumpAndSettle();
        board.newGame();
        await flush(tester);
        await tester.pumpAndSettle();
        var saved = (await tester.runAsync<Map<String, dynamic>?>(
          () => SessionRepository(directory).load(),
        ))!;
        expect(saved['playerIsWhite'], playerIsWhite);
        expect(saved['elo'], 1800);
        expect(saved['maiaUseMoveHistory'], true);
        expect(saved['chessnutResetPending'], true);
        expect(saved['clockPaused'], true);
        expect(saved['timePreset'], 'unlimited');
        expect(requests, 0);
        expect(saved['uciMoves'], isEmpty);
        expect(find.widgetWithText(FilledButton, 'Start game'), findsNothing);
        board.position((chess.Chess()..move('e4')).fen);
        await flush(tester);
        expect(requests, 0);
        expect(board.leds.last.toSet(), {'e2', 'e4'});
        board.position(chess.Chess.DEFAULT_POSITION);
        await flush(tester);
        await tester.pumpAndSettle();
        saved = (await tester.runAsync<Map<String, dynamic>?>(
          () => SessionRepository(directory).load(),
        ))!;
        expect(saved['chessnutResetPending'], isNull);
        expect(saved['clockPaused'], false);
        expect(requests, playerIsWhite ? 0 : 1);
        expect(saved['uciMoves'], hasLength(playerIsWhite ? 0 : 1));
        // Duplicate board snapshots cannot start another inference or reset again.
        board.position(chess.Chess.DEFAULT_POSITION);
        await flush(tester);
        expect(requests, playerIsWhite ? 0 : 1);
        await tester.pumpWidget(const SizedBox.shrink());
        await flush(tester);
      },
    );
  }

  testWidgets(
    'reset waits across disconnect and background; phone fallback can continue',
    (tester) async {
      var requests = 0;
      await launch(
        tester,
        playerIsWhite: false,
        evaluator: (_, _) async {
          requests++;
          return Float32List(4352);
        },
      );
      board.newGame();
      await flush(tester);
      await tester.pumpAndSettle();
      board.newGame();
      await flush(tester);
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      board.position(chess.Chess.DEFAULT_POSITION);
      await flush(tester);
      expect(requests, 0);
      board.status(ElectronicBoardConnectionState.disconnected);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      board.status(ElectronicBoardConnectionState.ready);
      await flush(tester);
      expect(requests, 0); // Pre-disconnect match cannot start the game.
      board.status(ElectronicBoardConnectionState.disconnected);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('chessnut-play-in-app')));
      await flush(tester);
      await tester.pumpAndSettle();
      expect(requests, 1);
      final saved = (await tester.runAsync<Map<String, dynamic>?>(
        () => SessionRepository(directory).load(),
      ))!;
      expect(saved['electronicBoard'], isNull);
      expect(saved['chessnutResetPending'], isNull);
      expect(saved['playerIsWhite'], false);
      await tester.pumpWidget(const SizedBox.shrink());
      await flush(tester);
    },
  );

  testWidgets('saved reset resumes waiting after app restart', (tester) async {
    await initialize(tester);
    await tester.runAsync(
      () => ActiveSessionStore.save({
        'type': 'game', 'pgn': '*', 'playerIsWhite': false,
        'electronicBoard': 'chessnut-go', 'chessnutResetPending': true,
        'clockPaused':
            false, // Pending setup overrides even stale pause metadata.
      }),
    );
    var requests = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(
          electronicBoardTransport: board,
          maiaEvaluator: (_, _) async {
            requests++;
            return Float32List(4352);
          },
        ),
      ),
    );
    await flush(tester);
    await tester.pumpAndSettle();
    board.status(ElectronicBoardConnectionState.ready);
    board.position((chess.Chess()..move('e4')).fen);
    await flush(tester);
    expect(requests, 0);
    expect(board.leds.last.toSet(), {'e2', 'e4'});
    board.position(chess.Chess.DEFAULT_POSITION);
    await flush(tester);
    await tester.pumpAndSettle();
    expect(requests, 1);
    final saved = (await tester.runAsync<Map<String, dynamic>?>(
      () => SessionRepository(directory).load(),
    ))!;
    expect(saved['chessnutResetPending'], isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await flush(tester);
  });

  testWidgets(
    'a superseded setup snapshot cannot start Maia after a delayed LED write',
    (tester) async {
      var requests = 0;
      await launch(
        tester,
        playerIsWhite: false,
        evaluator: (_, _) async {
          requests++;
          return Float32List(4352);
        },
      );
      board.newGame();
      await flush(tester);
      await tester.pumpAndSettle();
      board.newGame();
      await flush(tester);
      await tester.pumpAndSettle();
      final write = Completer<void>();
      board.writeGate = write;
      board.position(chess.Chess.DEFAULT_POSITION);
      await tester.pump(const Duration(milliseconds: 10));
      // The pieces changed again while the write completing setup was outstanding.
      board.position((chess.Chess()..move('e4')).fen);
      write.complete();
      await flush(tester);
      expect(requests, 0);
      expect(board.leds.last.toSet(), {'e2', 'e4'});
      board.position(chess.Chess.DEFAULT_POSITION);
      await flush(tester);
      expect(requests, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await flush(tester);
    },
  );
}
