part of '../main.dart';

abstract interface class BoardImageSource {
  Future<Uint8List?> pickImage();
  Future<Uint8List?> takePhoto();
  Future<List<double>> classifySquares(Float32List input);
}

class PlatformBoardImageSource implements BoardImageSource {
  const PlatformBoardImageSource();
  static const channel = MethodChannel('maia_chess/board_image');
  @override
  Future<Uint8List?> pickImage() =>
      channel.invokeMethod<Uint8List>('pickImage');
  @override
  Future<Uint8List?> takePhoto() =>
      channel.invokeMethod<Uint8List>('takePhoto');
  @override
  Future<List<double>> classifySquares(Float32List input) async {
    final result = await channel.invokeMethod<Object>('classifySquares', {
      'input': input,
    });
    if (result is Float32List) return result;
    if (result is List) {
      return result.cast<num>().map((n) => n.toDouble()).toList();
    }
    throw const FormatException('Invalid recognition output');
  }
}

/// Temporary crop/recognition route returning a placement to the existing editor.
/// Cancelled operations leave that editor unchanged; images are not saved.
class BoardImageImportPage extends StatefulWidget {
  const BoardImageImportPage({
    this.source = const PlatformBoardImageSource(),
    this.startWithCamera = false,
    super.key,
  });
  final BoardImageSource source;
  // Home goes straight to the installed camera and automatically reads a found
  // grid. The editor entry retains manual framing/orientation for either source.
  final bool startWithCamera;
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
  @override
  void initState() {
    super.initState();
    if (widget.startWithCamera) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isCurrentRoute) unawaited(_choose(camera: true));
      });
    }
  }

  // A popped route stays mounted during its exit animation. Its async result
  // must not pop the editor now underneath it or mutate a cancelled import.
  bool get _isCurrentRoute => ModalRoute.of(context)?.isCurrent == true;

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
      if (!mounted || !_isCurrentRoute) return;
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
      if (!mounted || !_isCurrentRoute || pixels == null) {
        image.dispose();
        return;
      }
      _image?.dispose();
      _image = image;
      _rgba = pixels.buffer.asUint8List();
      _crop = const Rect.fromLTWH(0, 0, 1, 1);
      _blackAtBottom = false;
      _notFound = true;
      final found = await _detect();
      if (mounted && _isCurrentRoute && found && widget.startWithCamera) {
        await _recognize();
      }
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

  Future<bool> _detect() async {
    final pixels = _rgba!;
    final w = _image!.width, h = _image!.height;
    final result = await vision.locateInBackground(pixels, w, h);
    if (!mounted || !_isCurrentRoute) return false;
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
    return result != null;
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
      if (!mounted || !_isCurrentRoute) {
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
      if (!mounted || !_isCurrentRoute) return;
      final logits = await widget.source.classifySquares(input);
      if (!mounted || !_isCurrentRoute) return;
      final result = vision.recognitionFromLogits(
        logits,
        rect,
        blackAtBottom: blackAtBottom,
      );
      Navigator.pop(context, '${result.placement} w - - 0 1');
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _dragCorner(int corner, Offset delta, Size size) {
    final minWidth = min(64 / _image!.width, _crop.right);
    final minHeight = min(64 / _image!.height, _crop.bottom);
    final dx = delta.dx / size.width, dy = delta.dy / size.height;
    setState(() {
      var left = _crop.left, top = _crop.top;
      var right = _crop.right, bottom = _crop.bottom;
      if (corner == 0 || corner == 3) {
        left = (left + dx).clamp(0, right - minWidth);
      } else {
        right = (right + dx).clamp(min(left + minWidth, 1), 1);
      }
      if (corner < 2) {
        top = (top + dy).clamp(0, bottom - minHeight);
      } else {
        bottom = (bottom + dy).clamp(min(top + minHeight, 1), 1);
      }
      _crop = Rect.fromLTRB(left, top, right, bottom);
    });
  }

  Widget _cropImage(ui.Image image) => LayoutBuilder(
    builder: (context, box) {
      final width = min(
        box.maxWidth,
        MediaQuery.sizeOf(context).height * .52 * image.width / image.height,
      );
      final size = Size(width, width * image.height / image.width);
      final corners = [
        _crop.topLeft,
        _crop.topRight,
        _crop.bottomRight,
        _crop.bottomLeft,
      ];
      return Center(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Semantics(
                  label: l10n(context).imageAdjustPhoto,
                  image: true,
                  child: GestureDetector(
                    key: const ValueKey('image-crop'),
                    onPanUpdate: (e) {
                      final dx = (e.delta.dx / size.width).clamp(
                        -_crop.left,
                        1 - _crop.right,
                      );
                      final dy = (e.delta.dy / size.height).clamp(
                        -_crop.top,
                        1 - _crop.bottom,
                      );
                      setState(() => _crop = _crop.shift(Offset(dx, dy)));
                    },
                    child: CustomPaint(
                      painter: _ImageCropPainter(image, _crop),
                    ),
                  ),
                ),
              ),
              for (int i = 0; i < corners.length; i++)
                Positioned(
                  left: (corners[i].dx * size.width - 24).clamp(
                    0,
                    max(0, size.width - 48),
                  ),
                  top: (corners[i].dy * size.height - 24).clamp(
                    0,
                    max(0, size.height - 48),
                  ),
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      key: ValueKey('image-crop-corner-$i'),
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (e) => _dragCorner(i, e.delta, size),
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.black54),
                              ),
                            ),
                            child: SizedBox(width: 14, height: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final t = l10n(context);
    final image = _image;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _busy
              ? t.imageScanBoard
              : image == null
              ? t.imageScanBoard
              : t.imageAdjustPhoto,
        ),
        actions: [
          if (image != null && !_busy)
            IconButton(
              key: const ValueKey('image-choose'),
              tooltip: t.imageChoose,
              onPressed: () => _choose(),
              icon: const Icon(Icons.photo_library_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: _busy
            ? Center(
                child: Semantics(
                  liveRegion: true,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          t.imageReading,
                          key: const ValueKey('image-reading'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_failed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _cameraUnavailable
                              ? t.imageCameraUnavailable
                              : t.imageImportFailed,
                          key: const ValueKey('image-import-error'),
                        ),
                      ),
                    if (image == null)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            key: const ValueKey('image-choose'),
                            onPressed: () => _choose(),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(t.imageChoose),
                          ),
                          FilledButton.icon(
                            key: const ValueKey('image-camera'),
                            onPressed: () => _choose(camera: true),
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: Text(t.imageTakePhoto),
                          ),
                        ],
                      )
                    else ...[
                      if (_notFound)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(t.imageBoardNotFound),
                        ),
                      _cropImage(image),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          TextButton.icon(
                            key: const ValueKey('image-camera'),
                            onPressed: () => _choose(camera: true),
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: Text(t.imageRetake),
                          ),
                          TextButton.icon(
                            key: const ValueKey('image-rotate'),
                            onPressed: _rotate,
                            icon: const Icon(Icons.rotate_right),
                            label: Text(t.imageRotate),
                          ),
                        ],
                      ),
                      FilledButton(
                        key: const ValueKey('image-recognize'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed:
                            _crop.width * image.width < 64 ||
                                _crop.height * image.height < 64
                            ? null
                            : _recognize,
                        child: Text(t.imageUsePhoto),
                      ),
                      ExpansionTile(
                        key: const ValueKey('image-adjust-edges'),
                        title: Text(t.imageAdjustEdges),
                        tilePadding: EdgeInsets.zero,
                        children: [
                          Text(t.imageCropHorizontal),
                          RangeSlider(
                            key: const ValueKey('image-horizontal-crop'),
                            values: RangeValues(_crop.left, _crop.right),
                            labels: RangeLabels(
                              '${(_crop.left * 100).round()}%',
                              '${(_crop.right * 100).round()}%',
                            ),
                            onChanged: (v) => setState(
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
                            onChanged: (v) => setState(
                              () => _crop = Rect.fromLTRB(
                                _crop.left,
                                v.start,
                                _crop.right,
                                v.end,
                              ),
                            ),
                          ),
                          SwitchListTile(
                            title: Text(t.imageBlackAtBottom),
                            value: _blackAtBottom,
                            onChanged: (v) =>
                                setState(() => _blackAtBottom = v),
                          ),
                          TextButton.icon(
                            onPressed: _find,
                            icon: const Icon(Icons.grid_on),
                            label: Text(t.imageFindBoard),
                          ),
                        ],
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
