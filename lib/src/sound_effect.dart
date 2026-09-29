part of '../main.dart';

/// Low-latency game audio backed by Android's platform [SoundPool].
///
/// Keeping this bridge in the app removes the abandoned third-party plugin's
/// independent Android Gradle and Kotlin toolchain from the build graph.
class SoundEffect {
  SoundEffect() {
    _channel.setMethodCallHandler(_handlePlatformCall);
  }

  static const _channel = MethodChannel('maia_chess/sound_effect');
  final Map<String, Completer<void>> _loads = {};

  Future<void> _handlePlatformCall(MethodCall call) async {
    final arguments = call.arguments;
    if (arguments is! Map) return;
    final soundId = arguments['soundId'];
    if (soundId is! String) return;
    final completer = _loads.remove(soundId);
    if (completer == null || completer.isCompleted) return;
    switch (call.method) {
      case 'onLoadComplete':
        completer.complete();
      case 'onLoadError':
        completer.completeError(StateError('Failed to load sound $soundId'));
    }
  }

  Future<void> initialize({int maxStreams = 1}) =>
      _channel.invokeMethod<void>('initialize', {'maxStreams': maxStreams});

  Future<void> load(String soundId, String path) async {
    final completer = Completer<void>();
    final previous = _loads.remove(soundId);
    if (previous != null && !previous.isCompleted) {
      previous.completeError(StateError('Sound load replaced: $soundId'));
    }
    _loads[soundId] = completer;
    try {
      await _channel.invokeMethod<void>('load', {
        'soundId': soundId,
        'path': path,
      });
    } catch (error, stackTrace) {
      if (_loads.remove(soundId) == completer && !completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    }
    return completer.future;
  }

  Future<void> play(String soundId, {double volume = 1.0}) =>
      _channel.invokeMethod<void>('play', {
        'soundId': soundId,
        'volume': volume.clamp(0.0, 1.0),
      });

  Future<void> release() async {
    for (final load in _loads.values) {
      if (!load.isCompleted) {
        load.completeError(StateError('Sound player released'));
      }
    }
    _loads.clear();
    await _channel.invokeMethod<void>('release');
  }
}
