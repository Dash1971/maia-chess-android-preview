import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:chessground/chessground.dart' as cg;
import 'package:crypto/crypto.dart';
import 'package:dartchess/dartchess.dart' as dc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:maia_chess/board_image/recognition.dart' as vision;
import 'package:maia_chess/l10n/app_localizations.dart';

Future<(Uint8List, int, int)> decodeFixture(String name) async {
  final codec = await ui.instantiateImageCodec(
    File('test/fixtures/board_image/$name.png').readAsBytesSync(),
  );
  try {
    final image = (await codec.getNextFrame()).image;
    try {
      final data = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      return (data.buffer.asUint8List(), image.width, image.height);
    } finally {
      image.dispose();
    }
  } finally {
    codec.dispose();
  }
}

class FakeImageSource implements BoardImageSource {
  Uint8List? bytes = File('test/fixtures/board_image/screen_chessnut.png')
      .readAsBytesSync();
  Object? failure;
  Object? cameraFailure;
  Uint8List? cameraBytes;
  Completer<Uint8List?>? cameraGate;
  int pickerCalls = 0, cameraCalls = 0;
  Completer<List<double>>? gate;
  Float32List? received;
  @override
  Future<Uint8List?> pickImage() async {
    pickerCalls++;
    return bytes;
  }

  @override
  Future<Uint8List?> takePhoto() async {
    cameraCalls++;
    if (cameraFailure case final error?) throw error;
    if (cameraGate case final wait?) return wait.future;
    return cameraBytes;
  }

