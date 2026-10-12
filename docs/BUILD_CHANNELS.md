# Build channels and promotion status

Updated 2026-10-13. Release pages are authoritative for published artifacts;
source on a branch alone is not an installed release. Each release PR records
its exact source SHA, tests, hashes, signing identity and remaining limitations.

| Channel | Version / status | Package and model | Scope |
| --- | --- | --- | --- |
| [Stable](https://github.com/Dash1971/maia-chess-android/releases) | Published 2.3.0; unchanged by this promotion | `com.dash1971.maia_chess`, 79M | Production app; use Stable's release guide for GitHub, Zapstore and F-Droid. |
| [Preview](https://github.com/Dash1971/maia-chess-android-preview/releases) | Published [2.4.0-beta.2](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.4.0-beta.2), code 2404; updates beta.1 in place | `com.dash1971.maia_chess.preview`, 79M | Maia help/history experiment and Chessnut improvements. Grand Kingdom and DGT are disabled. |
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

## Preview 2.4.0-beta.1 publication record

- Source: `3304a54e4a11fb974e77db8c559f5f2fc82e5473` ([PR #106](https://github.com/Dash1971/maia-chess-android-preview/pull/106)). Documentation-only commits after this SHA are not a rebuilt APK.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38192040612): full host regression suite, explicit Preview restrictions/settings tests, native board policies, localization and release packaging.
- GitHub Linux and independent Linux unsigned APK SHA-256: `b2296d4cd732090954d9036e7c1e89f1d3b3610bd1b4078edc51783962d9fa01`.
- Signed APK SHA-256: `2864afa54044908f39635f39a00b3ffb9272d3634802d1350c769c6cff3ff9c7`. Established Preview certificate SHA-256: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
- The release's verification bundle records APK packaging/signature checks, byte-identical signature reconstruction, beta.9 upgrade checks and native 79M qualification. The separate harness source is provided for reproduction; the harness is not in the app.
- Stable 2.3.0 and Dev alpha.2 were not rebuilt or republished. Physical Chessnut acceptance remains outstanding with the owner/testers; this publication does not claim Grand Kingdom/DGT support.

## Preview 2.4.0-beta.2 publication record

- Source: `0f4f2400b1f8cedcbe925deb233ad6700cba4bfa` ([fix #108](https://github.com/Dash1971/maia-chess-android-preview/pull/108), [release #109](https://github.com/Dash1971/maia-chess-android-preview/pull/109)). Later documentation commits do not rebuild this APK.
- Fresh discovery is three seconds. Confirmed Chessnut NEW GAME stays in-game, retains colors/settings and waits for LED-guided physical setup before automatically starting. Pending setup supports restore, reconnect and phone fallback.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38317124534): 895 Flutter tests, 28 explicit Preview tests, 51 release-tool tests, native board policies, localization, analysis and Android packaging passed.
- GitHub Linux and independent Linux unsigned APK SHA-256: `f2f09e3bf094b54f4e19ffef06d1a5f881d392716ddbbbd5e44d0b70e34d155d`.
- Signed APK SHA-256: `2bebe91bea2440feb7b37caa9ebfe5c4925135d010ec0cbb600da89efac670d4`. Preview certificate remains `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- The release verification bundle records the actual signed beta.1 upgrade, real Maia opening move with the player Black, and saved-game regressions for variations, unfinished games, checkmate, archive restoration and force-stop/restart. Additional fixture upgrades use temporary test signatures; the published-certificate upgrade is recorded separately.
- Model/engine dependencies are unchanged; beta.1's native tensor qualification is historical evidence, not a newly repeated beta.2 run. Physical discovery, LEDs and NEW GAME behavior still need owner/tester acceptance.
- Grand Kingdom/DGT remain Dev-only. Stable 2.3.0 and Dev alpha.2 were not rebuilt or republished; no Stable app-store changes.
