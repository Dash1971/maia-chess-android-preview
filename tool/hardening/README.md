# Release hardening without physical devices

The ordinary CI suite includes the deterministic regressions and a checked-in
256-position chess oracle. The Python development environment is required for
release-tool tests and for regenerating/expanding the oracles. These tools do
not add runtime dependencies or network access to the app.

## Standard checks

Use the Flutter version and commit pinned in `.github/workflows/checks.yml`.

```sh
flutter pub get --enforce-lockfile
flutter analyze
flutter test --reporter expanded
python3 -m venv /tmp/maia-release-venv
/tmp/maia-release-venv/bin/pip install -r tool/hardening/requirements.txt
/tmp/maia-release-venv/bin/python -m unittest discover -s tool -p '*_test.py'
```

The added tests cover Top-P sampling, malformed checkpoint metadata, PGN byte
and nesting limits, delayed board alerts, pause/resume guidance, failed native
Stockfish commands, lost Bluetooth command completions, and disconnect failure.
The queue stress test uses 1,000 seeded operations with cancellation, background
work, suspension, resumption, and simulated native errors. It checks that every
request settles and native execution remains serial.

## Independent chess oracle

```sh
python3 -m venv /tmp/maia-chess-oracle-venv
/tmp/maia-chess-oracle-venv/bin/pip install -r tool/hardening/requirements.txt
/tmp/maia-chess-oracle-venv/bin/python tool/hardening/generate_chess_corpus.py \
  --positions 3000 --seed 20260909 --output /tmp/maia-chess-oracle.json
MAIA_CHESS_CORPUS=/tmp/maia-chess-oracle.json \
  flutter test test/chess_oracle_test.dart --reporter expanded
```

The oracle compares legal moves, mate/stalemate status, selected move transitions,
board-frame move inference, and PGN import/export against python-chess. Fixed
positions exercise castling, pinned en passant, promotion, and terminal states;
the remainder follow seeded legal games. This is differential testing, not an
exhaustive proof of chess correctness or a test of Maia's rating calibration.
Use `--positions 256 --output test/fixtures/chess_oracle.json` to regenerate the
committed fixture with the default seed.

The corpus also supplies the complete 4,352-entry Maia move vocabulary, its
Black-perspective mapping, and board token occupancy derived with python-chess.
Regenerate older external corpora to include these fields. Sampling tests check
43,200 probability-space quantiles across temperatures, Top-P settings, colours,
promotion positions, and large additive shifts to logits.

Additional regressions cover Stockfish readiness failures and score perspective,
timeout draws against insufficient mating material, analysis restoration and
existing variations after pawn double moves, failed checkpoint writes, and a
1,000-game archive. These run as part of the standard suite.

`test/variation_navigation_test.dart` covers returning from imported and nested
variations, move highlighting, root alternatives, black-to-move starting FENs,
save/reopen, stale analysis replies, repeated branch exits with annotations,
and every main-line move of the reported 66-move game in both directions.
`test/pgn_import_routes_test.dart` drives shared, pasted, and file-picker PGNs
through their screens with the real background parser. This guards against
isolate closures accidentally capturing unsendable widget state.

`test/chessnut_continuation_test.dart` covers completed-game restoration and
switching from board input to the screen, including delayed connection/LED
callbacks, pending Maia moves, takebacks, draw decisions, retry, checkmate,
and persistence. `test/chessnut_continuation_layout_test.dart` checks both
connection actions and scrollable menus in portrait/landscape at normal and
200% text size. Android integration also opens real Recent games records,
continues a board game on screen with real Maia, and verifies that saving and
reopening preserve the archive identity and the new input choice.

The 1,000-ply PGN stress test prints a host timing for import and round-trip.
Compare timings on the same host; it does not establish phone performance.

## Variation preservation and action sequences

`test/takeback_review_regressions_test.dart` reproduces the consecutive
takebacks reported around move 12. It checks eight analysis visits and four
reopens, the full exported PGN, move history, clock history, and notes. It also
loads an older save containing three copies of the same line and verifies that
one complete line survives with the combined annotations.

