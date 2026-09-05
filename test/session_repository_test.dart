import 'dart:io';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:maia_chess/main.dart';

void main() {
  late Directory directory;
  late SessionRepository store;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('maia-sessions-');
    store = SessionRepository(directory);
  });
  tearDown(() async => directory.delete(recursive: true));

  test(
    'writes are ordered and snapshots detach nested mutable lists',
    () async {
      final moves = <String>['e4'];
      final first = store.save({'type': 'game', 'moves': moves});
      moves.add('e5');
      final second = store.save({'type': 'game', 'moves': moves});
      moves.clear();
      await Future.wait([first, second]);
      expect((await store.load())!['moves'], ['e4', 'e5']);
      await File('${directory.path}/active.json').writeAsString('{broken');
      expect((await store.load())!['moves'], ['e4']);
    },
  );

  test(
    'interrupted rename recovers previous checkpoint across a restart',
    () async {
      await store.save({'type': 'game', 'pgn': '1. e4 *'});
      await File('${directory.path}/active.json')
          .rename('${directory.path}/active.json.previous');
      await File('${directory.path}/active.json.pending')
          .writeAsString('{partial');
      final restarted = SessionRepository(directory);
      expect((await restarted.load())!['pgn'], '1. e4 *');
      await restarted.save({'type': 'game', 'pgn': '1. e4 e5 *'});
      await File('${directory.path}/active.json').writeAsString('bad');
      expect((await restarted.load())!['pgn'], '1. e4 *');
    },
  );

  test('starting new sessions archives independently and reopening preserves current', () async {
    await store.save({'type': 'game', 'pgn': '1. e4 *'});
    final first = (await store.recent()).single.id;
    await store.startNew();
    expect(await SessionRepository(directory).load(), isNull);
    await store.save({'type': 'analysis', 'pgn': '1. d4 *'});
    final entries = await store.recent();
    expect(entries.length, 2);
    final second = entries.firstWhere((entry) => entry.id != first).id;
    expect((await store.open(first))!['pgn'], '1. e4 *');
    expect((await store.open(second))!['pgn'], '1. d4 *');
    expect((await store.recent()).length, 2);
  });

  test(
    'deleting an active session removes its backups without resurrection',
    () async {
      await store.save({'type': 'game', 'pgn': '1. e4 *'});
      await store.save({'type': 'game', 'pgn': '1. e4 e5 *'});
      final id = (await store.recent()).single.id;
      await store.open(id);
      await store.delete(id);
      final restarted = SessionRepository(directory);
      expect(await restarted.load(), isNull);
      expect(await restarted.recent(), isEmpty);
    },
  );

  test(
    'archived backups remain available when their primary file is corrupt',
    () async {
      await store.save({'type': 'game', 'pgn': '1. e4 *'});
      final id = (await store.recent()).single.id;
      await store.open(id);
      await store.startNew();
      await File('${directory.path}/games/$id.json').writeAsString('bad');
      expect((await store.recent()).single.data['pgn'], '1. e4 *');
      expect((await store.open(id))!['pgn'], '1. e4 *');
    },
  );
  test('migration is durable before removing the old preference', () async {
    final legacy = {'schema': 1, 'type': 'game', 'pgn': '1. e4 *'};
    SharedPreferences.setMockInitialValues({
      'activeSessionV1': jsonEncode(legacy),
    });
    final preferences = await SharedPreferences.getInstance();
    expect(
      await ActiveSessionStore.restoreOrMigrate(store, preferences),
      legacy,
    );
    expect(preferences.getString('activeSessionV1'), isNull);
    expect(await SessionRepository(directory).load(), legacy);
  });

  test('interrupted migration cannot resurrect an archived game', () async {
    final legacy = {'schema': 1, 'type': 'game', 'pgn': '1. e4 *'};
    SharedPreferences.setMockInitialValues({
      'activeSessionV1': jsonEncode(legacy),
    });
    // Simulate process death after the new file is durable but before the old
    // preference was removed, followed by a successful Home operation.
    await store.save(legacy);
    await store.startNew();
    final preferences = await SharedPreferences.getInstance();
    expect(
      await ActiveSessionStore.restoreOrMigrate(
        SessionRepository(directory),
        preferences,
      ),
      isNull,
    );
    expect(preferences.getString('activeSessionV1'), isNull);
    expect((await store.recent()).single.data, legacy);
  });
}
