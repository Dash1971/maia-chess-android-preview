# Build channels and promotion status

Updated 2026-10-12. Release pages are authoritative for published artifacts;
source on a branch alone is not an installed release. Each release PR records
its exact source SHA, tests, hashes, signing identity and remaining limitations.

| Channel | Version / status | Package and model | Scope |
| --- | --- | --- | --- |
| [Stable](https://github.com/Dash1971/maia-chess-android/releases) | Published 2.3.0; unchanged by this promotion | `com.dash1971.maia_chess`, 79M | Production app; use Stable's release guide for GitHub, Zapstore and F-Droid. |
| [Preview](https://github.com/Dash1971/maia-chess-android-preview/releases) | 2.4.0-beta.1 candidate, code 2403; replaces beta.9 only after release verification | `com.dash1971.maia_chess.preview`, 79M | Maia help/history experiment and Chessnut improvements. Grand Kingdom and DGT are disabled. |
| [Dev](https://github.com/Dash1971/maia-chess-android-preview-dev/releases/tag/v2.4.0-alpha.2-dev) | Published 2.4.0-alpha.2-dev, code 2402 | `com.dash1971.maia_chess.preview.dev`, 5M | Prototype Grand Kingdom/DGT work remains here. This release retains the previous, longer history subtitle. |

The three packages install side by side. Obtainium users should select the
intended repository and enable prereleases for Preview/Dev. Installing Preview
does not upgrade Dev or transfer its saved games/preferences. Existing Preview
installations update in place using the established Preview certificate.

## Preview acceptance

- Use move history remains off by default. Its short description is
  “Off is recommended. See information button for details.” in English, with
  equivalent text in all ten languages. The information dialog retains the
  explanation that saved sessions keep their original mode.
- Chessnut: bounded diagnostics and decoder recovery, single/multiple-board
  discovery, remembered selection, session/lifecycle protection, and NEW GAME
  confirmation by a second deliberate press within 2.5 seconds.
- Board sounds remain under **Chessnut**, because the buzzer commands are
  Chessnut-specific. Other brands must not imply equivalent sound support.
- The Grand Kingdom and DGT implementations remain in shared source for Dev,
  but Preview must neither discover/connect to those boards nor send their
  commands. Both Dart and native channel policies are tested. A future promotion
  requires explicit approval; merging shared source does not change this policy.
- Qualify the actual 79M Preview APK, including history on/off, inference,
  upgrade/data retention, help layout and package/signature continuity. Dev's
  5M measurements are not evidence of 79M performance.
- Physical Chessnut acceptance remains with the owner/testers. Automated tests
  cannot confirm radio reliability, physical LEDs or button behavior on hardware.

## Dev limitations

Grand Kingdom is an experimental motor adapter, not support for all Square Off
boards. DGT Pegasus remains a protocol prototype; locked firmware is unsupported
because no unrestricted initialization route has been incorporated. Neither is
Preview or Stable support. See [the board tester guide](ELECTRONIC_BOARD_DEV.md).
Keep the board-specific issues open until hardware acceptance is recorded.

The published Dev alpha.2 APK uses 5M even though its exported PGN model label
still says 79M. This known Dev-only label limitation does not describe Preview's
actual 79M model. History is experimental and does not promise greater strength.
