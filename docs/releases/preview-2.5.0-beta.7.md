# Preview 2.5.0-beta.7 qualification

Published [Preview 2.5.0-beta.7](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.7), code **2507**, from `6a033984aa5503849d44079a5909271fc3e00ac0` through [release PR #184](https://github.com/Dash1971/maia-chess-android-preview/pull/184), after reviewed/merged #183. The release merge tree equals the qualified source. Later documentation does not rebuild the APK.

Engine help now offers one scrollable approved Temperature and Top-P explanation in all ten languages. The Simple/Technical selector is removed. Shorter move-history help retains its research link and recommendation to leave history off. Sampling behavior, defaults and saved preferences are unchanged.

Flutter **3.47.8** / Dart **3.13.7** address [GHSA-frr6-h895-5pxp](https://github.com/dart-lang/sdk/security/advisories/GHSA-frr6-h895-5pxp). Full Flutter revision: `737ba8f885dc774b53b442759999a312c9461e4e`. Existing strict revision/source-shape guards, deterministic asset ordering and package-URI/NNUE safeguards remain enforced. Matching helper/test changes are in [Stable draft PR #61](https://github.com/Dash1971/maia-chess-android/pull/61), tested separately and left unmerged for separate authorization. Stable and Dev releases remain unchanged.

## Verification

- [Exact-source host/Android CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/40172205458): 1154 host tests passed, three explicit skips; channel/native-policy, localization, analysis and release-tool checks passed. Review passed 55 focused help/layout/default tests, including all ten locales at 200% text.
- Full exact-source ARM64 Android 16 Preview native suite: 16 passed, including real 79M references, Stockfish, storage and lifecycle. Expanded corpora: 3,000 chess positions and 512 variation trees through four round trips.
- Independent Ubuntu and GitHub unsigned APK SHA-256: `ef2f7fe399b9b369ee94d2573549660129fe915a56119150246809695ec6f527`.
- Signed/public APK SHA-256: `fa7c25c89d5fbcd088c5a6d2f55b62644bd693913b85561ff1e6fc9a8991fc99`. Trusted Preview certificate: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction was byte-identical.
- Actual production-signed beta.6 → beta.7 upgrade preserved UID, preferences, games and sampling files. Actual signed-APK help smoke in English/Japanese at 200% text verified paragraph reading order, scroll/research-link reachability, selector removal, shortened history and unchanged settings. Ten-language host tests verify the exact external research targets. Real 79M play and three annotated/unfinished/checkmate upgrade/restart fixtures passed.
- Public APK, bundle and checksums matched qualified hashes/GitHub digests. Downloaded APK signer/model/package/version/payload checks passed. The published receipt was independently downloaded and compared.

[Fresh upstream review](../dependency-audit-2026-10-25-preview-beta7.md) records the SDK security fix and other update/deferral decisions. The 64 exact-version OSV queries returned no finding; manual advisory review found and resolved the SDK issue separately.

## Scope and cleanup

No completed translation editorial review was repeated. Catalog/terminology contracts and approved-English preservation were verified; automated checks are not native-speaker certification. Grand Kingdom/DGT remain Dev-only. Physical phones/Chessnut remain tester acceptance; Preview requires no screenshot-maintenance pass.

Immediately after public-download verification, checked cleanup removed task processes/emulator, bulk/APKs/archives, temporary environments, generated intermediates, completed source/model checkouts and the Linux container on all three hosts. Shared SDK/JDK/Gradle/pub/LFS caches and signing keys were preserved. The new versioned Flutter 3.47.8 installations are retained shared security-upgrade toolchains for future work; existing SDKs remain untouched. Compact evidence and an inspected public pip CA bundle remain outside disposable scratch. The concurrently used Stable companion checkout and its unmerged branch were preserved; its PR remains draft and no Stable publication occurred. README/roadmap records followed bulk cleanup in a source-only checkout.
