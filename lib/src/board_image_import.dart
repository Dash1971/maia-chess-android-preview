part of '../main.dart';

abstract interface class BoardImageSource {
  Future<Uint8List?> pickImage();
  Future<Uint8List?> takePhoto();
  Future<List<double>> classifySquares(Float32List input);
}

class PlatformBoardImageSource implements BoardImageSource {
  const PlatformBoardImageSource();
  static const channel = MethodChannel('maia_chess/board_image');
  Future<T> _trace<T>(String operation, Future<T> Function() run) async {
    DevDiagnostics.record('image.$operation.start');
    try {
      final result = await run();
      DevDiagnostics.record('image.$operation.complete', {
        'state': result == null ? 'cancelled' : 'completed',
      });
      return result;
    } catch (error) {
      DevDiagnostics.record('image.$operation.failed', {
        'state': error is PlatformException ? error.code : 'error',
      });
      rethrow;
    }
  }

  @override
  Future<Uint8List?> pickImage() =>
      _trace('picker', () => channel.invokeMethod<Uint8List>('pickImage'));
  @override
  Future<Uint8List?> takePhoto() =>
      _trace('camera', () => channel.invokeMethod<Uint8List>('takePhoto'));
  @override
  Future<List<double>> classifySquares(Float32List input) async {
    final result = await _trace(
      'recognition',
      () => channel.invokeMethod<Object>('classifySquares', {'input': input}),
    );
    if (result is Float32List) return result;
    if (result is List) {
      return result.cast<num>().map((n) => n.toDouble()).toList();
    }
    throw const FormatException('Invalid recognition output');
  }
}

/// Temporary crop/recognition route; the caller's editor is changed only by a
/// complete, reviewed FEN. Images and unconfirmed placements are never saved.
class BoardImageImportPage extends StatefulWidget {
  const BoardImageImportPage({
    this.source = const PlatformBoardImageSource(),
    super.key,
  });
  final BoardImageSource source;
  @override
  State<BoardImageImportPage> createState() => _BoardImageImportPageState();
}

