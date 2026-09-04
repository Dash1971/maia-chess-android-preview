import 'package:chess/chess.dart' as chess;
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';

void main() {
  test('move vocabulary matches Maia-3 ordering', () {
    expect(MaiaEncoding.moveIndex('e2e4', false), 796);
    expect(MaiaEncoding.moveIndex('e7e5', true), 796);
    expect(MaiaEncoding.moveIndex('a7a8q', false), 4096);
    expect(MaiaEncoding.moveIndex('h7h8n', false), 4351);
  });

  test('tokenization mirrors the side-to-move perspective', () {
    const whiteFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
    const blackFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1';
    final white = MaiaEncoding.tokenizeFen(whiteFen);
    final black = MaiaEncoding.tokenizeFen(blackFen);
    expect(white[3], 1); // White rook on a1.
    expect(white[56 * 12 + 9], 1); // Black rook on a8.
    expect(black[3], 1); // Black-to-move is mirrored and colours are swapped.
    expect(black[56 * 12 + 9], 1);
  });

  test('historical tensor has the exported model shape', () {
    const fen = '8/8/8/8/8/8/8/K6k w - - 0 1';
    expect(MaiaEncoding.historicalTokens([fen]), hasLength(64 * 97));
  });

  test(
    'short history repeats earliest board and keeps ponder channel zero',
    () {
      final game = chess.Chess();
      final earliest = game.fen;
      expect(game.move('e4'), isTrue);
      final tokens = MaiaEncoding.historicalTokens([earliest, game.fen]);
      const e2 = 12;
      const e5 = 36;

      // Maia-3's reference get_historical_tokens left-pads with the earliest
      // board. The final channel is clk_ponder / 100, which is zero because the
      // mobile model is not supplied clock metadata.
      expect(tokens[e2 * 97], 1);
      expect(tokens[e2 * 97 + 72], 1);
      // After 1.e4 Black is to move, so that latest board is mirrored: the
      // moved pawn is represented as an opposing pawn on e5 (channel 90).
      expect(tokens[e5 * 97 + 6], 0);
      expect(tokens[e5 * 97 + 90], 1);
      for (var square = 0; square < 64; square++) {
        expect(tokens[square * 97 + 96], 0);
      }
    },
  );

  test('top-p sampling keeps only the highest probability moves', () {
    final game = chess.Chess();
    final legalMoves = game.moves({'asObjects': true}).cast<chess.Move>();
    final logits = List<double>.filled(4352, -20);
    logits[MaiaEncoding.moveIndex('e2e4', false)] = 20;
    final move = MaiaEncoding.sampleLegalMove(
      game,
      legalMoves,
      logits,
      temperature: 0.5,
      topP: 0.5,
    );
    expect(MaiaEncoding.uci(move), 'e2e4');
  });

  test('zero temperature uses deterministic argmax', () {
    final game = chess.Chess();
    final legalMoves = game.moves({'asObjects': true}).cast<chess.Move>();
    final logits = List<double>.filled(4352, -1);
    logits[MaiaEncoding.moveIndex('d2d4', false)] = 3;
    final move = MaiaEncoding.sampleLegalMove(
      game,
      legalMoves,
      logits,
      temperature: 0,
      topP: 0,
    );
    expect(MaiaEncoding.uci(move), 'd2d4');
  });
}
