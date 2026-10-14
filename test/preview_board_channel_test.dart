import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'board_connection_widget_test.dart' show DiscoveryBoard;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('only Dev permits prototype board adapters', () {
    for (final flavor in ['preview', 'stable', '', null]) {
      expect(BoardChannelPolicy.supports(flavor, BoardKind.chessnut), isTrue);
      expect(BoardChannelPolicy.supports(flavor, BoardKind.pegasus), isFalse);
      expect(BoardChannelPolicy.supports(flavor, BoardKind.squareOff), isFalse);
    }
    for (final kind in BoardKind.values) {
      expect(BoardChannelPolicy.supports('dev', kind), isTrue);
    }
  });
  testWidgets(
    'Preview filters prototype candidates and rejects their ready events',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final board = DiscoveryBoard();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(maiaEngineChannel, (_) async => null);
      addTearDown(() async {
        await board.controller.close();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(maiaEngineChannel, null);
      });
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            electronicBoardTransport: board,
            maiaEvaluator: (_, _) async => Float32List(4352),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final toggle = find.byKey(const ValueKey('home-chessnut-toggle'));
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      board.candidates();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('board-candidate-board-one')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('board-candidate-board-two')),
        findsNothing,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      board.controller.add(
        const ElectronicBoardEvent(
          type: 'status',
          connectionState: ElectronicBoardConnectionState.ready,
          boardKind: BoardKind.chessnut,
          boardId: 'chessnut-go',
          connectionSession: 'preview-chessnut',
          deviceName: 'Chessnut Go',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chessnut Go connected'), findsOneWidget);
      for (final kind in [BoardKind.pegasus, BoardKind.squareOff]) {
        board.status(kind);
        await tester.pumpAndSettle();
        expect(find.text('Confirm board setup'), findsNothing);
        expect(board.starts, isEmpty);
        expect(board.motorMoves, isEmpty);
        expect(find.text('Chessnut Go connected'), findsOneWidget);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
    skip: appFlavor != 'preview',
  );
}
