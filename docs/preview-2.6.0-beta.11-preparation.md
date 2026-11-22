# Preview beta.11 preparation

Draft notes only. Beta.10 remains the published Preview release. This PR does
not bump the version, build an APK, run Actions or publish a release.

## Proposed changes

- A selected game over the 5 MiB individual-game limit now gets a specific error
  instead of a generic export failure. Save/Share stop before opening Android
  UI, retain the selection and allow retry. Import, export and individual-game validation all use the same 5 MiB limit.
- Importing a collection adds all validated games to Recent games in one commit,
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
and shared attachments handle every game in a collection. Invalid later games
and storage failure do not expose a partial import. No streaming, automatic
splitting or new warning dialog is added.

Grand Kingdom support remains experimental: standard-position untimed play,
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
