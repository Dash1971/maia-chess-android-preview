# Preview 2.5.0-beta.6 qualification

Published [Preview 2.5.0-beta.6](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.6), code **2506**, from `8ba0cae62692535d3e6a554e58d9d72f61cb129c` through [release PR #175](https://github.com/Dash1971/maia-chess-android-preview/pull/175), after reviewed/merged #174. The merge tree equals the qualified source. Later documentation does not rebuild the APK.

Hold Right inside an analysis variation selects one main-line move after the outermost branch point, matching Hold Left followed by one normal Right tap. The destination is independent of variation length, nesting and selected move, and clamps at the game end. Hold Left, ordinary taps and main-line endpoint holds are unchanged.

## Verification

- [Exact-source host and Android CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/39858160755): 1154 host tests passed, three explicit skips. Channel/native-policy, localization, static and release-tool checks passed. Review also passed 34 focused navigation tests.
- Full exact-source ARM64 Android 16 Preview native suite: 16 passed, including real 79M numerical references, Stockfish, storage, variations and lifecycle behavior. Expanded corpora: 3,000 chess positions and 512 variation trees through four round trips.
- Independent Ubuntu and GitHub unsigned APK SHA-256: `169f358dbd9174dcbb481b42dc897a1ba0c56fc864f1c10ebc7eb70cccd905e3`.
- Signed/public APK SHA-256: `0c01a6ec8faa4df2bee8a604e0e71c77e7e08e2a379bfbc626a7b3b6b7df9905`. Established Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction was byte-identical.
- Actual signed beta.5 → beta.6 upgrade preserved UID, preferences, games and sampling files. Signed APK checks covered disabled boundary taps, Left branch-point and Right next-main-line destinations for top-level/nested branches, selected main-line move and subsequent main-line stepping. Real 79M opening/middlegame play and annotated-variation, unfinished-game and checkmate upgrade/restart fixtures passed.
- Public APK, compact verification bundle and checksums matched qualified hashes and GitHub digests. Public APK signature/model/payload verification passed; the published verification receipt was independently downloaded and compared.

[Fresh upstream review](../dependency-audit-2026-10-23-preview-beta6.md) records available updates, advisories and deferrals; 64 exact-version OSV queries returned no finding. No dependency change was required; staged Dart TLS/certificate changes were investigated for offline-app applicability. No shared tooling change required a Stable companion PR; Stable's cleanup helper was inspected and matched Preview.

## Scope and cleanup

Stable and Dev remain unchanged. Grand Kingdom/DGT remain Dev-only. Physical phones/vendor rendering and Chessnut remain tester acceptance. No catalogs changed or translation review was repeated; automated localization contracts passed. Preview requires no screenshot-maintenance pass.

Immediately after public-download verification, task processes/emulator were stopped and the checked cleaner removed task bulk, APK/archive copies, virtual environments, emulator data and intermediates on all three hosts. Completed source/model checkouts and the Linux container were retired. Shared SDK/JDK/Flutter/Gradle/pub installations, useful LFS caches and secure signing keys were preserved. Compact reports/commands/hashes remain with the release and release PR. The inspected public pip CA bundle was retained separately as a public certificate bundle; it contains no private key. README/roadmap documentation followed cleanup in a source-only checkout.
