import 'dart:async';
import 'dart:io';

import 'package:chessground/chessground.dart' as cg;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:maia_chess/l10n/app_localizations.dart';

class FakeScanner extends BoardScanner {
  final pickResult = Completer<BoardScanImage?>();
  final reading = Completer<String>();
  final cameras = <bool>[];
  final discarded = <String>[];
  @override
  Future<BoardScanImage?> pick({required bool camera}) {
    cameras.add(camera);
    return pickResult.future;
  }

  @override
  Future<String> recognize(BoardScanImage image) => reading.future;
  @override
  Future<void> discard(BoardScanImage image) async =>
      discarded.add(image.token);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const original = '4k3/8/8/3pP3/8/8/8/4K3 b - d6 17 42';
  const recognized = '6r1/3k4/8/3KP3/8/8/7R/8';
  final preview = Uint8List.fromList(
    File('third_party/chessground/assets/piece_sets/cburnett/wK.webp')
        .readAsBytesSync(),
  );
  BoardScanImage photo() => BoardScanImage('one-image', preview);
  late FakeScanner scanner;
  String? clipboard;
  setUp(() {
    scanner = FakeScanner();
    clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = call.arguments['text'] as String;
          }
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(maiaEngineChannel, null);
  });

  Future<void> mount(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double scale = 1,
    Size size = const Size(390, 844),
  }) async {
    scanner = FakeScanner();
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: BoardEditorPage(initialFen: original, scanner: scanner),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> select(WidgetTester tester, {bool camera = false}) async {
    await tester.tap(find.byKey(const ValueKey('editor-camera')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(camera ? 'Take a photo' : 'Choose a photo'));
    await tester.pumpAndSettle();
  }

  Future<void> copyFen(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('editor-share')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy FEN'));
    await tester.pumpAndSettle();
    ScaffoldMessenger.of(tester.element(find.byType(BoardEditorPage)))
        .removeCurrentSnackBar();
    await tester.pumpAndSettle();
  }

  for (final camera in [false, true]) {
    testWidgets(
      'Lichess photo flow directly updates existing editor (camera=$camera)',
      (tester) async {
        await mount(tester);
        await select(tester, camera: camera);
        expect(scanner.cameras, [camera]);
        scanner.pickResult.complete(photo());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        expect(find.text('Reading the board…'), findsOneWidget);
        expect(find.text('Use image'), findsNothing);
        expect(find.text('I checked the position'), findsNothing);
        expect(
          tester
              .widget<IconButton>(find.byKey(const ValueKey('editor-camera')))
              .onPressed,
          isNull,
        );
        scanner.reading.complete(recognized);
        await tester.pumpAndSettle();
        expect(find.text('Board Editor'), findsOneWidget);
        expect(find.byType(cg.ChessboardEditor), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
        expect(scanner.discarded, ['one-image']);
        await copyFen(tester);
        expect(clipboard, '$recognized w - - 0 1');
      },
    );
  }

  for (final flipped in [false, true]) {
    testWidgets(
      'correct an upside-down scan without changing the view (flipped=$flipped)',
      (tester) async {
        await mount(tester);
        await select(tester);
        scanner.pickResult.complete(photo());
        await tester.pump();
        scanner.reading.complete(recognized);
        await tester.pumpAndSettle();
        if (flipped) {
          await tester.tap(find.byKey(const ValueKey('board-editor-flip')));
          await tester.pumpAndSettle();
        }
        await copyFen(tester);
        expect(
          clipboard,
          '$recognized w - - 0 1',
        ); // View flip does not repair placement.
        final orientation = tester
            .widget<cg.ChessboardEditor>(find.byType(cg.ChessboardEditor))
            .orientation;
        await tester.tap(find.byKey(const ValueKey('editor-menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('editor-menu-rotate')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<cg.ChessboardEditor>(find.byType(cg.ChessboardEditor))
              .orientation,
          orientation,
        );
        await copyFen(tester);
        expect(clipboard, '8/R7/8/8/3PK3/8/4k3/1r6 w - - 0 1');
        await tester.tap(find.byKey(const ValueKey('editor-menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('editor-menu-rotate')));
        await tester.pumpAndSettle();
        await copyFen(tester);
        expect(clipboard, '$recognized w - - 0 1');
      },
    );
  }

  for (final phase in ['pick', 'recognize']) {
    testWidgets(
      '$phase native failure leaves editor usable for an immediate retry',
      (tester) async {
        await mount(tester);
        var picks = 0, readings = 0, discards = 0;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(maiaEngineChannel, (call) async {
              switch (call.method) {
                case 'pickBoardScanImage':
                  picks++;
                  if (phase == 'pick' && picks == 1) {
                    throw PlatformException(code: 'scan_read_failed');
                  }
                  return {'token': 'retry-$picks', 'preview': preview};
                case 'recognizeBoardScanImage':
                  readings++;
                  if (phase == 'recognize' && readings == 1) {
                    throw PlatformException(code: 'scan_read_failed');
                  }
                  return {'placement': recognized};
                case 'discardBoardScanImage':
                  discards++;
              }
              return null;
            });
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BoardEditorPage(initialFen: original),
          ),
        );
        await tester.pumpAndSettle();
        await select(tester);
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        await copyFen(tester);
        expect(clipboard, original);
        ScaffoldMessenger.of(tester.element(find.byType(BoardEditorPage)))
            .removeCurrentSnackBar();
        await tester.pumpAndSettle();
        await select(tester);
        expect(find.byType(AlertDialog), findsNothing);
        expect(picks, 2);
        expect(discards, phase == 'pick' ? 1 : 2);
        await copyFen(tester);
        expect(clipboard, '$recognized w - - 0 1');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'closing choices and canceling picker preserve the complete FEN',
    (tester) async {
      await mount(tester);
      await tester.tap(find.byKey(const ValueKey('editor-camera')));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(scanner.cameras, isEmpty);
      await select(tester);
      scanner.pickResult.complete(null);
      await tester.pumpAndSettle();
      expect(scanner.discarded, isEmpty);
      await copyFen(tester);
      expect(clipboard, original);
    },
  );

  for (final failure in [
    'scan_no_board',
    'scan_too_large',
    'scan_picker_unavailable',
    'scan_read_failed',
  ]) {
    testWidgets(
      '$failure retains the original board and removes the progress route',
      (tester) async {
        await mount(tester);
        await select(tester);
        scanner.pickResult.complete(photo());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        scanner.reading.completeError(PlatformException(code: failure));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(scanner.discarded, ['one-image']);
        await copyFen(tester);
        expect(clipboard, original);
      },
    );
  }

  testWidgets('a malformed placement is atomic and remains editable', (
    tester,
  ) async {
    await mount(tester);
    await select(tester);
    scanner.pickResult.complete(photo());
    await tester.pump();
    scanner.reading.complete('not a FEN');
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await copyFen(tester);
    expect(clipboard, original);
  });

  testWidgets(
    'leaving while the external picker is open discards a late image',
    (tester) async {
      await mount(tester);
      await select(tester);
      await tester.pumpWidget(const MaterialApp(home: Text('Other screen')));
      scanner.pickResult.complete(photo());
      await tester.pumpAndSettle();
      expect(scanner.discarded, ['one-image']);
      expect(find.text('Other screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'platform bridge uses scoped token and rejects malformed model responses',
    (tester) async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(maiaEngineChannel, (call) async {
            calls.add(call);
            return switch (call.method) {
              'pickBoardScanImage' => {'token': 'selected', 'preview': preview},
              'recognizeBoardScanImage' => {'placement': 'not/a/board'},
              _ => null,
            };
          });
      const service = BoardScanner();
      final image = await service.pick(camera: true);
      expect(image!.token, 'selected');
      await expectLater(service.recognize(image), throwsFormatException);
      await service.discard(image);
      expect(calls.map((c) => c.method), [
        'pickBoardScanImage',
        'recognizeBoardScanImage',
        'discardBoardScanImage',
      ]);
      expect(calls[1].arguments, {'token': 'selected'});
    },
  );

  for (final locale in AppLocalizations.supportedLocales) {
    for (final size in [
      const Size(320, 740),
      const Size(844, 390),
      const Size(1024, 768),
    ]) {
      testWidgets(
        '${locale.languageCode} camera choices at $size with large text',
        (tester) async {
          await mount(tester, locale: locale, scale: 2, size: size);
          await tester.tap(find.byKey(const ValueKey('editor-camera')));
          await tester.pumpAndSettle();
          expect(find.byType(ListTile), findsNWidgets(2));
          expect(find.byType(Checkbox), findsNothing);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('editor-menu')));
          await tester.pumpAndSettle();
          final context = tester.element(
            find.byKey(const ValueKey('editor-menu-rotate')),
          );
          expect(
            find.text(AppLocalizations.of(context)!.editorRotatePosition),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
