import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maia_chess/main.dart';
import 'package:maia_chess/board_image/recognition.dart' as vision;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native diagram classifier recovers from invalid input and releases sessions',
    (tester) async {
      expect(appFlavor, 'preview');
      await tester.runAsync(() async {
        const source = PlatformBoardImageSource();
        await expectLater(
          source.classifySquares(Float32List(1)),
          throwsA(
            isA<PlatformException>().having(
              (e) => e.code,
              'code',
              'invalid_image_input',
            ),
          ),
        );
        final input = Float32List.fromList(List.filled(64 * 32 * 32, .5));
        List<double>? first;
        for (var cycle = 0; cycle < 3; cycle++) {
          final logits = await source
              .classifySquares(input)
              .timeout(const Duration(seconds: 30));
          expect(logits, hasLength(64 * 13));
          expect(logits.every((n) => n.isFinite), isTrue);
          if (first != null) expect(logits, orderedEquals(first));
          first = logits;
          final decoded = vision.recognitionFromLogits(
            logits,
            const vision.BoardRect(0, 0, 256, 256),
          );
          expect(decoded.placement.split('/'), hasLength(8));
        }
      });
    },
  );
}
