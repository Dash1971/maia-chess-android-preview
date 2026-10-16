import 'dart:io';
import 'dart:ui' as ui;

import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart' as dc;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';

const opening =
    'B21 · Sicilian Defense: Smith-Morra Gambit Accepted, Classical Formation';
const pgn =
    '1. e4 c5 2. d4 cxd4 3. c3 dxc3 4. Nxc3 Nc6 5. Nf3 d6 '
    '6. Bc4 a6 7. O-O Nf6 *';
final openingFinder = find.byKey(const ValueKey('review-opening-name'));

Widget review({double scale = 1, bool twoEngines = false}) {
  final session = AnalysisSession.fromPgn(pgn);
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff5d735f),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xff171a18),
      useMaterial3: true,
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: ReviewPage(
      title: 'Analysis Board',
      positions: session.positions,
      sanMoves: session.sanMoves,
      uciMoves: session.uciMoves,
      initialCurrentFen: session.positions.last,
      playerIsWhite: true,
      pgn: pgn,
      secondMaiaElo: twoEngines ? 2400 : null,
      onHome: () {},
      // Deterministic display fixtures; this test does not run chess engines.
      evaluator: (_) async => const StockfishReview(
        -30,
        'd1e2',
        lines: [
          StockfishLine(evaluation: -30, moves: ['d1e2', 'c8g4']),
          StockfishLine(evaluation: -40, moves: ['c1g5', 'e7e6']),
        ],
      ),
      maiaPolicyEvaluator: (_, _) async {
        final policy = List<double>.filled(4352, -20);
        policy[MaiaEncoding.moveIndex('d1e2', false)] = 3;
        policy[MaiaEncoding.moveIndex('c1g5', false)] = 2;
        return policy;
      },
    ),
  );
}

void main() {
  setUpAll(OpeningNames.load);

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 2.0]) {
      for (final twoEngines in [false, true]) {
        testWidgets(
          'full opening at $size, scale $scale, two engines $twoEngines',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final semantics = tester.ensureSemantics();
            try {
              await tester.pumpWidget(
                review(scale: scale, twoEngines: twoEngines),
              );
              await tester.pumpAndSettle();
              expect(find.text(opening), findsOneWidget);
              final rich = find.descendant(
                of: openingFinder,
                matching: find.byType(RichText),
              );
              final paragraph = tester.renderObject<RenderParagraph>(rich);
              expect(paragraph.didExceedMaxLines, isFalse);
              // The trailing variation must actually be laid out, not just present
              // in Text.data/semantics behind an ellipsis.
              final last = paragraph.getBoxesForSelection(
                const TextSelection(
                  baseOffset: opening.length - 1,
                  extentOffset: opening.length,
                ),
              );
              expect(last, isNotEmpty);
              expect(
                last.last.bottom,
                lessThanOrEqualTo(paragraph.size.height + 0.01),
              );
              expect(
                last.last.right,
                lessThanOrEqualTo(paragraph.size.width + 0.01),
              );
              expect(tester.getSemantics(openingFinder).label, opening);
              expect(
                find.byTooltip('Previous move').hitTestable(),
                findsOneWidget,
              );
              expect(find.byTooltip('Next move').hitTestable(), findsOneWidget);
              await tester.ensureVisible(
                find.byKey(const ValueKey('analysis-engine-lines')),
              );
              await tester.ensureVisible(
                find.byKey(const ValueKey('analysis-tab-panel')),
              );
              expect(
                find.byTooltip('Previous move').hitTestable(),
                findsOneWidget,
              );
              expect(tester.takeException(), isNull);
              await tester.pumpWidget(const SizedBox.shrink());
              await tester.pumpAndSettle();
            } finally {
              semantics.dispose();
            }
          },
        );
      }
    }
  }

  testWidgets('opening follows navigation into a new variation and back', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(review());
      await tester.pumpAndSettle();
      expect(find.text(opening), findsOneWidget);
      await tester.longPress(find.byTooltip('Previous move'));
      await tester.pumpAndSettle();
      expect(openingFinder, findsNothing);
      final board = tester.widget<cg.Chessboard>(find.byType(cg.Chessboard));
      board.onMove!(dc.NormalMove.fromUci('d2d4'));
      await tester.pumpAndSettle();
      final branchName = OpeningNames.identify(['d2d4'])!;
      expect(find.text(branchName), findsOneWidget);
      expect(tester.getSemantics(openingFinder).label, branchName);
      await tester.tap(find.byTooltip('Previous move'));
      await tester.pumpAndSettle();
      expect(openingFinder, findsNothing);
      await tester.longPress(find.byTooltip('Next move'));
      await tester.pumpAndSettle();
      expect(find.text(opening), findsOneWidget);
      expect(tester.getSemantics(openingFinder).label, opening);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    } finally {
      semantics.dispose();
    }
  });

  final output = Platform.environment['MAIA_OPENING_SCREENSHOTS'];
  if (output != null) {
    testWidgets('capture opening layout for review', (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final font = Platform.environment['MAIA_REPORT_FONT']!;
      final fonts = {
        'Roboto': Future.value(
          ByteData.sublistView(File(font).readAsBytesSync()),
        ),
        'MaterialIcons': rootBundle.load('fonts/MaterialIcons-Regular.otf'),
        'LichessIcons': rootBundle.load('assets/fonts/LichessIcons.ttf'),
        'packages/cupertino_icons/CupertinoIcons': rootBundle.load(
          'packages/cupertino_icons/assets/CupertinoIcons.ttf',
        ),
      };
      for (final entry in fonts.entries) {
        final loader = FontLoader(entry.key)..addFont(entry.value);
        await tester.runAsync(loader.load);
      }
      for (final entry in {
        'portrait': (const Size(390, 844), 1.0),
        'large-text': (const Size(320, 568), 2.0),
        'landscape': (const Size(844, 390), 1.0),
      }.entries) {
        tester.view.physicalSize = entry.value.$1;
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: review(scale: entry.value.$2, twoEngines: true),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory(output).create(recursive: true);
          await File('$output/${entry.key}.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    });
  }
}
