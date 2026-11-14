# Selected Recent Games → one PGN

Implementation for [#225](https://github.com/Dash1971/maia-chess-android-preview/issues/225),
targeting the next release. This source change does not publish an APK.

Long-press a game, or choose Select games from the Recent Games menu. Select one
or more games, or use Select all. **Export games** opens the existing **Save PGN
file** and **Share PGN** choices. Each produces a single multi-game `.pgn` file.

## Ordering and content

Export follows the current Recent Games display order, regardless of selection
tap order. The repository orders by original played day, newest first; known
start times and then record IDs resolve ties. Unknown historical dates remain
unknown. Export does not sort by save/update time or fabricate PGN metadata.

Each selected record is read again through a read-only repository method.
Export never calls `open()`, which would archive/replace the active game. It
does not write snapshots, update history, delete games or change restoration
preferences. The current PGN snapshot already contains the individual game's
supported export data. The existing single-game parser/serializer validates
each game's tokens, starting FEN and all variations and preserves its available
headers, result, comments, NAGs and clock annotations. A record containing more
than one game is rejected rather than silently dropping the later game.

Games are separated by a blank line, including a final blank line. No default
historical player names, dates or time controls are invented. Completed games,
unfinished `*` games and supported custom starting positions use the same path.

## Limits and failures

- The complete file is validated before opening Android's save/share UI. A
  missing, unreadable, unsupported or invalid selected record fails the entire
  operation; no selected game is silently omitted.
- Assembly reads/validates one game at a time, with parsing in a background
  isolate. Only the combined bounded PGN is retained by the export builder.
  Recent Games' existing list-loading behavior is unchanged.
- The existing Android document/share limit remains **2 MiB (2,097,152 UTF-8
  bytes)**, including inter-game separators. The user-facing message calls this
  2 MB and suggests selecting fewer games. There is no unlimited-size promise or
  truncation. Per-game parser limits remain unchanged.
- An empty selection disables the action. Repeated/stale callbacks cannot start
  a second export or alter the selection while it is running. Other actions and
  navigation are blocked while preparing the file or awaiting the picker.
- Success, picker cancellation and failure preserve the selection. Cancellation
  shows no success message. A failed export leaves the screen usable for retry.

Android continues to use the existing document picker and FileProvider chooser,
temporary URI grants and MIME type. There is no new native code, permission,
network dependency, model or automatic upload.

## Verification

`test/recent_games_pgn_export_test.dart` covers one/multiple/all selection,
display ordering, round-trip metadata/annotations/variations, custom FEN,
unfinished games, missing/invalid/multiple-game records, UTF-8 and aggregate byte
limits, a 200-game collection, read-only repository files, save/share method
dispatch, cancellation, native failure/retry and stale callbacks. All ten
languages exercise the selection/export menu at 320 px with 200% text.

Existing Recent Games failure/recovery, repository and PGN import tests remain
in place. Host method-channel tests cover the Dart save/share/cancel contract;
they do not certify an OEM document provider or third-party PGN application.
Android device smoke testing remains a release check. No Android build or CI is
required to review this draft PR.
