# Preview beta.11 preparation history

Beta.11 is now [published](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.11); [qualification and cleanup](releases/preview-2.6.0-beta.11.md) record the release. The entries below describe pre-release work and its earlier no-build/no-Actions scope. Those dated limits are historical. Stable 2.6.0 is now released; see [its separate qualification](https://github.com/Dash1971/maia-chess-android/blob/main/docs/release-notes/v2.6.0-verification.md).

## Proposed changes

- Remove the Pegasus prototype from all flavors, including Dev, due to unresolved
  initialization licensing. The [decision](decisions/2026-11-22-electronic-board-support.md)
  and README table record supported models and hardware testing status. Old Dev
  saves recover on the phone without reconnecting to the retired board.

- A selected game over the 5 MiB individual-game limit now gets a specific error
  instead of a generic export failure. Save/Share stop before opening Android
  UI, retain the selection and allow retry. Import, export and individual-game validation all use the same 5 MiB limit.
- Importing a collection adds new validated games to Recent games in one commit,
  without replacing the current game or recovery settings. Single-game opening
  stays unchanged. PGN transfers games and annotations, not app settings or live
  clock/motor session checkpoints.
- Board status, Bluetooth permission/recovery and Android-only messages no
  longer call every board Chessnut. All ten languages are covered.
- README credits and third-party notices identify the pinned Grand Kingdom
  protocol reference.

## Release clarifications

Human move timing defaults on when no saved choice exists, including after
upgrading. An explicitly saved off choice stays off; resetting Settings enables
timing. No migration preserving the previous unset default is added.

Import and export both allow 5 MiB of UTF-8. File picker, pasted PGN, Open with
and shared attachments validate every game in a collection. Exact-content duplicates are skipped against saved games and within the file; annotations and metadata remain part of the comparison. Invalid later games
and storage failure do not expose a partial import. No streaming, automatic
splitting or new warning dialog is added.

Grand Kingdom is supported: standard-position untimed play,
assisted Maia promotion and phone fallback. Existing hardware evidence and
remaining scenarios are in the [acceptance record](ELECTRONIC_BOARD_GRAND_KINGDOM_26.md).

Recent games uses selection-toolbar deletion instead of per-row delete icons.
Back cancels selection first; Back from a saved game restores the list position.
The unfinished-game leave confirmation remains in place.

## Testing before Stable approval

After beta.11 is qualified and built, check these messages and export/retry paths
in the installed app, then revisit the affected gameplay and analysis flows.
Stable 2.6 remains a draft pending that testing and its own release qualification.
Host regressions do not replace Android document-provider or physical-board tests.

The duplicate/progress follow-up adds a localized progress bar and imported/skipped summary. First repository access cleans abandoned import staging, preserving checkpoints, committed records and live imports. Import file work and Recent games decoding use background workers. Stable store descriptions also clarify that Chessnut Pro is not fully tested; Preview has no Fastlane/Zapstore listing to port.

## Initial host verification — 22 November 2026

The full host suite passed 1,507 tests, with one skipped. The explicit Preview-flavor focused suite passed 130 tests, and default Dev channel-policy checks passed five with one skipped. Flutter analyze reports no issues. Localization/terminology, source/metadata checks and unchanged workflow structure pass. Native tests are updated but uncompiled because the current Mac host has no JDK. Android and physical-board verification remain pending.

The matching [Stable 2.6 draft #82](https://github.com/Dash1971/maia-chess-android/pull/82) carries these changes without altering its release identity or qualification gates. Shared helpers remain identical. Dev uses Preview source; its separate repository contains only the release feed, so no third source companion applies.

## Final collection hardening host checks

The updated full host suite passed **1,526 tests, one skipped**, in each repository. New regressions cover exact-content duplicates, metadata/annotation differences, readable backups, all-duplicate retry without writes, abandoned/live staging, progress transitions and ten-language compact/large-text feedback. The 10,000-game near-5-MiB fixture and repeat import pass in both repositories. Final localized checks also run under the official Preview flavor. The [measurement report](verification/pgn-collection-import-2026-11-22.md) records fixture scope, timings and pending device checks. No Android builds, Actions or LFS downloads.

## Export/re-import correction

Host regressions reproduced duplicate records after exporting/reimporting app-generated and imported PGNs. Duplicate keys now normalize supported content through the export serializer. Changed annotations and metadata stay separate; lossy serialization uses conservative original-text comparison. Ten new round-trip regressions and updated README/PGN guidance accompany the shared fix in Stable #82 and Preview #261. No Android builds, Actions or LFS downloads.

Verification of the round-trip correction: 85 focused import/export checks passed in Stable, and all ten new regressions passed under the official Preview flavor. The complete remaining Stable host suite passed 1,535 tests with one skipped. The identical 10,000-game assertions passed separately in the instrumented diagnostic after a combined run exceeded the scale timeout on a loaded Mac. Both analyzers pass. These checks preserve the no-Android-build/no-Actions/no-LFS boundary and do not replace release qualification.

## Parsing progress and delayed feedback

Validation now reports progress from its worker after each complete game validates. The bar advances continuously through validation (first half) and duplicate checking/staged writes (second half). The visible dialog and dimming appear only after 300 ms, while the existing input/Back guard starts immediately; quick success or failure cancels delayed feedback. Failure and source disposal leave no late dialog or timer. Single-game opening, 5 MiB limits and duplicate rules are unchanged.

Verification: 95 focused PGN regressions pass in Stable and 95 under the official Preview flavor, including ten new parsing/delay checks and all ten localized compact/large-text cases. Both analyzers are clean. The updated standalone 10,000-game / 5,240,000-byte regression passes, including intermediate ordered parsing updates (2,345 reports on this run), import/re-import and Recent games. No Android builds, Actions or LFS downloads. Shared app/test changes match the companion PR; mandatory workspace helpers and release identities/gates remain unchanged.

## Supported Grand Kingdom policy

Grand Kingdom is supported across Stable 2.6, Preview and Dev. The Dart and native policy and corresponding regressions now match in both source repositories. Current README/release/store wording and board controls use supported-device language; hardware test coverage remains separately recorded as partial. Standard-position/untimed setup, assisted promotion, current-session motor guards and phone recovery are unchanged. Historical published records are retained. No Android builds, Actions or LFS downloads.

Verification: 108 board/discovery/promotion/wording host tests pass in each repository; three additional six-test runtime suites pass per repository, covering all four actual flavor configurations in total. Both analyzers are clean; 12 localization-checker tests pass in each repository and all 470 messages across ten catalogs satisfy the contracts. Native policy and native regression source are aligned; native/Android compilation remains pending. The stale scanned-position comment is also aligned. No Android builds, Actions or LFS downloads.