class _BoardImageImportPageState extends State<BoardImageImportPage> {
  ui.Image? _image;
  Uint8List? _rgba;
  Rect _crop = const Rect.fromLTWH(0, 0, 1, 1);
  bool _busy = false,
      _blackAtBottom = false,
      _notFound = false,
      _failed = false,
      _cameraUnavailable = false;
  Offset? _anchor;

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  Future<void> _choose({bool camera = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
      _cameraUnavailable = false;
    });
    try {
      final bytes = await (camera
          ? widget.source.takePhoto()
          : widget.source.pickImage());
      if (!mounted) return;
      if (bytes == null) {
        if (_image == null) Navigator.pop(context);
        return;
      }
      if (bytes.length > 16 * 1024 * 1024) {
        throw const FormatException('Image too large');
      }
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      ui.Image image;
      try {
        final descriptor = await ui.ImageDescriptor.encoded(buffer);
        try {
          if (descriptor.width < 64 ||
              descriptor.height < 64 ||
              descriptor.width > 1536 ||
              descriptor.height > 1536) {
            throw const FormatException('Unsupported image dimensions');
          }
          final codec = await descriptor.instantiateCodec();
          try {
            image = (await codec.getNextFrame()).image;
          } finally {
            codec.dispose();
          }
        } finally {
          descriptor.dispose();
        }
      } finally {
        buffer.dispose();
      }
      ByteData? pixels;
      try {
        pixels = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      } catch (_) {
        image.dispose();
        rethrow;
      }
      if (!mounted || pixels == null) {
        image.dispose();
        return;
      }
      _image?.dispose();
      _image = image;
      _rgba = pixels.buffer.asUint8List();
      _crop = const Rect.fromLTWH(0, 0, 1, 1);
      _blackAtBottom = false;
      _notFound = true;
      await _detect();
    } catch (error) {
      if (mounted) {
        setState(() {
          _failed = true;
          _cameraUnavailable =
              error is PlatformException &&
              error.code == 'image_camera_unavailable';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _detect() async {
    final pixels = _rgba!;
    final w = _image!.width, h = _image!.height;
    final result = await vision.locateInBackground(pixels, w, h);
    DevDiagnostics.record('image.locate', {
      'state': result == null ? 'manual-crop' : 'located',
    });
    if (!mounted) return;
    setState(() {
      _notFound = result == null;
      _crop = result == null
          ? Rect.fromLTWH(0, 0, 1, 1)
          : Rect.fromLTRB(
              (result.left / w).clamp(0, 1),
              (result.top / h).clamp(0, 1),
              (result.right / w).clamp(0, 1),
              (result.bottom / h).clamp(0, 1),
            );
    });
  }

  Future<void> _find() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await _detect();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rotate() async {
    final pixels = _rgba!;
    final w = _image!.width, h = _image!.height;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final (rotated, rw, rh) = await vision.rotateInBackground(pixels, w, h);
      final buffer = await ui.ImmutableBuffer.fromUint8List(rotated);
      ui.Image image;
      try {
        final descriptor = ui.ImageDescriptor.raw(
          buffer,
          width: rw,
          height: rh,
          pixelFormat: ui.PixelFormat.rgba8888,
        );
        try {
          final codec = await descriptor.instantiateCodec();
          try {
            image = (await codec.getNextFrame()).image;
          } finally {
            codec.dispose();
          }
        } finally {
          descriptor.dispose();
        }
      } finally {
        buffer.dispose();
      }
      if (!mounted) {
        image.dispose();
        return;
      }
      _image?.dispose();
      _image = image;
      _rgba = rotated;
      await _detect();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recognize() async {
    final pixels = _rgba!;
    final w = _image!.width, h = _image!.height;
    final rect = vision.BoardRect(
      _crop.left * w,
      _crop.top * h,
      _crop.width * w,
      _crop.height * h,
    );
    final blackAtBottom = _blackAtBottom;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final input = await vision.prepareInBackground(pixels, w, h, rect);
      if (!mounted) return;
      final logits = await widget.source.classifySquares(input);
      if (!mounted) return;
      final result = vision.recognitionFromLogits(
        logits,
        rect,
        blackAtBottom: blackAtBottom,
      );
      final confirmed = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => BoardEditorPage(
            initialFen: '${result.placement} w - - 0 1',
            imageReview: true,
          ),
        ),
      );
      if (mounted && confirmed != null) Navigator.pop(context, confirmed);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = l10n(context);
    final image = _image;
    return Scaffold(
      appBar: AppBar(title: Text(t.imageFromImage)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.imageImportHelp),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('image-choose'),
                    onPressed: _busy ? null : () => _choose(),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      image == null ? t.imageChoose : t.imageChooseAnother,
                    ),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('image-camera'),
                    onPressed: _busy ? null : () => _choose(camera: true),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(t.imageTakePhoto),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(t.imageCameraHelp),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: LinearProgressIndicator(),
                ),
              if (_failed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _cameraUnavailable
                        ? t.imageCameraUnavailable
                        : t.imageImportFailed,
                    key: const ValueKey('image-import-error'),
                  ),
                ),
              if (_notFound && image != null) Text(t.imageBoardNotFound),
              if (image != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  label: t.imageImportHelp,
                  image: true,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * .55,
                    ),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: image.width / image.height,
                        child: LayoutBuilder(
                          builder: (_, box) {
                            Offset unit(Offset p) => Offset(
                              (p.dx / box.maxWidth).clamp(0, 1),
                              (p.dy / box.maxHeight).clamp(0, 1),
                            );
                            return GestureDetector(
                              key: const ValueKey('image-crop'),
                              onPanStart: _busy
                                  ? null
                                  : (e) => _anchor = unit(e.localPosition),
                              onPanUpdate: _busy
                                  ? null
                                  : (e) {
                                      final anchor = _anchor;
                                      if (anchor == null) return;
                                      setState(
                                        () => _crop = Rect.fromPoints(
                                          anchor,
                                          unit(e.localPosition),
                                        ),
                                      );
                                    },
                              child: CustomPaint(
                                painter: _ImageCropPainter(image, _crop),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Text(t.imageCropHorizontal),
                RangeSlider(
                  key: const ValueKey('image-horizontal-crop'),
                  values: RangeValues(_crop.left, _crop.right),
                  labels: RangeLabels(
                    '${(_crop.left * 100).round()}%',
                    '${(_crop.right * 100).round()}%',
                  ),
                  onChanged: _busy
                      ? null
                      : (v) => setState(
                          () => _crop = Rect.fromLTRB(
                            v.start,
                            _crop.top,
                            v.end,
                            _crop.bottom,
                          ),
                        ),
                ),
                Text(t.imageCropVertical),
                RangeSlider(
                  key: const ValueKey('image-vertical-crop'),
                  values: RangeValues(_crop.top, _crop.bottom),
                  labels: RangeLabels(
                    '${(_crop.top * 100).round()}%',
                    '${(_crop.bottom * 100).round()}%',
                  ),
                  onChanged: _busy
                      ? null
                      : (v) => setState(
                          () => _crop = Rect.fromLTRB(
                            _crop.left,
                            v.start,
                            _crop.right,
                            v.end,
                          ),
                        ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: _busy ? null : _find,
                      icon: const Icon(Icons.grid_on),
                      label: Text(t.imageFindBoard),
                    ),
                    TextButton.icon(
                      key: const ValueKey('image-rotate'),
                      onPressed: _busy ? null : _rotate,
                      icon: const Icon(Icons.rotate_right),
                      label: Text(t.imageRotate),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: Text(t.imageBlackAtBottom),
                  value: _blackAtBottom,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() => _blackAtBottom = v),
                ),
                FilledButton(
                  key: const ValueKey('image-recognize'),
                  onPressed:
                      _busy ||
                          _crop.width * image.width < 64 ||
                          _crop.height * image.height < 64
                      ? null
                      : _recognize,
                  child: Text(t.imageRecognize),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageCropPainter extends CustomPainter {
  _ImageCropPainter(this.image, this.crop);
  final ui.Image image;
  final Rect crop;
  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: image,
      fit: BoxFit.fill,
    );
    final rect = Rect.fromLTRB(
      crop.left * size.width,
      crop.top * size.height,
      crop.right * size.width,
      crop.bottom * size.height,
    );
    final shade = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRect(rect);
    canvas.drawPath(shade, Paint()..color = Colors.black54);
    final pen = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, pen);
    for (int i = 1; i < 8; i++) {
      canvas.drawLine(
        Offset(rect.left + i * rect.width / 8, rect.top),
        Offset(rect.left + i * rect.width / 8, rect.bottom),
        pen,
      );
      canvas.drawLine(
        Offset(rect.left, rect.top + i * rect.height / 8),
        Offset(rect.right, rect.top + i * rect.height / 8),
        pen,
      );
    }
  }

  @override
  bool shouldRepaint(_ImageCropPainter old) =>
      old.image != image || old.crop != crop;
}
