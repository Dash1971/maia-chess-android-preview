# Preview 2.5.0-beta.5 qualification

Published [Preview 2.5.0-beta.5](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.5), code **2505**, from `f58cebbad5a8fd30ae5ac205c46a8317d4de97c9` through [release PR #172](https://github.com/Dash1971/maia-chess-android-preview/pull/172), after reviewed/merged #171. The merge tree equals the qualified source. Later documentation does not rebuild the APK.

Analysis arrows step along the current line. At a side-variation end, Right is dimmed for tapping while either arrow can be held to return to the outermost main-line branch point. The corresponding move stays selected and further taps follow the main line. Main-line holds retain their beginning/end behavior; live-game navigation is unchanged.

## Verification

- [Exact-source host and Android CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/39748479482): 1145 host tests passed, three explicit skips. Channel/native-policy, localization, static and release-tool checks passed. Review also passed 134 focused navigation tests.
- Full exact-source ARM64 Android 16 Preview native suite: 16 passed, including real 79M numerical references, Stockfish, storage, variations and lifecycle behavior. Expanded corpora: 3,000 chess positions and 512 variation trees through four round trips.
- Independent Ubuntu and GitHub unsigned APK SHA-256: `921a4d99a748f9b79c696fc9bb573a9e6d4f4516587571d40020a947734e5acd`.
- Signed/public APK SHA-256: `3825153f1e54e08c53253b926e8be89540449b8f404e8721ed0116ea775ff469`. Established Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction was byte-identical.
- Actual signed beta.4 → beta.5 upgrade preserved UID, preferences, games and sampling files. Signed APK checks covered disabled boundary taps, both hold controls for top-level/nested branches, selected main-line move and subsequent main-line stepping. Real 79M opening/middlegame play and annotated-variation, unfinished-game and checkmate upgrade/restart fixtures passed.
- Public APK, compact verification bundle and checksums matched qualified hashes and GitHub digests. Public APK signature/model/payload verification passed; the published verification receipt was independently downloaded and compared.

[Fresh upstream review](../dependency-audit-2026-10-22-preview-beta5.md) records available updates, advisories and deferrals; 64 exact-version OSV queries returned no finding. No dependency change was required. No shared tooling change required a Stable companion PR; Stable's cleanup helper was inspected and matched Preview.

## Scope and cleanup

Stable and Dev remain unchanged. Grand Kingdom/DGT remain Dev-only. Physical phones/vendor rendering and Chessnut remain tester acceptance. The completed translation review was not repeated; the newly added main-line noun and automated localization contracts were checked. Preview requires no screenshot-maintenance pass.

Immediately after public-download verification, task processes/emulator were stopped and the checked cleaner removed task bulk, APK/archive copies, virtual environments, emulator data and intermediates on all three hosts. Completed source/model checkouts and the Linux container were retired. Shared SDK/JDK/Flutter/Gradle/pub installations, useful LFS caches and secure signing keys were preserved. Compact reports/commands/hashes remain with the release and release PR. The inspected public pip CA bundle was retained separately as a public certificate bundle; it contains no private key. README/roadmap documentation followed cleanup in a source-only checkout.
