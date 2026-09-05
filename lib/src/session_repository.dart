part of '../main.dart';

class RecentSession {
  const RecentSession(this.id, this.updatedAt, this.data);
  final String id;
  final DateTime updatedAt;
  final Map<String, dynamic> data;
  String get title {
    final kind = data['type'] == 'game' ? 'Game' : 'Analysis';
    final pgn = data['pgn'] ?? (data['session'] as Map?)?['pgn'];
    // Listing a long game must not parse its move tree on the UI isolate.
    final eventHeader = pgn is String
        ? RegExp(
            r'^\[Event .*$',
            multiLine: true,
          ).firstMatch(pgn.substring(0, min(pgn.length, 8192)))?.group(0)
        : null;
    final event = eventHeader == null
        ? null
        : dc.PgnGame.parsePgn(
            eventHeader,
            initHeaders: dc.PgnGame.emptyHeaders,
          ).headers['Event'];
    return event != null && event != '?' && !event.startsWith('Mobile Maia')
        ? event
        : '$kind · Maia ${data['elo'] ?? data['maiaElo'] ?? 1600}';
  }
}

/// App-private, transactional files. Each successful write retains the previous
/// readable checkpoint. Archived games are separate files, not rewritten per move.
class SessionRepository {
  SessionRepository(this.directory);
  final Directory directory;
  Future<void> _tail = Future.value();
  String? _activeId;

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        result.complete(await action());
      } catch (error, stack) {
        result.completeError(error, stack);
      }
    });
    return result.future;
  }

  Future<Map<String, dynamic>?> _readFile(File file) async {
    try {
      final source = await file.readAsString();
      final decoded = await Isolate.run(() => jsonDecode(source));
      if (decoded is! Map ||
          decoded['version'] != 1 ||
          decoded['id'] is! String ||
          (decoded['data'] != null && decoded['data'] is! Map)) {
        return null;
      }
      return Map<String, dynamic>.from(decoded);
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _read(File file) async =>
      await _readFile(file) ?? await _readFile(File('${file.path}.previous'));

  Future<void> _write(File file, Map<String, Object?> envelope) async {
    await file.parent.create(recursive: true);
    final payload = envelope;
    final encoded = await Isolate.run(() => jsonEncode(payload));
    final temporary = File('${file.path}.pending');
    await temporary.writeAsString(encoded, flush: true);
    if (await _readFile(file) != null) {
      await file.rename('${file.path}.previous');
    }
    await temporary.rename(file.path);
  }

  File get _active => File('${directory.path}/active.json');
  File _archiveFile(String id) {
    if (!RegExp(r'^[0-9a-z-]+$').hasMatch(id)) {
      throw const FormatException('Invalid session identifier');
    }
    return File('${directory.path}/games/$id.json');
  }

  Future<bool> hasCheckpoint() =>
      _serial(() async => await _read(_active) != null);

  Future<Map<String, dynamic>?> load() => _serial(() async {
    final envelope = await _read(_active);
    _activeId = envelope?['id'] as String?;
    return envelope?['data'] == null
        ? null
        : Map<String, dynamic>.from(envelope!['data'] as Map);
  });

  static Object? _detach(Object? value) => switch (value) {
    Map() => value.map((key, item) => MapEntry(key, _detach(item))),
    List() => value.map(_detach).toList(),
    _ => value,
  };

  Future<void> save(Map<String, Object?> data) {
    // Transfer to the isolate from a detached snapshot, never a live game list.
    final snapshot = Map<String, Object?>.from(_detach(data) as Map);
    return _serial(() async {
      _activeId ??=
          '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 30)}';
      await _write(_active, {
        'version': 1,
        'id': _activeId,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'data': snapshot,
      });
    });
  }

  Future<void> _archive() async {
    final envelope = await _read(_active);
    if (envelope != null && envelope['data'] != null) {
      await _write(_archiveFile(envelope['id'] as String), envelope);
    }
  }

  Future<void> startNew() => _serial(() async {
    await _archive();
    await _write(_active, {
      'version': 1,
      'id': _activeId ?? 'none',
      'data': null,
    });
    final previous = File('${_active.path}.previous');
    if (await previous.exists()) await previous.delete();
    _activeId = null;
  });

  Future<List<RecentSession>> recent() => _serial(() async {
    final entries = <String, RecentSession>{};
    void add(Map<String, dynamic>? envelope) {
      if (envelope == null || envelope['data'] == null) return;
      final id = envelope['id'] as String;
      entries[id] = RecentSession(
        id,
        DateTime.tryParse(envelope['updatedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        Map<String, dynamic>.from(envelope['data'] as Map),
      );
    }

    final archive = Directory('${directory.path}/games');
    if (await archive.exists()) {
      final names = <String>{};
      await for (final entity in archive.list()) {
        if (entity is File &&
            (entity.path.endsWith('.json') ||
                entity.path.endsWith('.json.previous'))) {
          names.add(entity.path.replaceFirst(RegExp(r'\.previous$'), ''));
        }
      }
      for (final name in names) {
        add(await _read(File(name)));
      }
    }
    add(await _read(_active));
    return entries.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  });

  Future<Map<String, dynamic>?> open(String id) => _serial(() async {
    await _archive();
    final entry = await _read(_archiveFile(id));
    if (entry == null) return null;
    _activeId = id;
    await _write(_active, entry);
    return Map<String, dynamic>.from(entry['data'] as Map);
  });

  Future<void> delete(String id) => _serial(() async {
    // Tombstone the active checkpoint before touching its archive. A process
    // death can then leave an incomplete deletion visible in Recent games, but
    // it cannot restore the deleted session as the active game on next launch.
    if ((await _read(_active))?['id'] == id) {
      await _write(_active, {'version': 1, 'id': id, 'data': null});
      final previous = File('${_active.path}.previous');
      if (await previous.exists()) await previous.delete();
      _activeId = null;
    }
    final archive = _archiveFile(id);
    // Delete rollback files first and the primary last. If deletion is
    // interrupted, _read() must never resurrect an older .previous copy after
    // the primary has disappeared.
    for (final suffix in ['.pending', '.previous', '']) {
      final file = File('${archive.path}$suffix');
      if (await file.exists()) await file.delete();
    }
  });
}

class RecentGamesPage extends StatefulWidget {
  const RecentGamesPage({super.key});
  @override
  State<RecentGamesPage> createState() => _RecentGamesPageState();
}

class _RecentGamesPageState extends State<RecentGamesPage> {
  late Future<List<RecentSession>> _items = ActiveSessionStore.recent();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Recent games')),
    body: FutureBuilder<List<RecentSession>>(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Could not load saved games. Please try again.'),
          );
        }
        final games = snapshot.data;
        if (games == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (games.isEmpty) {
          return const Center(
            child: Text('Your games and analysis will be saved here.'),
          );
        }
        return ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            final date = game.updatedAt.toLocal();
            return ListTile(
              title: Text(game.title),
              subtitle: Text(
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final data = await ActiveSessionStore.open(game.id);
                if (context.mounted && data != null) {
                  Navigator.pop(context, data);
                }
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete saved game',
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete saved game?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  await ActiveSessionStore.delete(game.id);
                  if (mounted) {
                    setState(() => _items = ActiveSessionStore.recent());
                  }
                },
              ),
            );
          },
        );
      },
    ),
  );
}
