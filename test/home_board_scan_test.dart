import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:chessground/chessground.dart' as cg;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';
import 'package:maia_chess/board_image/recognition.dart' as vision;
import 'package:maia_chess/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'board_image_import_test.dart' show FakeImageSource;
import 'fixtures/electronic_board.dart';

const scannedFen = '4k3/4p3/8/8/8/8/4P3/4K3 w - - 0 1';

class ScanSource extends FakeImageSource {
  @override
  Future<List<double>> classifySquares(Float32List input) async {
    received = input;
    if (failure case final error?) throw error;
    if (gate case final wait?) return wait.future;
    return logits();
  }

  List<double> logits() {
    final logits = List<double>.filled(64 * 13, -12);
    for (int i = 0; i < 64; i++) {
      logits[i * 13] = 12;
    }
    for (final entry in {4: 'k', 12: 'p', 52: 'P', 60: 'K'}.entries) {
      logits[entry.key * 13] = -12;
      logits[entry.key * 13 + vision.boardSquareClasses.indexOf(entry.value)] =
          12;
    }
    return logits;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final directory = Platform.environment['MAIA_FONT_DIR'];
    if (directory == null) return;
    for (final (family, path) in [
      ('Roboto', '$directory/Roboto-Regular.ttf'),
      ('Ahem', '$directory/Roboto-Regular.ttf'),
      ('MaterialIcons', '$directory/MaterialIcons-Regular.otf'),
      (
        'packages/cupertino_icons/CupertinoIcons',
        '$directory/CupertinoIcons.ttf',
      ),
      ('LichessIcons', 'assets/fonts/LichessIcons.ttf'),
    ]) {
      await (FontLoader(
        family,
      )..addFont(File(path).readAsBytes().then(ByteData.sublistView))).load();
    }
  });
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final captureKey = GlobalKey();
  late ScanSource source;
  late SimulatedElectronicBoard board;
  final enabled = appFlavor == 'preview' || appFlavor == 'dev';

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'analysisEnginesEnabledV1': false,
      maiaPlaySidePreferenceKey: PlayerSide.white.name,
    });
    MaiaInferenceQueue.resetForTesting();
    source = ScanSource()
      ..cameraBytes = File('test/fixtures/board_image/screen_chessnut.png')
          .readAsBytesSync();
    board = SimulatedElectronicBoard();
    messenger.setMockMethodCallHandler(maiaEngineChannel, (call) async {
      if (call.method == 'predict') return Float32List(4352);
      return null;
    });
  });
  tearDown(() async {
    messenger.setMockMethodCallHandler(maiaEngineChannel, null);
    await board.close();
  });

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
    fail('Scan did not reach expected state');
  }

  Future<void> screen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double scale = 1,
  }) async {
    tester.view.physicalSize = scale > 1
        ? const Size(320, 568)
        : const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepaintBoundary(
        key: captureKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorObservers: [maiaRouteObserver],
          theme: appTheme(const AppAppearance(), Brightness.dark),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: GamePage(
            boardImageSource: source,
            electronicBoardTransport: board,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Optional local evidence from the actual Flutter widgets, never golden files.
  Future<void> capture(WidgetTester tester, String name) async {
    final directory = Platform.environment['MAIA_SCAN_EVIDENCE'];
    if (directory == null) return;
    await tester.pump();
    final boundary =
        captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      var image = await boundary.toImage();
      if (name == 'scan-home') {
        final bounds = Rect.fromLTWH(0, 0, boundary.size.width, 630);
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawImageRect(image, bounds, bounds, Paint());
        final picture = recorder.endRecording();
        final cropped = await picture.toImage(
          bounds.width.round(),
          bounds.height.round(),
        );
        picture.dispose();
        image.dispose();
        image = cropped;
      }
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      image.dispose();
      File('$directory/$name.png').writeAsBytesSync(bytes.buffer.asUint8List());
    });
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final target = find.byKey(ValueKey(key));
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pump();
  }

  Future<void> scan(WidgetTester tester) async {
    await tapKey(tester, 'home-scan-board');
    await work(
      tester,
      () => find.byType(BoardEditorPage).evaluate().isNotEmpty,
    );
  }

  testWidgets('scan shortcut obeys Preview/Dev channel gates', (tester) async {
    await screen(tester);
    expect(
      find.byKey(const ValueKey('home-scan-board')),
      enabled ? findsOneWidget : findsNothing,
    );
    expect(source.cameraCalls, 0);
  });
  if (!enabled) return;

  testWidgets(
    'Home opens camera once, reads automatically and uses the normal editor and analysis',
    (tester) async {
      source.gate = Completer<List<double>>();
      await screen(tester);
      final analysis = tester.getRect(
        find.byKey(const ValueKey('home-analysis-board')),
      );
      final scanButton = tester.getRect(
        find.byKey(const ValueKey('home-scan-board')),
      );
      expect(scanButton.top, analysis.top);
      expect(scanButton.left, greaterThan(analysis.right));
      await capture(tester, 'scan-home');
      await tapKey(tester, 'home-scan-board');
      await work(tester, () => source.received != null);
      expect(source.cameraCalls, 1);
      expect(source.pickerCalls, 0);
      expect(find.byKey(const ValueKey('image-reading')), findsOneWidget);
      expect(find.byKey(const ValueKey('image-recognize')), findsNothing);
      await capture(tester, 'scan-reading');
      source.gate!.complete(source.logits());
      await work(
        tester,
        () => find.byType(BoardEditorPage).evaluate().isNotEmpty,
      );
      await tester.pumpAndSettle();
      expect(find.byType(BoardEditorPage), findsOneWidget);
      expect(find.byType(AnalysisBoardPage, skipOffstage: false), findsNothing);
      expect(find.byType(BoardImageImportPage), findsNothing);
      expect(find.byType(CheckboxListTile), findsNothing);
      expect(find.byKey(const ValueKey('editor-settings')), findsOneWidget);
      await capture(tester, 'scan-editor');
      await tapKey(tester, 'editor-settings');
      await tester.pumpAndSettle();
      await tapKey(tester, 'editor-turn-black');
      await tester.tap(find.widgetWithText(TextButton, 'Done'));
      await tester.pumpAndSettle();
      await tapKey(tester, 'editor-analyze');
      await tester.pumpAndSettle();
      expect(find.byType(AnalysisBoardPage), findsOneWidget);
      expect(tester.widget<ReviewPage>(find.byType(ReviewPage)).positions, [
        scannedFen.replaceFirst(' w ', ' b '),
      ]);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'cancelled camera or editor preserves the existing saved session',
    (tester) async {
      source.cameraGate = Completer<Uint8List?>();
      await screen(tester);
      await ActiveSessionStore.save({
        'type': 'analysis',
        'session': AnalysisSession.start().toJson(),
        'maiaElo': 1600,
      });
      final before = await ActiveSessionStore.load();
      await tapKey(tester, 'home-scan-board');
      await tester.pump(const Duration(milliseconds: 400));
      expect(source.cameraCalls, 1);
      source.cameraGate!.complete(null);
      await tester.pumpAndSettle();
      expect(find.byType(BoardEditorPage), findsNothing);
      expect(await ActiveSessionStore.load(), before);
      source.cameraGate = null;
      await scan(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(await ActiveSessionStore.load(), before);
      expect(find.byKey(const ValueKey('home-scan-board')), findsOneWidget);
    },
  );

  testWidgets('leaving automatic recognition ignores its late result', (
    tester,
  ) async {
    source.gate = Completer<List<double>>();
    await screen(tester);
    await tapKey(tester, 'home-scan-board');
    await work(tester, () => source.received != null);
    await tester.pageBack();
    await tester.pump(); // Still mounted in the reverse transition.
    source.gate!.complete(source.logits());
    await tester.pumpAndSettle();
    expect(find.byType(BoardEditorPage), findsNothing);
    expect(find.byKey(const ValueKey('home-scan-board')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'missing camera falls back to library and still opens the editor automatically',
    (tester) async {
      source.cameraFailure = PlatformException(
        code: 'image_camera_unavailable',
      );
      await screen(tester);
      await tapKey(tester, 'home-scan-board');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('image-import-error')), findsOneWidget);
      await tapKey(tester, 'image-choose');
      await work(
        tester,
        () => find.byType(BoardEditorPage).evaluate().isNotEmpty,
      );
      expect(source.cameraCalls, 1);
      expect(source.pickerCalls, 1);
      expect(tester.takeException(), isNull);
    },
  );

  Future<Uint8List> blankImage(WidgetTester tester) async {
    return (await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.white, BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(256, 256);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      image.dispose();
      picture.dispose();
      return bytes.buffer.asUint8List();
    }))!;
  }

  testWidgets(
    'no grid opens framing; drag, accessible edges, rotate and use photo work',
    (tester) async {
      source.cameraBytes = await blankImage(tester);
      await screen(tester);
      await tapKey(tester, 'home-scan-board');
      await work(
        tester,
        () => find.byKey(const ValueKey('image-crop')).evaluate().isNotEmpty,
      );
      expect(source.received, isNull);
      await capture(tester, 'scan-crop');
      await tester.drag(
        find.byKey(const ValueKey('image-crop-corner-0')),
        const Offset(25, 25),
      );
      await tester.pump();
      await tapKey(tester, 'image-adjust-edges');
      await tester.pumpAndSettle();
      final horizontal = tester.widget<RangeSlider>(
        find.byKey(const ValueKey('image-horizontal-crop')),
      );
      expect(horizontal.values.start, greaterThan(0));
      horizontal.onChanged!(const RangeValues(.2, .8));
      await tester.pump();
      await tapKey(tester, 'image-rotate');
      await work(
        tester,
        () => find.byKey(const ValueKey('image-crop')).evaluate().isNotEmpty,
      );
      await tapKey(tester, 'image-recognize');
      await work(
        tester,
        () => find.byType(BoardEditorPage).evaluate().isNotEmpty,
      );
      expect(
        tester
            .widget<cg.ChessboardEditor>(find.byType(cg.ChessboardEditor))
            .pieces
            .length,
        4,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'failed automatic inference keeps framing and permits retake without losing Home',
    (tester) async {
      source.failure = StateError('inference failure');
      await screen(tester);
      await tapKey(tester, 'home-scan-board');
      await work(
        tester,
        () => find
            .byKey(const ValueKey('image-import-error'))
            .evaluate()
            .isNotEmpty,
      );
      expect(find.byKey(const ValueKey('image-crop')), findsOneWidget);
      await capture(tester, 'scan-crop');
      source.failure = null;
      source.cameraBytes = null;
      await tapKey(tester, 'image-camera');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('image-crop')), findsOneWidget);
      await tapKey(tester, 'image-recognize');
      await work(
        tester,
        () => find.byType(BoardEditorPage).evaluate().isNotEmpty,
      );
      expect(source.cameraCalls, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'scanned editor reuses Continue from here and starts from the scanned FEN',
    (tester) async {
      await screen(tester);
      await scan(tester);
      await tapKey(tester, 'editor-menu');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue from here'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('continuation-use-board')),
        findsOneWidget,
      );
      await tapKey(tester, 'continuation-start-game');
      await tester.pumpAndSettle();
      final pages = tester.widgetList<GamePage>(find.byType(GamePage));
      expect(pages.last.startingFen, scannedFen);
      expect(
        ((await ActiveSessionStore.load())!['positions'] as List).first,
        scannedFen,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'scan Home and framing fit 320px/200% text: ${locale.languageCode}',
      (tester) async {
        source.cameraBytes = await blankImage(tester);
        await screen(tester, locale: locale, scale: 2);
        await tapKey(tester, 'home-scan-board');
        await work(
          tester,
          () => find.byKey(const ValueKey('image-crop')).evaluate().isNotEmpty,
        );
        await tester.ensureVisible(
          find.byKey(const ValueKey('image-recognize')),
        );
        expect(
          find.byKey(const ValueKey('image-recognize')).hitTestable(),
          findsOneWidget,
        );
        await tapKey(tester, 'image-adjust-edges');
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const ValueKey('image-vertical-crop')),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
