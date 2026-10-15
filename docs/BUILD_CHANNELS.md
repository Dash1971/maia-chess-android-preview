# Build channels and promotion status

Updated 2026-10-15. Release pages are authoritative for published artifacts;
source on a branch alone is not an installed release. Each release PR records
its exact source SHA, tests, hashes, signing identity and remaining limitations.

| Channel | Version / status | Package and model | Scope |
| --- | --- | --- | --- |
| [Stable](https://github.com/Dash1971/maia-chess-android/releases) | Published 2.3.0; unchanged by this promotion | `com.dash1971.maia_chess`, 79M | Production app; use Stable's release guide for GitHub, Zapstore and F-Droid. |
| [Preview](https://github.com/Dash1971/maia-chess-android-preview/releases) | Published [2.4.0-beta.8](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.4.0-beta.8), code 2410; updates beta.7 in place | `com.dash1971.maia_chess.preview`, 79M | Maia help/history experiment and Chessnut improvements. Grand Kingdom and DGT are disabled. |
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

## Stable 2.4 promotion boundary

A Stable 2.4 release can proceed with Chessnut support while Grand Kingdom and
Pegasus remain unaccepted Dev prototypes. Keep both Dart and native flavor gates
and their regression tests; verify the actual production flavor during promotion.
Source presence is not a support claim, and these restrictions do not promise that
experimental code is absent from the compiled APK. There is no user setting to
enable the blocked adapters in Preview or Stable.

Grand Kingdom needs physical motor, reset/reconnect and recovery acceptance.
Pegasus additionally needs a documented FOSS-compatible initialization route for
locked firmware; no manufacturer initialization key is bundled. Neither should
be enabled or listed as supported simply because the shared source is promoted.
Shared Chessnut discovery/lifecycle code remains active and must still be tested.
If the prototypes remain unmaintained long-term, review their separation/removal
as planned cleanup rather than enabling them to finish a release.

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

## Preview 2.4.0-beta.3 publication record

- Source: `50af20b6e885737a304ec9c3cddbf7a9e70495bb` ([fix #111](https://github.com/Dash1971/maia-chess-android-preview/pull/111), [release #112](https://github.com/Dash1971/maia-chess-android-preview/pull/112)). Later documentation commits do not rebuild this APK.
- Multiple premoves retain projected piece positions while each move is consumed. Highlights shrink without the intermediate jump to the real board. White/Black continuity and Maia-checkmate regressions supplement the existing queue, clock and reset tests.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38397402667): full Flutter suite, explicit Preview restrictions/settings tests, release-tool tests, native board policies, localization, static analysis and Android packaging passed.
- GitHub Linux and independent Linux unsigned APK SHA-256: `598fa2d4125d76a5eaa6d3d89dd24de693c912f5f46e9c113ffa116998b8638e`.
- Signed APK SHA-256: `8fb31648ca59fbe19eef8b0011636b407e92086a47fecf0632b9690dc57aa681`. Preview certificate remains `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- The release verification bundle records the actual signed beta.2 upgrade, real Maia play with the player Black, and saved-game regressions for variations, unfinished games, checkmate, archive restoration and force-stop/restart. Additional fixture upgrades use temporary test signatures; the published-certificate upgrade is recorded separately.
- Models, native engines and dependencies are unchanged. Beta.1's native tensor qualification is historical evidence, not a new beta.3 run. Phone visual/physical Chessnut acceptance remains with owner/testers.
- Grand Kingdom/DGT remain Dev-only. Stable 2.3.0 and Dev alpha.2 were not rebuilt or republished; no app-store changes. The release PR records temporary artifact/container cleanup.

## Preview 2.4.0-beta.4 publication record

- Source: `abdb27697b73a436fe55930dfa23c327db2aefc2` ([change #114](https://github.com/Dash1971/maia-chess-android-preview/pull/114), [release #115](https://github.com/Dash1971/maia-chess-android-preview/pull/115)). Later documentation commits do not rebuild this APK.
- Board connection/disconnection messages name recognized devices, with brand/generic fallbacks and translations in all ten languages. Readiness, stale-event protection, name retention, switching boards, Preview restrictions and narrow/large-text layouts have regression coverage.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38494899378): 911 Flutter tests, 28 explicit Preview tests, 51 release-tool tests, native board policies, localization, static analysis and Android packaging passed.
- GitHub Linux and independent Linux unsigned APK SHA-256: `acc275e020600047e82672d1f445e0dd1e8df8beed0a4e0bd7f951a7713ed420`.
- Signed APK SHA-256: `8ef36f5f9cd7f8466b614d310c79f2875da73d2853dea8b09325ac3ff4c8fd53`. Preview certificate remains `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- The release verification bundle records an actual signed beta.3 upgrade, real Maia play with the player Black, and saved-game regressions for variations, unfinished games, checkmate, archive restoration and force-stop/restart. Additional fixture upgrades use temporary test signatures.
- Models, native engines and dependencies are unchanged. Beta.1's native tensor qualification is historical evidence, not a new beta.4 run. Physical board acceptance remains with owner/testers.
- Grand Kingdom/DGT remain Dev-only. Stable 2.3.0 and Dev alpha.2 were not rebuilt or republished; no app-store changes. Release #115 records temporary artifact/container cleanup.

## Preview 2.4.0-beta.5 publication record

- Source: `074ac69f987c4f7f6d521378be70235fb826a666` ([PR #121](https://github.com/Dash1971/maia-chess-android-preview/pull/121), [issue #120](https://github.com/Dash1971/maia-chess-android-preview/issues/120)). Later documentation commits do not rebuild this APK.
- Home from restored post-game analysis now returns directly Home after process restart. Unfinished-game review retains Back to game; standalone review does not create an underlying game. Five committed navigation regressions cover these paths and ordinary background/resume.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38646968364): 921 Flutter tests (one expected flavor-specific skip), 33 explicit Preview tests, 51 release-tool tests, native board policies, localization, static analysis and Android packaging passed.
- GitHub Linux and independent Linux unsigned APK SHA-256: `1e8231c1e4f8db46c0a50857d0ef961488e16db988f039fa3058a7c10ee32296`.
- Signed APK SHA-256: `fc8d852283902d833c977c1db932fc07e6b7f3ba5d73633e3f2422142a794ceb`. Preview certificate remains `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- The actual beta.4 APK reproduced the two-tap Home defect after a background process kill. The same review checkpoint survived a real signed beta.4 → beta.5 upgrade; one-tap Home, another restart and archived moves/clocks passed. Real Maia play and additional variation, unfinished-game and checkmate upgrades also passed on the isolated ARM64 emulator. Additional fixture upgrades use temporary test signatures.
- Models, engines and dependencies are unchanged. Physical board checks were not repeated for this navigation-only fix. Grand Kingdom/DGT remain Dev-only; Stable 2.3.0 and Dev alpha.2 were not rebuilt or published. PR #121 records release verification and cleanup.

## Preview 2.4.0-beta.6 publication record

- Source: `11534b8ea58e39682f902520d17f054fc1a7fa58` ([PR #125](https://github.com/Dash1971/maia-chess-android-preview/pull/125), [issue #122](https://github.com/Dash1971/maia-chess-android-preview/issues/122)). The merge commit preserves this tested source as an ancestor with an identical tree; the release tag points to the exact built commit. Later documentation commits do not rebuild the APK.
- Optional local Maia sampling capture is off by default. Export/Clear and help are available in all ten languages. The 64 MiB FIFO store removes oldest captured games, never Recent Games/PGNs. See [sampling-data format and limits](SAMPLING_DATA.md).
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38666670956): 938 Flutter tests (one expected flavor skip), 33 Preview tests, 51 release-tool tests, native board policies, localization, static analysis and Android packaging passed.
- Independent Linux and GitHub unsigned APK SHA-256: `9ba42bafa01eac5ff7ef01c6dc27600cafb6e2b37650160f1db9f26842008c2e`.
- Signed APK SHA-256: `4211d28e5d6377eef16f946d0019268c422a18e41353307d9116f393f9c59b12`. Preview certificate remains `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- Actual Android 79M play and independent replay of document-provider exports passed for the opening and Qf5 position. Save/cancel, persisted off preference, near-capacity FIFO retention, Clear with preserved archive hashes, and interruption/restart outcomes passed. Initial feature qualification used the exact APK payload with a disposable emulator signature; official-signed play and the beta.5 → beta.6 upgrade also passed. Additional variation, incomplete-game and checkmate upgrades use temporary test signatures.
- The small interleaved 1+0 emulator sample observed no slowdown from recording (median launch-to-move about 1.76 s off, 1.63 s on; near-capacity about 1.81 s). These include launch/inference and do not establish a speedup or physical-phone guarantees.
- Models/native engines are unchanged. `crypto` 3.0.7 is the sole new Dart dependency for local checksums. Grand Kingdom/DGT remain Dev-only; Stable 2.3.0 and Dev alpha.2 are unchanged. Physical device/board acceptance remains with owner/testers. The release verification bundle and PR #125 record qualification and cleanup.

## Preview 2.4.0-beta.7 publication record

- Source: `695fd38992ab1f24e6dea85377e0767621b6cef2` ([PR #129](https://github.com/Dash1971/maia-chess-android-preview/pull/129), issues #127 and #128). The tag points to the exact built commit; later documentation does not rebuild the APK.
- Readable offline HTML reports show actual post-Temperature/Top-P probabilities, plain-language odds and charcoal/gray board diagrams. Save/Share also offers original JSONL. All ten languages are supported; there is no in-app summary screen.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38683441570): 950 Flutter tests (one expected flavor skip), 33 Preview checks, 51 release-tool tests, native board/share/document lifecycle checks, localization, static analysis and Android packaging passed.
- Independent Linux and GitHub unsigned APK SHA-256: `189b94417aa4d4e196d7c140af6fe4f89f57940ac50c1d6756e630c361994a84`.
- Signed APK SHA-256: `4efff6745427c4cdf386a11e0024e8f2d2489d2ddc1e06914f93a6aafdd5f3c4`. Existing Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- Actual signed beta.6 → beta.7 upgrade preserved app UID, saved games and captures. Real 79M play with Temperature 0.5/Top-P 0.9 and effective report probabilities passed. Native Android Save/Share, read-only receiver grants, cancellation, failed document storage, retry and reading a shared file after capture Clear passed. Additional variation, incomplete-game and checkmate upgrades use temporary test signatures.
- Android qualification found and fixed a pending Save being lost when the process died in the system picker. Forced process-death save/cancel and Activity recreation now pass on the corrected APK, with snapshot cleanup and another successful export. Fixed preparation files left by abrupt process death are bounded and removed on the next export/Clear.
- Models, engines and dependencies are unchanged. Physical phone/board acceptance remains with owner/testers. Grand Kingdom/DGT remain Dev-only; Stable 2.3.0 and Dev alpha.2 are unchanged. Release verification and task-owned cleanup are recorded in PR #129.

## Preview 2.4.0-beta.8 publication record

- Source: `23d88b585fcc16b572b6591ff3d0d10b806b9146` ([PR #131](https://github.com/Dash1971/maia-chess-android-preview/pull/131)). The release tag points to the exact built commit; later documentation does not rebuild the APK.
- HTML and JSONL keep the latest ten recorded games, including unfinished games, newest first. Compact game headings show known players/results/openings/time controls and the original start date; HTML adds jump links. Only results use the shared Recent Games colors. The 64 MiB safeguard remains and never deletes Recent Games/PGNs.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38697125351): 957 Flutter tests (one expected flavor skip), 33 Preview checks, 51 release-tool tests, native policy/lifecycle checks, localization, static analysis and Android packaging passed. Browser checks covered ten languages at three widths.
- Independent Linux and GitHub unsigned APK SHA-256: `81dc4d969a5639f354522e2986c3737e72d261172a7474b8fe693a9b17cec5d6`.
- Signed APK SHA-256: `385b869d01c3dc453bf85f204568fdbb6ec7281db217562c8ae3baff4c28c762`. Existing Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
- Actual signed beta.7 → beta.8 upgrade preserved UID, saved games and capture files. Real 79M play with history off/on, game metadata, twelve-to-ten retention, result perspective, matching HTML/JSONL exports, Save/Share, cancellation, failed document storage and retry passed. Additional variation, unfinished-game and checkmate upgrades use temporary test signatures.
- Regression tests cover resumed/evicted games, terminal human/forced results, stale inference metadata, and concurrent Settings storage loading/enabling. Unknown metadata remains unknown. Models, native engines and dependencies are unchanged.
- Grand Kingdom/DGT remain Dev-only; Stable 2.3.0 and Dev alpha.2 are unchanged. Physical phone/board acceptance remains with owner/testers. PR #131 records public-download verification and task-owned cleanup.
