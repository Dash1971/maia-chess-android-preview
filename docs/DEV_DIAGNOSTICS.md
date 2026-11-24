# Dev local diagnostics

**Current scope:** automatic tracing is Dev-only. Grand Kingdom is supported in Preview 2.6; Pegasus and the former image importer are withdrawn from current source. Open Board Scanner remains a [2.7 candidate](../README.md#roadmap), not a restored scanner.

The red-icon Dev app automatically records recent app lifecycle/error categories,
engine loading/inference phases and detailed Grand Kingdom events. There is no
switch. Preview, Stable and unflavored builds neither record this trace nor expose
its export; Dart and native flavor guards are independent. Grand Kingdom is included in published Preview; automatic tracing remains Dev-only.

Grand Kingdom records timestamped intended full UCI (including promotion suffix),
current/prior FEN and PGN context, input acceptance/rejection, exact outgoing wire
bytes, bounded incoming bytes, GATT callback status, connection/session changes,
queue depth and the motor-pending flag. It never sends new board commands, retries
moves or treats a successful GATT write as physical motor completion. Firmware
is not queried; ask the tester to supply its version. Raw input is capped at 128
bytes per notification, with truncation shown. PGN context is capped at 16,000
characters; the actual Dev model is 5M despite legacy PGN opponent labels.

Storage is private, excluded from Android backup, bounded to two 256 KiB segments,
and expires each segment seven days after its oldest event. The worker queue is
bounded; overload/storage failure does not block gameplay and is reported in the
export. Old events can be missing. Recording is diagnostic evidence, not a safe
motor replay facility or proof of the physical position.

Settings → Copy diagnostics includes the most recent 64 KiB of trace. Settings →
Save Dev diagnostics… opens Android's document picker and exports the full retained
trace plus the ordinary app/device diagnostics as text. Cancellation exports
nothing; the snapshot is fixed when the export starts. Review before manually
uploading. Nothing is sent automatically. Positions, moves, board messages and
phone/app versions are included; photos, model inputs and Bluetooth addresses
are not. Native runtime diagnostic text is deliberately canonical English.

Dev-store tests run through the existing test scripts. The published Dev
alpha.2 snapshot included [PR #210](https://github.com/Dash1971/maia-chess-android-preview/pull/210) and retains the former camera/image prototype.
That prototype was removed from source in Preview beta.3; the current scanner
direction is recorded in the [roadmap](../README.md#roadmap).
