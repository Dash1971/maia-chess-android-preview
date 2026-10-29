# Build channels and promotion status

Updated 2026-10-29. Release pages are authoritative for published artifacts;
source on a branch alone is not an installed release. Each release PR records
its exact source SHA, tests, hashes, signing identity and remaining limitations.

| Channel | Version / status | Package and model | Scope |
| --- | --- | --- | --- |
| [Stable](https://github.com/Dash1971/maia-chess-android/releases) | Published [2.5.1](https://github.com/Dash1971/maia-chess-android/releases/tag/v2.5.1), code 83 | `com.dash1971.maia_chess`, 79M | Production app; use Stable's release guide for GitHub, Zapstore and F-Droid. |
| [Preview](https://github.com/Dash1971/maia-chess-android-preview/releases) | Published [2.5.0-beta.11](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.11), code 2511 | `com.dash1971.maia_chess.preview`, 79M | Custom-position crash fix; prior 2.5 features are released in Stable. Grand Kingdom/DGT stay disabled. |
| [Dev](https://github.com/Dash1971/maia-chess-android-preview-dev/releases) | 2.6.0-alpha.1-dev, code 2601: local qualification in progress | `com.dash1971.maia_chess.preview.dev`, 5M, red icon | Latest Preview base (containing Stable 2.5.1 fixes), PR #209 assisted Maia promotion and PR #210 assisted image import. Capture failures remain unresolved. |

The three packages install side by side. Obtainium users should select the
intended repository and enable prereleases for Preview/Dev. Installing Preview
does not upgrade Dev or transfer its saved games/preferences. Existing Preview
installations update in place using the established Preview certificate.

## Release instructions

- [Stable release procedure](https://github.com/Dash1971/maia-chess-android/blob/main/docs/RELEASING.md):
  full qualification, stores and post-release README/feature/screenshot updates.
- [Preview and Dev release procedure](https://github.com/Dash1971/maia-chess-android-preview/blob/main/docs/RELEASING.md):
  Preview upstream review and README/roadmap pass; lightweight Dev publication
  by default, with no published-download check.

## Grand Kingdom: proposed 2.6 enablement

The 2.6 draft source allows Grand Kingdom discovery, connection and session-bound
motor commands in Preview/Dev. DGT remains Dev-only and Stable/unflavored builds
exclude both. Published Preview/Stable versions above are unchanged. See the
[2.6 acceptance record](ELECTRONIC_BOARD_GRAND_KINGDOM_26.md) for the initial positive Dev
hardware report, later capture failures and draft/release boundary. Keep this feature
out of the 2.5 maintenance cycle.

## Assisted image import: 2.6 draft

The proposed 2.6 source adds From image in the Preview/Dev board editor with a
bundled MIT diagram classifier, adjustable crop/orientation and a separate manual
review draft. It is being qualified for the Dev snapshot above; published Preview/Stable artifacts are unchanged.
[Workflow, provenance and pending acceptance](BOARD_IMAGE_IMPORT.md) distinguish
this assisted prototype from broad recognition readiness and Stable promotion.
No camera or new storage/media/network permission is included.

## Preview acceptance

- Use move history remains off by default, with its own information button.
  The updated help explains the measured prediction improvement, unestablished
  strength gain and off recommendation, with a research link. Saved sessions
  continue to retain their recorded mode. All ten languages are covered.
- Chessnut: bounded diagnostics and decoder recovery, single/multiple-board
  discovery, remembered selection, session/lifecycle protection, and NEW GAME
  confirmation by a second deliberate press within 2.5 seconds.
- Board sounds remain under **Chessnut**, because the buzzer commands are
  Chessnut-specific. Other brands must not imply equivalent sound support.
- Published Preview 2.5 excludes Grand Kingdom and DGT. The proposed 2.6 source
  admits only Grand Kingdom experimentally, with matching Dart/native gates and
  motor-session checks. DGT stays Dev-only. Remaining physical acceptance and
  full Preview qualification are required before release.
- Qualify the actual 79M Preview APK, including history on/off, inference,
  upgrade/data retention, help layout and package/signature continuity. Dev's
  5M measurements are not evidence of 79M performance.
- Physical Chessnut acceptance remains with the owner/testers. Automated tests
  cannot confirm radio reliability, physical LEDs or button behavior on hardware.

## Preview 2.5.0-beta.11 qualification

[PR #206](https://github.com/Dash1971/maia-chess-android-preview/pull/206) fixes a crash when analyzing certain custom positions. The same fix is released in [Stable 2.5.1](https://github.com/Dash1971/maia-chess-android/releases/tag/v2.5.1). [Release verification and cleanup](https://github.com/Dash1971/maia-chess-android-preview/pull/206#issuecomment-6437920899) record final-source CI, matching independent Linux APKs, real-engine Android regressions and an actual signed upgrade with an unsafe saved position, preserving games and settings. Existing 2.5 Chessnut physical acceptance was reported by the owner before promotion; this hotfix was tested on an emulator and makes no new hardware-support claim. Dev remains unchanged.

## Preview 2.5.0-beta.10 qualification

Published through [PR #201](https://github.com/Dash1971/maia-chess-android-preview/pull/201) after reviewed #198/#199 and an ownership regression correction. Maia score circles/percentages use aligned columns with 8 dp after the rating and 4 dp after the circle. Continue from here can connect to or reuse a Chessnut board, then wait for the selected physical position before untimed play. Full FEN, side, castling/en-passant rights, rating and validated history are retained; phone continuation remains available. [Qualification](releases/preview-2.5.0-beta.10.md) records exact-source CI, independent Linux equality, signing, full native suite, controlled-board/real 79M continuation, signed beta.9 upgrade, actual APK checks and cleanup. Physical Chessnut acceptance is explicitly pending the requester’s testing with this Preview. Stable/Dev releases are unchanged.

## Preview 2.5.0-beta.9 qualification

Published through [PR #196](https://github.com/Dash1971/maia-chess-android-preview/pull/196) after reviewed #195. Maia rating labels and score columns stay anchored through loading, missing results, changing percentages and terminal positions. Rating visibility uses reserved space rather than the current inference result; narrow screens and large text keep the compact presentation and accessible details. [Qualification](releases/preview-2.5.0-beta.9.md) records exact-source CI, independent Linux equality, production signing, full native suite, signed beta.8 upgrade, score anchoring checks and completed cleanup. Stable and Dev releases are unchanged.

## Preview 2.5.0-beta.8 qualification

Published through [PR #193](https://github.com/Dash1971/maia-chess-android-preview/pull/193) after reviewed #188/#190/#191/#192. Configurable board aids, 25 offline board designs and 16 audited piece sets, a graphical board editor, and optional Maia expected-score text in the existing analysis title bar. Existing users retain Brown/Cburnett and prior aid behavior; the score display defaults off. [Qualification](releases/preview-2.5.0-beta.8.md) records exact-source CI, independent Linux equality, signing, full native suite, signed beta.7 upgrade, feature checks and completed cleanup. Stable and Dev releases are unchanged.

## Preview 2.5.0-beta.7 qualification

Published through [PR #184](https://github.com/Dash1971/maia-chess-android-preview/pull/184) after reviewed #183. Engine help now offers one scrollable approved Temperature and Top-P explanation in all ten languages. The Simple/Technical selector is removed. Shorter move-history help retains its research link and recommendation to leave history off. Sampling behavior, defaults and saved preferences are unchanged. Patched Flutter 3.47.8 / Dart 3.13.7 address the TLS advisory. [Qualification](releases/preview-2.5.0-beta.7.md) records exact-source CI, independent Linux equality, signing, full native suite, signed beta.6 upgrade, help smoke and completed cleanup. [Stable companion #61](https://github.com/Dash1971/maia-chess-android/pull/61) was draft at beta.7 publication and subsequently merged separately; Stable and Dev releases are unchanged.

## Preview 2.5.0-beta.6 qualification

Published through [PR #175](https://github.com/Dash1971/maia-chess-android-preview/pull/175) after reviewed #174. Hold Right inside an analysis variation selects one main-line move after the outermost branch point, matching Hold Left followed by one normal Right tap. The destination is independent of variation length, nesting and selected move, and clamps at the game end. Hold Left, ordinary taps and main-line endpoint holds are unchanged. [Qualification](releases/preview-2.5.0-beta.6.md) records exact-source CI, independent Linux equality, full 79M native suite, signed beta.5 upgrade, changed-feature checks and completed cleanup. Stable and Dev remain unchanged.

## Preview 2.5.0-beta.5 qualification

Published through [PR #172](https://github.com/Dash1971/maia-chess-android-preview/pull/172) after reviewed #171. Analysis arrows step along the current line. At a side-variation end, Right is dimmed for tapping while either arrow can be held to return to the outermost main-line branch point. The corresponding move stays selected and further taps follow the main line. Main-line holds retain their beginning/end behavior; live-game navigation is unchanged. [Qualification](releases/preview-2.5.0-beta.5.md) records exact-source CI, independent Linux equality, full 79M native suite, signed beta.4 upgrade, changed-feature checks and completed cleanup. Stable and Dev remain unchanged.

## Preview 2.5.0-beta.4 qualification

Published through [PR #169](https://github.com/Dash1971/maia-chess-android-preview/pull/169) after reviewed #168. Analysis navigation clears selection/destination dots and cancels held gestures/promotion without changing ordinary move interactions. [Qualification](releases/preview-2.5.0-beta.4.md) records the dated upstream review, exact-source CI, independent Linux equality, full 79M native suite, signed beta.3 upgrade and actual-APK defect reproduction/fix. Stable and Dev remain unchanged.

## Preview 2.5.0-beta.3 qualification

Published through [PR #164](https://github.com/Dash1971/maia-chess-android-preview/pull/164) after #162. The completed translation review is included without repetition; clearer theme names and consistent chess/sampling terminology do not change gameplay or defaults. [Qualification](releases/preview-2.5.0-beta.3.md) records exact-source CI, independent Linux reproduction, full Preview native checks and signed beta.2 upgrade. Stable and Dev remain unchanged.

## Preview 2.5.0-beta.2 qualification

Published through [PR #160](https://github.com/Dash1971/maia-chess-android-preview/pull/160).
Darker neutral panels apply only to pure-black dark mode. The strength notices
omit “From move 6”, and the approved Simple explanation is updated in all ten
languages. Engine behavior, defaults, stored games and other themes are unchanged.
[Qualification](releases/preview-2.5.0-beta.2.md) records final-source CI,
independent build equality, signed beta.1 upgrade and Android 16 checks.
Stable 2.4.0 and Dev remain unchanged.

## Preview 2.5.0-beta.1 qualification

Published from `ffe8032c7082170b310013a66af59b74a7f7a0ad` after combining #156 and
#157 through #158. Appearance remains green/dark by default; Light/System,
Android system colors and OLED black are optional. Fresh sampling defaults are
1.0/0.95 with opening variety on; explicit saved preferences and frozen game
profiles are preserved. Primary analysis defaults to 1500; optional secondary
Maia defaults to 2600 and remains disabled until selected.

[Release verification](releases/preview-2.5.0-beta.1.md) records exact-source CI,
independent Linux reproduction, signed upgrade, Android 11/16 appearance and
actual 79M sampling/lifecycle checks. No Stable/F-Droid/Zapstore or Dev promotion
is implied by this Preview release.

## Opening-variety candidate for Stable 2.4 (historical)

Beta.15 (2417) is published for #152, superseding beta.14 as the intended
final candidate. It adds optional full sampling through move 5, then the user's
configured Temperature/Top-P from move 6. New games freeze their sampling
configuration; older saves never silently opt in. JSONL records effective and
configured values, while HTML uses the existing effective probability display.
No new inference, model, engine or board-support changes. Exact-source CI,
independent Linux build comparison and signed Android qualification passed. This candidate was subsequently promoted to the published Stable 2.4.0 release.

## Beta.14 baseline for Stable 2.4

Preview 2.4.0-beta.14 (2416) combines the approved engine help in all ten
languages, shared Chessnut behavior across Preview/Stable, and the verified
Gradle 9.8.1 security update. Grand Kingdom and DGT remain Dev-only. The balanced
play example now recommends Temperature 1.0 and Top-P 0.95. Settings defaults,
models and sampling behavior are unchanged.

The release PR records exact-source CI, independent Linux reproduction, signed
upgrade and Android checks before publication. After owner acceptance, Stable
2.4 should promote this app behavior and qualified toolchain; a newly discovered
app fix requires another tested Preview candidate. Stable packaging, metadata,
signing and F-Droid/Zapstore release checks remain separate obligations.

## Stable 2.4 promotion boundary

A Stable 2.4 release can proceed with Chessnut support while Grand Kingdom and
Pegasus remain unaccepted Dev prototypes. Keep both Dart and native flavor gates
and their regression tests; verify the actual production flavor during promotion.
The shared connection flow must not depend on the Dev/Preview flavor name:
Stable receives the same Chessnut discovery, remembered selection, notification
reassembly, physical NEW GAME handling and stale-session protection. Only
`BoardChannelPolicy` and the Dev-only motor-command guard restrict experimental
board families. Extra bounded packet-error detail can remain Preview/Dev-only;
that diagnostic verbosity switch must not change connection behavior.

The CI Stable board regression uses the actual Dart platform transport (with
mocked native messages), including multiple Chessnut candidates and rejection of
Pegasus/Grand Kingdom, plus an older saved Chessnut game without a board identity.
Native reconnect policy starts a fresh Chessnut-only search for that older save
instead of rejecting it or reusing an unrelated connection. Preserve these tests
when promoting the workflow. The
current Stable app is unflavored: Android packaging, real upgrade/restore and
hardware qualification still need to use the final Stable build, not just the
Preview test flavor. Preserve Stable's release/security/store workflows and
package identity; do not overwrite them with Preview's build scaffolding.

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

Stable 2.4.0 and this Preview use the reviewed Gradle 9.8.1 pin that addressed
the findings in the [2026-10-17 upstream review](dependency-audit-2026-10-17.md).
Preserve the security pin; a passing automated advisory query alone does not
override upstream advisories when considering later upgrades.

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

## Preview 2.4.0-beta.9 publication record

- Source: `1a7fc2e05e32e76de549f7228cd7e53eb2b153cc` ([PR #135](https://github.com/Dash1971/maia-chess-android-preview/pull/135), issue #134). The tag points to the exact built commit, preserved unchanged in the merge. Later documentation does not rebuild the APK.
- Clearing sampling data requires an explicit Delete data confirmation in all ten languages. Cancel, Back and outside dismissal preserve captures; guards prevent duplicate actions and overlapping exports. Large-text confirmation/help layouts are covered.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38724036354) passed 962 Flutter tests (one expected flavor skip), 33 Preview checks, 51 release-tool tests, native policies/lifecycle, localization, static analysis and Android packaging.
- Independent Linux and GitHub unsigned APK SHA-256: `c745cc7062b02dc842959fec290935b6d13fd7a604bd63b2d00f25c3a28e9437`.
- Signed APK SHA-256: `30f8f8604b6c39c738e182ff5a8f8908dbd1e56fd18520de563363077438c1c8`. Existing Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- Actual signed beta.8 → beta.9 upgrade preserved UID, saved games and captures. Android confirmation Cancel/Back/outside dismissal preserved capture bytes. Delete cleared only captures, kept saved games/exported HTML/recording preference, survived restart, and allowed recording real Maia moves again. Widget regressions additionally cover repeated taps, export exclusion and failure/retry.
- Models, engines and dependencies are unchanged. Physical phone/board acceptance remains with owner/testers. Grand Kingdom/DGT remain Dev-only; Stable 2.3.0 and Dev alpha.2 are unchanged. PR #135 records public-download verification and task-owned cleanup.

## Preview 2.4.0-beta.10 publication record

- Source: `a8cc2bee2ead6cf663e0863a362d7ff007b7329a` ([PR #138](https://github.com/Dash1971/maia-chess-android-preview/pull/138), issue #137). The tag points to the exact built commit, preserved unchanged in the merge. Later documentation does not rebuild the APK.
- Settings groups premove suboptions, separates analysis controls, gives move history dedicated help and combines sampling export/delete actions. The move-history advice, defaults, preference keys, storage and gameplay remain unchanged. All ten languages have layout coverage at 320px and 200% text, independent help/switch accessibility and explicit reset scope.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38820271332) passed 964 Flutter tests (one expected flavor skip), 33 Preview checks, 51 release-tool tests, native policies/lifecycle, localization, static analysis and Android packaging.
- Independent Linux and GitHub unsigned APK SHA-256: `8a0afc9f978fc333fb3c39c9e9d4997739a7d9c3941a8a5aa2771e5c9040c389`.
- Signed APK SHA-256: `12457cb5d25acedf2ea5602dcea6bb36628f9a207a35420aa0a1d3df4d36b779`. Existing Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- Actual signed beta.9 → beta.10 upgrade preserved UID, saved game, preferences and captures. Android checks covered independent help buttons, unchanged advice, analysis grouping, persistent reset, HTML saving, HTML/JSONL sharing, read-only grants, document-provider failure/retry, confirmation dismissal/deletion, saved-game/export preservation and real Maia recording after Clear.
- Models, engines and dependencies are unchanged. Grand Kingdom/DGT remain Dev-only; Stable 2.3.0 and Dev alpha.2 are unchanged. Physical phone/board acceptance remains with owner/testers. PR #138 records public-download verification and cleanup of task-owned builds, APKs, signing workspace and emulator data.


## Preview 2.4.0-beta.11 publication record

- Source: `d99724a33d82fc2c88cdfccd854cb8ce0708da97` ([PR #140](https://github.com/Dash1971/maia-chess-android-preview/pull/140)). The tag points to the exact built commit, preserved unchanged in the merge. Later documentation does not rebuild the APK.
- Research report links are distinct from JSONL export labels and identify English in non-English screens. Sampling help and reports clarify that the last ten recorded games are saved and shown newest first. All ten languages are updated.
- Reset settings to default sits above Diagnostics, requires explicit confirmation and resets every option on the Settings screen, including language, sounds and sampling recording. Saved games, captures and Home game-setup selections remain intact. Cancel, Back and outside dismissal leave settings unchanged.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38831749684) passed host regressions, explicit Preview checks, release-tool tests, native policies/lifecycle, localization, static analysis and Android packaging.
- Independent Linux and GitHub unsigned APK SHA-256: `694025a9a65e1022db6ebb9ade7165228b0867a5d6cb7669353ceccb5cc2ff93`.
- Signed APK SHA-256: `ccf8603c0c2c600bc9145a066cadc3cbe6598ffba159983df945529239f71dac`. Existing Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- Actual signed beta.10 to beta.11 upgrade on ARM64 Android emulator: UID, game, captures and preferences preserved. Research/export labels, confirmation Cancel/Back/outside dismissal, reset to all Settings defaults, language to system, restart persistence and byte-preserved saved games/captures passed. Real 79M inference with history off/on passed on both versions. Host tests cover all ten languages at large text and failure/retry.
- Models, engines and dependencies are unchanged. Grand Kingdom/DGT remain Dev-only; Stable 2.3.0 and Dev alpha.2 are unchanged. Physical phone/board acceptance remains with owner/testers. PR #140 records public-download verification and task-owned build/APK/emulator cleanup.

## Preview 2.4.0-beta.12 publication record

- Source: `2267d2eafc9b3ab2d1748528160939b0ffc41811` ([PR #143](https://github.com/Dash1971/maia-chess-android-preview/pull/143), issue #142). The tag points to the exact tested build source, preserved in the merge. Later documentation does not rebuild the APK.
- Opening names stay on one line. Only truncated names show an information icon and open a localized, scrollable full-name dialog. Close, Back and outside dismissal preserve the board/selected position. Names that fit have no icon/action. Large-text layouts reserve usable move-list space.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38973973243) passed host regressions, explicit Preview checks, release-tool tests, native policies/lifecycle, localization, static analysis and Android packaging.
- Independent Linux and GitHub unsigned APK SHA-256: `a7f44d5c2530e86a71a6218afe3697206e65a316b2ec441ab5f57801432bcccb`.
- Signed APK SHA-256: `62e79bcb4bb403c7e6995f4b9d752eeea6fe874a94178b3eafdcb72ba01be761`. Existing Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- Actual signed beta.11 to beta.12 upgrade on ARM64 Android emulator: UID, saved game, captures and preferences preserved. Opening details checked at normal, narrow, large-text and landscape layouts, with short names and both longest names; complete accessibility labels, conditional details action, dialog dismissal, navigation, background and process restart. Real 79M inference with history off/on passed. Host tests cover all ten dialog languages, precise truncation boundary, navigation, semantics, and large-text layouts.
- Models, engines and dependencies are unchanged. Grand Kingdom/DGT remain Dev-only; Stable 2.3.0 and Dev alpha.2 are unchanged. Physical phone/board acceptance remains with owner/testers. PR #143 records public-download verification and task-owned build/APK/emulator cleanup.

## Preview 2.4.0-beta.13 publication record

- Source: `0a030a37d0eee4b3562c3e517a5f9b9f11523d28` ([PR #145](https://github.com/Dash1971/maia-chess-android-preview/pull/145)). The tag points to the exact tested build source, preserved in the merge. Later documentation does not rebuild the APK.
- Short and truncated opening names use the same compact row height. Showing the information action no longer pushes the engine panel and move list down. The whole truncated row remains tappable; larger accessibility text receives consistent space in both cases.
- Temperature/Top-P help uses the maintainer-approved explanation in all ten languages, retaining local chess terminology and the English-language research labels. Old example-list translations were removed; defaults and sampling behavior are unchanged.
- [Release CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38983471315) passed host regressions, explicit Preview checks, release-tool tests, native policies/lifecycle, localization, static analysis and Android packaging.
- Independent Linux and GitHub unsigned APK SHA-256: `b92014255fdd5c9345f7443145486eb6228832d73444fa87f781f40ee8fc210e`.
- Signed APK SHA-256: `6c7f1bba47e7b3cb1d96b9059c7aaea65e3463bf0f01946cd250002ca9a75be6`. Existing Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- Actual signed beta.12 to beta.13 upgrade on ARM64 Android emulator preserved UID, saved game, captures and preferences. Short/long/short opening checks at portrait, narrow, 200% text and landscape verified an unchanged engine-panel position. Text/icon taps, dialog dismissal, navigation, background/resume and process restart passed. Real 79M inference with history off/on passed. Eight new widget regressions verify stable row/following-content geometry (six reproduced the old jump before the fix) at four text sizes with normal/bold text. Approved sampling help is translated in all ten languages. Expanded help passed 320px/200% widget checks in all ten locales and English/Japanese actual-APK scrolling, research-label, dismissal and unchanged-settings checks.
- Models, engines and dependencies are unchanged. Grand Kingdom/DGT remain Dev-only; Stable 2.3.0 and Dev alpha.2 are unchanged. Physical phone/board acceptance remains with owner/testers. PR #145 records public-download verification and task-owned build/APK/emulator cleanup.


## Preview 2.4.0-beta.14 publication record

- Source: `49058a541132bb61312b7d8071c07f1b84c3a01a` ([release #150](https://github.com/Dash1971/maia-chess-android-preview/pull/150), changes #147, #148 and #149). The tag points to the exact built commit, preserved unchanged in the merge. Later documentation does not rebuild the APK.
- Approved Temperature/Top-P, history and sampling-data help in all ten languages; the balanced-play example is Temperature 1.0 / Top-P 0.95. Shared Chessnut behavior is ready for Stable promotion, including legacy reconnect without a saved board identity. Models, engines, settings defaults and sampling behavior are unchanged.
- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/38989883544): 1,036 Flutter tests (three expected flavor-specific skips), 35 Preview checks, eight Stable/empty-flavor checks, 57 release-tool tests, native policies, localization, static analysis and Android packaging passed.
- Independent Linux and GitHub unsigned APK SHA-256: `8b1be3db1a6170c9adee3db9a5503f535a2a742a73008db5e123924d2d6ed127`.
- Signed APK SHA-256: `02df25aafd7b94bac1ef24dbcb61df4ef8f41a95ee53e24675233a6fbea7f818`. Established Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- Actual signed beta.13 upgrade preserved UID, settings, saved games and captures. Opening rows retained engine-panel position across short/long/short names in four layouts, including 200% text; navigation, resume and restart passed. All three updated help dialogs passed English/Japanese actual-APK text, scrolling, dismissal and unchanged-settings checks. Real 79M inference with history off/on passed.
- Gradle 9.8.1 replaces the vulnerable 9.3.1 pin, with an official checksum and offline CI/build guard. The [Stable companion's canonical F-Droid build/scans](https://github.com/Dash1971/maia-chess-android/pull/53#issuecomment-6228113567) also reproduced its CI APK exactly. That compatibility test does not replace final Stable 2.4 release qualification.
- Grand Kingdom/DGT remain Dev-only; Stable 2.3.0 and Dev alpha.2 were not rebuilt or published. Owner phone/Chessnut testing remains the final acceptance step before Stable promotion. The release verification bundle and PR #150 record public-download verification and task-owned cleanup.


## Preview 2.4.0-beta.15 publication record

- Source: `48a4d0a57f501923d43cc14248ef291a05e915f0` ([PR #153](https://github.com/Dash1971/maia-chess-android-preview/pull/153), issue #152 split from #97). The tag points to the exact tested build source; the merge preserves an identical tree. Later documentation does not rebuild the APK.
- Optional **Max variety in opening** uses Temperature/Top-P 1.0/1.0 through move 5 for both colors, then the configured settings from move 6. It is off by default and disabled/off at default 1.0/1.0. New games retain their sampling profile; old saves never silently opt in. Ten-language help, effective/configured capture metadata, takeback/Continue from here and Chessnut reset coverage are included. Analysis probabilities and model/engine defaults are unchanged; no extra inference is introduced.
- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/39024551581): 1,072 Flutter tests (three expected flavor skips), 37 Preview checks, eight Stable/empty-flavor checks, 57 release-tool tests, native policies, localization, static analysis and Android packaging passed.
- Independent Linux and GitHub unsigned APK SHA-256: `f84f9e16d5c3583c42b17cfd6934a15bf2d2fac23149be97abf30eae56be45f3`.
- Signed APK SHA-256: `c6934e3c1a0d0ecd798b7a5806122c80b8c1a22bc226a67a21df716a185887c6`. Established Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- Actual signed beta.14 upgrade preserved UID, settings, saved games and captures. Real 79M sampling verified both colors at moves 5/6, frozen restored settings despite changed global preferences, legacy no-opt-in, new Home-game settings and restart persistence. Actual APK English/Japanese UI checks verified disabled defaults, independent help, enabling via slider, persistence and localized help dismissal. All ten languages passed narrow/large-text host regression checks.
- Public APK and verification downloads were checked against local hashes and GitHub asset digests. The release contains compact evidence and the standalone emulator harness; test fixtures/harness are not bundled in the APK. Physical phone/Chessnut acceptance remains with owner/testers. Functional qualification does not establish increased strength or an optimal opening cutoff.
- Grand Kingdom/DGT remain Dev-only. Stable 2.3.0 and Dev alpha.2 are unchanged; no Stable/store publication. PR #153 records task-owned build, APK and emulator cleanup. Shared toolchains/caches and signing keys are retained.

## Preview 2.5.0-beta.1 publication

Combines Appearance #156 and sampling defaults/help #157. Existing installs keep
their saved settings and the original dark green theme. New/reset engine defaults
are Temperature 1.0, Top-P 0.95 and opening variety on; primary analysis is 1500
and the optional second engine is 2600. Play already defaults to 1500. Appearance
is below Language and adds Light/Dark/System, system colors and pure black.

Published after exact-source Linux CI, independent reproduction, signed upgrade
and Android appearance/settings qualification. The release PR and linked
verification record contain the final evidence. Preview package,
79M model, signing identity and experimental-board restrictions remain unchanged.
Stable 2.4 and Dev alpha.2 are not part of this publication.
