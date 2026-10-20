# Preview 2.5.0-beta.3 qualification

Published [Preview 2.5.0-beta.3](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.3), code **2503**, from `03f95347dd522b3b86bc4f10ca3a778132ee54a2` through [release PR #164](https://github.com/Dash1971/maia-chess-android-preview/pull/164), after merged translation PR #162. The release merge preserves the built source with an identical tree. Later documentation does not rebuild the APK.

The completed translation review is included without repeating it. All ten languages receive clearer theme choices and consistent chess/sampling terminology, grammar and formatting. The approved English sampling explanation, gameplay, engines, model, settings defaults and storage behavior are preserved.

## Verification

- [Exact-source host and Android CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/39512099527): 1,126 host tests passed, 3 explicit skips; 37 Preview restriction/settings tests; native board policies, channel checks, localization generation/checks, static analysis and 60 Python tool tests passed.
- Expanded corpora: 3,000 independent chess positions and 512 variation trees, each through four round trips.
- Independent Ubuntu and GitHub unsigned APKs are byte-identical: `52275d8f54879fcf60a49f2c6487dd311ac86d0b5188029065c03de2b0128bea`.
- Signed APK SHA-256: `b6a8228aef13086cd12afd1bd2f2b6f2f67953ca65ff9a743f6e5bb67e8e43cd`. Preview certificate remains `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction is byte-identical.
- Full Preview native suite passed on Android 16 ARM64 AOSP for the exact source, including four actual 79M numerical reference cases, real Stockfish, storage, variation and lifecycle regressions. Initial setup lacked the 5M LFS asset; the build stopped before tests. The pinned asset was materialized and hash-verified before rerunning successfully.
- Actual signed beta.2 → beta.3 upgrade preserved UID, settings, games and sampling files. The release APK performed real 79M opening and middlegame moves. Separate temporary-key upgrade checks passed for annotated variations, an unfinished game and checkmate, including archive and restart preservation.
- Actual public APK, verification bundle and checksums match the qualified local files and GitHub asset digests. The published APK was rechecked against the unsigned source build after merge.

## Scope and limitations

Stable 2.4.0 and Dev 2.4.0-alpha.2-dev are unchanged. Grand Kingdom and DGT remain disabled in Preview. Native-speaker acceptance, physical-device font/rendering inspection and physical Chessnut acceptance remain with testers. Android 16 emulator checks do not certify every phone/vendor behavior.

## Evidence and cleanup

The release contains the APK, verification bundle, checksums and public-download receipt. Task-owned build/signing directories, container, APK copies, emulator data and temporary Python environment were removed after retaining compact evidence and verifying downloads. Shared SDK/Gradle caches, signing keys and unrelated work were preserved. Merged task branches were removed after the source was preserved by the release tag; automatic merged-branch deletion remains enabled. Cleanup details are recorded in PR #164.