  @override
  Future<List<double>> classifySquares(Float32List input) async {
    received = input;
    if (failure case final error?) throw error;
    if (gate case final wait?) return wait.future;
    final logits = List<double>.filled(64 * 13, -12);
    for (int i = 0; i < 64; i++) {
      logits[i * 13] = 12;
    }
    for (final entry in {4: 'k', 60: 'K', 18: 'Q'}.entries) {
      logits[entry.key * 13] = -12;
      logits[entry.key * 13 + vision.boardSquareClasses.indexOf(entry.value)] =
          12;
    }
    // A confident false queen on c6 models the analysis-arrow regression.
    return logits;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('bundled model, source pin and native contract match exact MIT artifact', () {
    final pin = jsonDecode(
      File('third_party/board_image/provenance.json').readAsStringSync(),
    ) as Map;
    final bytes = File('assets/models/board_squares.onnx').readAsBytesSync();
    expect(bytes.length, pin['model']['bytes']);
    expect(sha256.convert(bytes).toString(), pin['model']['sha256']);
    final native = File(
      'android/app/src/main/kotlin/com/dash1971/maia_chess/BoardImageBridge.kt',
    ).readAsStringSync();
    expect(native, contains(pin['model']['sha256'] as String));
  });
  test('grayscale uses premultiplied alpha over white paper', () {
    final gray = vision.GrayImage.fromRgba(
      Uint8List.fromList([0, 0, 0, 255, 0, 0, 0, 128, 0, 0, 0, 0]),
      3,
      1,
    );
    expect(gray.pixels, [0, 127, 255]);
  });
  for (final fixture in ['screen_chessnut', 'two_diagrams']) {
    testWidgets('grid detector and bounded tensors: $fixture', (tester) async {
      await tester.runAsync(() async {
        final (pixels, w, h) = await decodeFixture(fixture);
        final rect = vision.locateBoard(pixels, w, h)!;
        expect(rect.left, closeTo(fixture == 'screen_chessnut' ? 14 : 33, 2));
        expect(rect.top, closeTo(fixture == 'screen_chessnut' ? 14 : 7, 2));
        expect(
          rect.width,
          closeTo(fixture == 'screen_chessnut' ? 384 : 208, 3),
        );
        final input = vision.prepareSquares(pixels, w, h, rect);
        expect(input.length, 64 * 32 * 32);
        expect(input.every((n) => n.isFinite && n >= 0 && n <= 1), isTrue);
      });
    });
  }
  testWidgets('preprocessing matches the upstream training parity samples', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final parity = jsonDecode(
        File('test/fixtures/board_image/parity.json').readAsStringSync(),
      ) as List;
      for (final p in parity.where((e) => e['fixture'] == 'screen_chessnut')) {
        final (pixels, w, h) = await decodeFixture('screen_chessnut');
        final rect = (p['rect'] as List).cast<num>();
        final cell = Float32List(32 * 32);
        vision.cellInput(
          vision.GrayImage.fromRgba(pixels, w, h),
          rect[0].toDouble(),
          rect[1].toDouble(),
          rect[2].toDouble(),
          rect[3].toDouble(),
          cell,
          0,
        );
        expect(cell.reduce((a, b) => a + b), closeTo(p['sum'] as num, .001));
        for (final s in p['samples'] as List) {
          expect(cell[s[0] * 32 + s[1]], closeTo(s[2] as num, .000001));
        }
      }
    });
  });
  test(
    'manual selection chooses a smaller board instead of a competing board',
    () {
      const w = 320, h = 160;
      final pixels = Uint8List(w * h * 4);
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final i = (y * w + x) * 4;
          final tone = x < 160 ? 255 : 0;
          pixels.setRange(i, i + 4, [tone, tone, tone, 255]);
        }
      }
      final smaller = vision.prepareSquares(
        pixels,
        w,
        h,
        const vision.BoardRect(0, 0, 128, 128),
      );
      final other = vision.prepareSquares(
        pixels,
        w,
        h,
        const vision.BoardRect(176, 0, 128, 128),
      );
      expect(smaller.every((n) => n == 1), isTrue);
      expect(other.every((n) => n == 0), isTrue);
      expect(
        () => vision.prepareSquares(
          pixels,
          w,
          h,
          const vision.BoardRect(-1, 0, 128, 128),
        ),
        throwsFormatException,
      );
      expect(
        () => vision.prepareSquares(
          pixels,
          w,
          h,
          const vision.BoardRect(0, 0, 63, 128),
        ),
        throwsFormatException,
      );
    },
  );
  test('clockwise rotation preserves RGBA and explicit board orientation reverses all squares', () async {
    final input = Uint8List.fromList([1, 2, 3, 255, 4, 5, 6, 255]);
    final (rotated, w, h) = vision.rotateImage(input, 2, 1);
    expect([w, h], [1, 2]);
    expect(rotated, input);
    final logits = await FakeImageSource().classifySquares(
      Float32List(64 * 32 * 32),
    );
    final a = vision.recognitionFromLogits(
      logits,
      const vision.BoardRect(0, 0, 128, 128),
    );
    final b = vision.recognitionFromLogits(
      logits,
      const vision.BoardRect(0, 0, 128, 128),
      blackAtBottom: true,
    );
    expect(b.squares, a.squares.reversed.toList());
    expect(a.squares[18], 'Q');
    expect(a.confidence[18], greaterThan(.99));
    expect(
      () => vision.recognitionFromLogits([double.nan], a.rect),
      throwsFormatException,
    );
  });

  Widget app(
    Widget child, {
    Locale locale = const Locale('en'),
    double scale = 1,
  }) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: child,
  );
  void size(WidgetTester tester, Size value) {
    tester.view.physicalSize = value;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> work(WidgetTester tester, bool Function() done) async {
    for (int i = 0; i < 150; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      if (done()) {
        await tester.pump(const Duration(milliseconds: 400));
        return;
      }
    }
    fail('Image operation did not finish');
  }

  testWidgets(
    'cancelled picker and cancelled recognition preserve original editor',
    (tester) async {
      size(tester, const Size(390, 844));
      final source = FakeImageSource()..bytes = null;
      await tester.pumpWidget(
        app(
          BoardEditorPage(
            initialFen: dc.Chess.initial.fen,
            imageSource: source,
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('editor-from-image')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('image-choose')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<cg.ChessboardEditor>(find.byType(cg.ChessboardEditor))
            .pieces
            .length,
        32,
      );
      source.bytes = File('test/fixtures/board_image/screen_chessnut.png')
          .readAsBytesSync();
      source.gate = Completer<List<double>>();
      await tester.tap(find.byKey(const ValueKey('editor-from-image')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('image-choose')));
      await tester.pump();
      await work(
        tester,
        () =>
            find
                .byKey(const ValueKey('image-recognize'))
                .evaluate()
                .isNotEmpty &&
            tester
                    .widget<FilledButton>(
                      find.byKey(const ValueKey('image-recognize')),
                    )
                    .onPressed !=
                null,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('image-recognize')));
      await tester.tap(find.byKey(const ValueKey('image-recognize')));
      await tester.pump();
      await work(tester, () => source.received != null);
      await tester.pageBack();
      await tester.pumpAndSettle();
      source.gate!.complete(
        await FakeImageSource().classifySquares(Float32List(64 * 32 * 32)),
      );
      await work(tester, () => true);
      expect(find.byKey(const ValueKey('image-use-position')), findsNothing);
      expect(
        tester
            .widget<cg.ChessboardEditor>(find.byType(cg.ChessboardEditor))
            .pieces
            .length,
        32,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'recognized pieces stay editable and Done needs no acknowledgement',
    (tester) async {
      size(tester, const Size(390, 844));
      final source = FakeImageSource();
      await tester.pumpWidget(
        app(
          BoardEditorPage(
            initialFen: dc.Chess.initial.fen,
            imageSource: source,
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('editor-from-image')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('image-choose')));
      await tester.pump();
      await work(
        tester,
        () =>
            find
                .byKey(const ValueKey('image-recognize'))
                .evaluate()
                .isNotEmpty &&
            tester
                    .widget<FilledButton>(
                      find.byKey(const ValueKey('image-recognize')),
                    )
                    .onPressed !=
                null,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('image-recognize')));
      await tester.tap(find.byKey(const ValueKey('image-recognize')));
      await work(
        tester,
        () => find
            .byKey(const ValueKey('image-use-position'))
            .evaluate()
            .isNotEmpty,
      );
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const ValueKey('image-use-position')),
            )
            .onPressed,
        isNotNull,
      );
      expect(find.byType(CheckboxListTile), findsNothing);
      final editor = find.byType(cg.ChessboardEditor).last;
      expect(
        tester.widget<cg.ChessboardEditor>(editor).pieces[dc.Square.c6]?.role,
        dc.Role.queen,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('editor-erase-white')).last,
      );
      await tester.tap(find.byKey(const ValueKey('editor-erase-white')).last);
      await tester.pump();
      final square = find.byKey(const ValueKey('editor-square-c6')).last;
      await tester.ensureVisible(square);
      await tester.tapAt(tester.getCenter(square));
      await tester.pump();
      expect(
        tester.widget<cg.ChessboardEditor>(editor).pieces[dc.Square.c6],
        isNull,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('image-review-turn-black')),
      );
      await tester.tap(find.byKey(const ValueKey('image-review-turn-black')));
      await tester.pump();
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const ValueKey('image-use-position')),
            )
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byKey(const ValueKey('image-use-position')));
      await tester.pumpAndSettle();
      final applied = tester.widget<cg.ChessboardEditor>(
        find.byType(cg.ChessboardEditor),
      );
      expect(applied.pieces.length, 2);
      expect(applied.pieces[dc.Square.c6], isNull);
      expect(find.byKey(const ValueKey('image-crop')), findsNothing);
      expect(source.received!.length, 64 * 32 * 32);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'corrupt input and inference failure keep retry and original position',
    (tester) async {
      size(tester, const Size(390, 844));
      final source = FakeImageSource()..bytes = Uint8List.fromList([1, 2, 3]);
      await tester.pumpWidget(
        app(
          BoardEditorPage(
            initialFen: dc.Chess.initial.fen,
            imageSource: source,
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('editor-from-image')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('image-choose')));
      await tester.pump();
      await work(
        tester,
        () => find
            .byKey(const ValueKey('image-import-error'))
            .evaluate()
            .isNotEmpty,
      );
      source.bytes = File('test/fixtures/board_image/screen_chessnut.png')
          .readAsBytesSync();
      source.failure = StateError('Simulated runtime failure');
      await tester.tap(find.byKey(const ValueKey('image-choose')));
      await work(
        tester,
        () =>
            find
                .byKey(const ValueKey('image-recognize'))
                .evaluate()
                .isNotEmpty &&
            tester
                    .widget<FilledButton>(
                      find.byKey(const ValueKey('image-recognize')),
                    )
                    .onPressed !=
                null,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('image-recognize')));
      await tester.tap(find.byKey(const ValueKey('image-recognize')));
      await work(
        tester,
        () => find
            .byKey(const ValueKey('image-import-error'))
            .evaluate()
            .isNotEmpty,
      );
      expect(find.byKey(const ValueKey('image-use-position')), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<cg.ChessboardEditor>(find.byType(cg.ChessboardEditor))
            .pieces
            .length,
        32,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'camera choice, cancellation and unavailable-camera fallback preserve parent',
    (tester) async {
      size(tester, const Size(390, 844));
      final source = FakeImageSource();
      await tester.pumpWidget(
        app(
          BoardEditorPage(
            initialFen: dc.Chess.initial.fen,
            imageSource: source,
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('editor-from-image')));
      await tester.pumpAndSettle();
      expect(source.pickerCalls, 0);
      expect(source.cameraCalls, 0);
      await tester.tap(find.byKey(const ValueKey('image-camera')));
      await tester.pumpAndSettle();
      expect(source.cameraCalls, 1);
      expect(
        tester
            .widget<cg.ChessboardEditor>(find.byType(cg.ChessboardEditor))
            .pieces
            .length,
        32,
      );
      source.cameraFailure = PlatformException(
        code: 'image_camera_unavailable',
      );
      await tester.tap(find.byKey(const ValueKey('editor-from-image')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('image-camera')));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not open the camera. Choose an image instead.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('image-choose')));
      await tester.pump();
      await work(
        tester,
        () => find.byKey(const ValueKey('image-crop')).evaluate().isNotEmpty,
      );
      expect(source.pickerCalls, 1);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<cg.ChessboardEditor>(find.byType(cg.ChessboardEditor))
            .pieces
            .length,
        32,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'late camera output after leaving import cannot alter the original board',
    (tester) async {
      size(tester, const Size(390, 844));
      final source = FakeImageSource()..cameraGate = Completer<Uint8List?>();
      await tester.pumpWidget(
        app(
          BoardEditorPage(
            initialFen: dc.Chess.initial.fen,
            imageSource: source,
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('editor-from-image')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('image-camera')));
      await tester.pump();
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('image-camera')))
            .onPressed,
        isNull,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      source.cameraGate!.complete(source.bytes);
      await work(tester, () => true);
      expect(
        tester
            .widget<cg.ChessboardEditor>(find.byType(cg.ChessboardEditor))
            .pieces
            .length,
        32,
      );
      expect(find.byKey(const ValueKey('image-crop')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('captured image opens an editable position with Done available', (
    tester,
  ) async {
    size(tester, const Size(390, 844));
    final source = FakeImageSource();
    source.cameraBytes = source.bytes;
    await tester.pumpWidget(
      app(
        BoardEditorPage(initialFen: dc.Chess.initial.fen, imageSource: source),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('editor-from-image')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('image-camera')));
    await tester.pump();
    await work(
      tester,
      () => find.byKey(const ValueKey('image-crop')).evaluate().isNotEmpty,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('image-recognize')));
    await tester.tap(find.byKey(const ValueKey('image-recognize')));
    await tester.pump();
    await work(
      tester,
      () => find
          .byKey(const ValueKey('image-use-position'))
          .evaluate()
          .isNotEmpty,
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('image-use-position')))
          .onPressed,
      isNotNull,
    );
    expect(source.cameraCalls, 1);
    expect(source.pickerCalls, 0);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<cg.ChessboardEditor>(find.byType(cg.ChessboardEditor))
          .pieces
          .length,
      32,
    );
    expect(tester.takeException(), isNull);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'camera/image choices at 320px and 200% text: ${locale.languageCode}',
      (tester) async {
        size(tester, const Size(320, 568));
        final source = FakeImageSource();
        await tester.pumpWidget(
          app(BoardImageImportPage(source: source), locale: locale, scale: 2),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const ValueKey('image-choose')));
        await tester.ensureVisible(find.byKey(const ValueKey('image-camera')));
        expect(source.cameraCalls, 0);
        expect(source.pickerCalls, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'review controls at 320px and 200% text: ${locale.languageCode}',
      (tester) async {
        size(tester, const Size(320, 568));
        await tester.pumpWidget(
          app(
            BoardEditorPage(
              initialFen: '4k3/8/8/8/8/8/8/4K3 w - - 0 1',
              imageReview: true,
            ),
            locale: locale,
            scale: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('image-review-turn-white')),
          findsOneWidget,
        );
        expect(
          tester
              .widget<IconButton>(
                find.byKey(const ValueKey('image-use-position')),
              )
              .onPressed,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