`test/variation_tree_test.dart` covers every segmentation of a six-move
continuation, different child alternatives, comments and NAGs, equivalent
legacy FEN notation, and the boundary between played and undone moves. An
undone terminal continuation must never become part of the played main line.

`test/variation_editing_regressions_test.dart` combines nested promotion,
making a branch the main line, deleting a separate alternative, and four JSON
reopens. It compares every remaining move path and annotation, the selected
position, and the complete PGN after each reopen.

`test/recent_games_failure_test.dart` exercises overlapping taps before a new
frame, Back while a save is opening, and retry after open/delete failures.
`test/recent_games_recovery_test.dart` adds concurrent delete requests before
a confirmation frame, cancellation by button or Back followed by a successful
open, partial batch deletion with selection refresh and retry, and opening
another game after a record becomes unavailable.
`test/storage_failure_test.dart` also blocks an active-checkpoint write while
switching archives, then resumes the original game and checks both save IDs.
The Android suite repeats that real filesystem failure and retry through the
Recent-games screen on app-private storage.

`test/beta16_release_regressions_test.dart` combines seeded legal moves,
repeated takebacks, stale Maia replies, background/resume, reopening, and
analysis visits. After each step it checks played moves, board position and
clocks. It now also checks that exported root-to-leaf variation paths occur
once and that merely opening analysis does not change the exported PGN.

The independent variation oracle starts with python-chess games containing
legal forks, comments and NAGs, duplicates some branches as legacy saves did,
and mixes flat PGN branches with segmented takeback trees in Dart. It compares
all move paths and their annotations, unique leaf paths, the played main line,
and the final position against Python's expected values. Each tree undergoes
four export/merge cycles. The ordinary CI suite uses 32 checked-in games;
release hardening can run a larger corpus with a different seed:

```sh
/tmp/maia-chess-oracle-venv/bin/python tool/hardening/generate_variation_corpus.py \
  --cases 512 --seed 20260911 --output /tmp/maia-variation-oracle.json
MAIA_VARIATION_CORPUS=/tmp/maia-variation-oracle.json \
  flutter test test/variation_oracle_test.dart --reporter expanded
```

Use `--output test/fixtures/variation_oracle.json` with the default arguments
to regenerate the committed fixture. Both generators use the same optional
Python environment. The starting positions include castling, promotion, and
en passant for either side.

For future bugs, retain a reduced PGN or saved-record fixture and first show
that the relevant regression fails on the affected release. Test combinations
of features, including no-op visits and save/reload cycles, rather than only
testing each button in isolation. Keep fast deterministic cases in every PR's
CI; run expanded seeded corpora, native integration, and a clean release build
before publishing. A newly failing seed should become a permanent small case.

## Android native integration

Use JDK 17, the project's Android SDK/NDK versions, an ARM64 Android emulator,
and the real model asset verified by `python3 tool/verify_model.py`. Materialize
Git LFS assets before building. On Apple Silicon, the audit used an AOSP API 36
ARM64 image with hardware acceleration, two virtual CPU cores, and 3 GB RAM.

```sh
flutter devices
flutter test integration_test/review_android_test.dart \
  --flavor preview -d emulator-5554 --reporter expanded
tool/build_android_release.sh
```

Substitute the actual emulator ID. Always select `--flavor preview` for official
release qualification: the default flavor is `dev`, which packages Maia3-5M
instead of the official 79M model. Use `--flavor dev` only for supplementary
Dev-lane testing, and record the tested flavor in the results:

```sh
flutter test integration_test/review_android_test.dart \
  --flavor dev -d emulator-5554 --reporter expanded
```

Dev runs one native 5M policy shape/finiteness smoke check. Preview runs all four
79M numerical reference cases instead, reusing one model session. Unknown flavors
fail the engine test. Dev results do not qualify an official release.

Before publishing, require a passing full Preview native suite for the exact
candidate source commit and retain its log with the tested flavor and emulator
architecture. Ordinary GitHub PR checks do not run native inference; the optional
Android workflow builds/verifies the APK but also does not run this suite. A green
GitHub badge therefore does not replace this release gate.

