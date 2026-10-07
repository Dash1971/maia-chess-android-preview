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

  Future<void> launch(WidgetTester tester) async {
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
        'pgn': '1. e4 e5 *',
        'playerIsWhite': true,
        'electronicBoard': 'chessnut-go',
        'clockPaused': true,
      }),
    );
    await tester.pumpWidget(
      MaterialApp(home: GamePage(electronicBoardTransport: board)),
    );
    await flush(tester);
    await tester.pumpAndSettle();
    board.status(ElectronicBoardConnectionState.ready);
    final position = chess.Chess()
      ..move('e4')
      ..move('e5');
    board.position(position.fen);
    await flush(tester);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'first board press and Cancel preserve active and unrelated games',
    (tester) async {
      await launch(tester);
      final active = await tester.runAsync(
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
        (await tester.runAsync(
          () => SessionRepository(directory).load(),
        ))!['pgn'],
        active!['pgn'],
      );
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await flush(tester);
      await tester.pumpAndSettle();
      expect(
        (await tester.runAsync(
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
      await tester.runAsync(() => SessionRepository(directory).load()),
      isNull,
    );
    final recent = (await tester.runAsync(
      () => SessionRepository(directory).recent(),
    ))!;
    expect(recent, hasLength(1));
    expect(recent.single.data['pgn'], contains('d4'));
    expect(board.leds.last.toSet(), {'e2', 'e4', 'e7', 'e5'});
    // Intermediate physical placements belong to setup and cannot create moves.
    final partial = chess.Chess()..move('e4');
    board.position(partial.fen);
    await flush(tester);
    await tester.pumpAndSettle();
    expect(
      await tester.runAsync(() => SessionRepository(directory).load()),
      isNull,
    );
    expect(board.leds.last.toSet(), {'e2', 'e4'});
    board.position(chess.Chess.DEFAULT_POSITION);
    await flush(tester);
    await tester.pumpAndSettle();
    expect(board.leds.last, isEmpty);
    expect(
      await tester.runAsync(() => SessionRepository(directory).load()),
      isNull,
    );
    expect(find.widgetWithText(FilledButton, 'Start game'), findsOneWidget);
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
      await tester.runAsync(() => SessionRepository(directory).load()),
      isNull,
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
      expect(
        await tester.runAsync(() => SessionRepository(directory).load()),
        isNull,
      );
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
      expect(
        await tester.runAsync(() => SessionRepository(directory).load()),
        isNull,
      );
      final recent = (await tester.runAsync(
        () => SessionRepository(directory).recent(),
      ))!;
      expect(recent, hasLength(1));
      expect(recent.single.data['pgn'], contains('d4'));
      await tester.pumpWidget(const SizedBox.shrink());
      await flush(tester);
      await tester.pumpAndSettle();
    },
  );
}
