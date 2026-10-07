# Electronic-board development snapshot

This work is intentionally isolated on `codex/eboard-dev-integration`. It is not
Preview or Stable support qualification. The installable channel is
[Mobile Maia Preview Dev](https://github.com/Dash1971/maia-chess-android-preview-dev/releases).

## What to try

- Enable Electronic board on the new-game screen and connect. Discovery collects
  recognized nearby boards for four seconds: one connects automatically, multiple
  boards open a chooser. A remembered board retains the quick connection path;
  Choose another board explicitly scans again. Bluetooth addresses are not shown
  or included in diagnostics.
- Chessnut keeps piece recognition, LED guidance, Unlimited games, takebacks and
  phone continuation. In a game, NEW GAME opens the normal reset confirmation;
  a second deliberate press within 2.5 seconds confirms it. Cancellation,
  backgrounding, disconnection and game changes disarm confirmation. Unfinished
  reset games are discarded; completed games remain in Recent Games.
- Pegasus is an occupancy-only protocol prototype. Confirm physical piece identity
  at setup; ambiguous captures/promotions need phone confirmation. **Locked
  firmware is not supported:** the manufacturer initialization key has not been
  included because the reference permission is not unrestricted/FOSS-compatible.
  An unrestricted initialization route is required before claiming support.
- Square Off Grand Kingdom is an experimental motor protocol prototype, not
  support for every Square Off model. Explicitly confirm standard setup. An engine
  move is sent once, without automatic retries. A following legal human move, or
  explicit verification of every piece against the screen, acknowledges completion.
  Generic OK is insufficient. Interrupted motor sessions, takebacks and engine
  promotions require phone continuation; arbitrary-position restoration and motor
  cancellation have no established safe protocol here.

## Development capture and diagnostics

Routine diagnostics retain bounded summaries, not Bluetooth addresses or raw
position notifications. Explicit developer capture/replay is separate; see
`tool/board_capture/capture.py --help` and `tool/board_capture/README.md`.
Capture files can reveal moves and positions; review them before sharing.

## Validation before promotion

Automated checks cover pure Kotlin discovery/framing/queue policies, Dart frame
reassembly and occupancy inference, reset timing/data preservation, connection
selection, stale sessions, lifecycle, phone continuation and all ten languages at
320×568 with 200% text. Native protocol checks run in normal PR CI through
`tool/test_board_native.sh`; the existing Flutter and Python suites remain gates.

Hardware acceptance is still required. Record board model, firmware, Android
version and APK version for each result. Test one/multiple nearby boards, denied
permissions, Bluetooth off/on, connection loss, reset double press/long hold,
castling, en passant, captures, promotions, Maia playing White, takebacks,
background/resume, saved-game restoration and continuing on the phone. Verify
LEDs physically and never infer motor completion from a successful write alone.

The owner first reviews the Dev UI. Promotion into Preview and distribution to
Pegasus/Grand Kingdom testers happen only after that separate approval. Keep
issues #27, #38, #40 and #68 open until their relevant acceptance is complete.

See `ELECTRONIC_BOARD_NATIVE_PROTOCOL.md` for pinned upstream wire references,
licensing constraints and explicit protocol limitations.
