# Preview 2.5.0-beta.4 qualification

Published [Preview 2.5.0-beta.4](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.4), code **2504**, from `0ccdaa0150feb615139947052859cc249087d4cf` through [release PR #169](https://github.com/Dash1971/maia-chess-android-preview/pull/169), after reviewed/merged #168. The release merge tree equals the qualified source. Later documentation does not rebuild the APK.

Navigation in Game Review/imported-PGN analysis now cancels selection, destination dots, held drags and promotion state. A fresh touch works immediately. Ordinary engine updates preserve selection, while played moves retain their tap/drag animation path. Gameplay algorithms, defaults, models and engine versions are unchanged.

## Verification

- [Exact-source host and Android CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/39699722944): 1131 host tests passed, three explicit skips; Preview/channel/native-policy, localization, static and release-tool checks passed. Five focused gesture regressions passed during review.
- Full exact-source ARM64 Android 16 Preview native suite: 16 passed, including real 79M numerical references, Stockfish, storage, variations and lifecycle behavior. Expanded corpora: 3,000 chess positions and 512 variation trees through four round trips.
- Independent Ubuntu and GitHub unsigned APK SHA-256: `5e6fb02e3537c621005b3115319d42d54598414f61428f759c87f48a026f30d0`.
- Signed/public APK SHA-256: `edd0b8bddf1581f30ee48047e9d085339002f0de72c1dcdcb63c4df38f1e11a4`. Established Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction was byte-identical.
- Actual signed beta.3 → beta.4 upgrade preserved UID, preferences, games and sampling files. Signed release APKs reproduced the original legal-dot defect in beta.3 and confirmed clearing plus fresh selection in beta.4. Real 79M opening/middlegame play and annotated-variation, unfinished-game and checkmate upgrade/restart fixtures passed.
- Public APK, compact verification bundle and checksums matched qualified hashes and GitHub asset digests. The public APK's signature/model/payload comparison was repeated after merge. The public verification receipt is attached to the release and was independently downloaded and compared.

The first CI build received an empty NNUE download after a connection failure; the integrity guard rejected it. The fresh exact-source run passed without checksum/source changes. Independent-container monitor bootstrap was corrected without changing application source. [Dated upstream review](../dependency-audit-2026-10-22.md) records available updates, advisories and deferrals; 64 exact-version OSV queries returned no finding. No shared tooling change required a Stable companion PR; Stable's cleanup helper was inspected and already matched Preview.

## Scope and cleanup

Stable 2.4.0 and Dev are unchanged. Grand Kingdom/DGT remain Dev-only. Physical phones/vendor rendering and Chessnut still need tester acceptance. No translation review was repeated and Preview requires no screenshot-maintenance pass.

Immediately after public-download verification, task processes/emulator were stopped and the checked workspace cleaner removed task bulk, APK/archive copies, virtual environments, emulator data and checkout intermediates on every host. Completed task source/model checkouts and the Linux container were retired; shared SDK/JDK/Flutter/Gradle/pub installations, useful shared LFS caches and secure signing keys were preserved. Compact reports/commands/hashes remain in the release and release PR. README/roadmap updates followed cleanup; the documentation checkout contained source pointers only.