Integration tests
exercise the real Maia policy bridge against checked-in logits generated by the
official Maia-3 79M PyTorch checkpoint (initial position, Black-to-move
mirroring with unequal player ratings, a middlegame, and promotions), real Stockfish navigation and graph
analysis, a reported game replay, and checkmate UI handling. Test-only simulated
transports cover Bluetooth failures; the emulator does not establish actual
GATT or LED behavior.

The test-only reference fixture records the official Maia-3 source commit and
PyTorch checkpoint hash as well as the Mobile Maia ONNX hash. Regenerate it only
from clean, independently checked-out Maia-3 source and the pinned checkpoint:

```sh
python3.12 -m venv /tmp/maia3-reference-venv
/tmp/maia3-reference-venv/bin/pip install \
  -r tool/hardening/requirements-maia3-reference.txt
/tmp/maia3-reference-venv/bin/python tool/generate_maia3_reference.py \
  --maia3-source /path/to/clean/maia3 \
  --checkpoint /path/to/maia3-79m.pt
dart format integration_test/fixtures/maia3_reference.dart
```

The optional environment pins the direct numerical dependencies and is separate
from ordinary test requirements. The source checkout must be at the commit
recorded in the fixture, and the checkpoint and materialized ONNX file must match
its hashes. Regeneration is not a build or CI step. Different numerical runtimes
may still produce tiny rounding differences; Android comparisons use a tolerance.
The Black-to-move case uses self Elo 1600 and opponent Elo 2100 so swapping those
inputs cannot pass simply because both ratings are equal.

The reported move-16 variation is also exercised with the real engines, checking
that Back selects the highlighted main-line move and Forward follows that line.
The paste dialog also imports the reported PGN through a real isolate on Android.
The nested-takeback regression uses real Android storage and clipboard, opens
analysis with the real engines, and reopens the game after each visit. Its game
opponent is controlled so the exact takeback/replacement sequence is repeatable.

Check that the emulator has finished booting and no system crash/ANR dialog is
covering the app. Android can deny clipboard reads to an unfocused app; do not
disable permissions or SELinux to make a test pass. Run native suites serially
on an emulator containing only synthetic test data. Separately smoke-test the
release APK and update restoration, since debug integration alone does not
verify the artifact that will ship.

Keep release artifacts unsigned for review. Do not commit materialized model
binaries, SDKs, caches, emulator disks, or generated APKs. The checked-in LFS
pointer must remain a pointer.

## Portable APK and upgrade checks

[`RELEASE_CHECKS.md`](RELEASE_CHECKS.md) documents the repository tools for APK
packaging/signature/payload verification and an emulator saved-game upgrade.
They replace the one-off Mac scripts with configurable SDK/APK paths, a
sanitized checked-in PGN, JSON pass/fail results and failure diagnostics. The
manual CI release-build job also runs packaging verification and retains its
APK/log/report artifacts for 14 days.

## Feedback and Maia probability regressions

`test/game_feedback_lifecycle_test.dart` holds sound loading pending while the
app backgrounds, returns, changes routes, browses history, or disposes its game.
It also verifies accepted feedback and one game-end event still work, and that
entering analysis cancels the delayed end event. The shared navigation tests
record platform feedback calls so implicit Material/tooltip haptics cannot
bypass the phone feedback policy.

`test/maia_probability_sheet_test.dart` covers single-Maia and second-Maia
probabilities in 24 phone, landscape, and tablet/text-size combinations. It
checks painted font size at normal, 160%, and 200% text scaling, matching text
sizes for moves and Other, 48-pixel minimum action targets, and a single line
when entries fit. It opens each distribution, checks the selected rating and
probabilities, and reaches the last legal move without changing the board.
Wrapped engine panels remain scrollable while navigation controls stay usable.
`test/maia_probability_corpus_test.dart` compares raw legal probabilities with
direct softmax across both colors, promotions, castling, en passant, terminal
positions, and ten reproducible seeded games (seed 20260928).

These tests run with the normal `flutter test` suite; they require neither
physical phones nor an electronic board. Android Recent Games integration
checks use stable session-ID keys rather than display names, which may repeat.
