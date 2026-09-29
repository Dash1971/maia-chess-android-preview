import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('maia_chess/sound_effect');
  const codec = StandardMethodCodec();
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('waits for native load completion and clamps playback volume', () async {
    final player = SoundEffect();
    await player.initialize(maxStreams: 2);
    expect(calls.single.method, 'initialize');
    expect(calls.single.arguments, {'maxStreams': 2});

    var loaded = false;
    final load = player
        .load('move', 'assets/sounds/standard/move.mp3')
        .then((_) => loaded = true);
    await Future<void>.delayed(Duration.zero);
    expect(loaded, isFalse);
    expect(calls.last.method, 'load');

    final callback = Completer<void>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channel.name,
          codec.encodeMethodCall(
            const MethodCall('onLoadComplete', {'soundId': 'move'}),
          ),
          (_) => callback.complete(),
        );
    await callback.future;
    await load;
    expect(loaded, isTrue);

    await player.play('move', volume: 2);
    expect(calls.last.method, 'play');
    expect(calls.last.arguments, {'soundId': 'move', 'volume': 1.0});
  });
}
