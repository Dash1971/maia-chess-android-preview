part of '../main.dart';

/// Android owns the scoped source file; Dart receives only a small JPEG preview.
class BoardScanImage {
  const BoardScanImage(this.token, this.preview);
  final String token;
  final Uint8List preview;
}

class BoardScanner {
  const BoardScanner();

  Future<BoardScanImage?> pick({required bool camera}) async {
    final value = await maiaEngineChannel.invokeMapMethod<String, dynamic>(
      'pickBoardScanImage',
      {'camera': camera},
    );
    if (value == null) return null;
    final token = value['token'];
    final preview = value['preview'];
    if (token is! String ||
        preview is! Uint8List ||
        preview.length > 512 * 1024) {
      throw const FormatException('Invalid scanner image response');
    }
    return BoardScanImage(token, preview);
  }

  Future<String> recognize(BoardScanImage image) async {
    final value = await maiaEngineChannel.invokeMapMethod<String, dynamic>(
      'recognizeBoardScanImage',
      {'token': image.token},
    );
    final placement = value?['placement'];
    if (placement is! String || placement.contains(' ')) {
      throw const FormatException('Invalid scanner placement');
    }
    // Parse as an editable draft, permitting missing/extra kings for correction.
    BoardEditorDraft('$placement w - - 0 1');
    return placement;
  }

  Future<void> discard(BoardScanImage image) async {
    try {
      await maiaEngineChannel.invokeMethod<void>('discardBoardScanImage', {
        'token': image.token,
      });
    } on PlatformException {
      // Native finally/next startup also removes task-owned images.
    } on MissingPluginException {
      // A disposed platform engine has no image left for this Dart screen.
    }
  }
}
