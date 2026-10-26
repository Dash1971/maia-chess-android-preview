# Preview 2.5.0-beta.8 qualification

Published [Preview 2.5.0-beta.8](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.8), code **2508**, from `0a6d4655562c07d29d65512e897f9cfd3e97e119` through [release PR #193](https://github.com/Dash1971/maia-chess-android-preview/pull/193), after reviewed/merged #188 → #190 → #191 → #192. The release merge tree equals the qualified source. Later documentation does not rebuild the APK.

Configurable board aids, 25 offline board designs and 16 audited piece sets, a graphical board editor, and optional Maia expected-score text in the existing analysis title bar. Existing users retain Brown/Cburnett and prior aid behavior; the score display defaults off.

The editor supports palettes, tap/drag/place/erase, flip, position metadata and validated analysis/play; native FEN sharing opens a chooser without selecting a recipient. Image import stays unavailable. Maia score means P(win) + half P(draw), conditioned independently on each engine's rating/history; it is not a literal win probability.

## Verification

- [Exact-source host/Android CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/40262057677): 1235 host tests passed, three expected skips, plus analysis, native-policy, flavor, localization and release-tool checks. Local review: 81 focused feature/layout tests and 89 Python tool tests passed. All ten locales pass narrow/landscape layouts at 200% text.
- Full exact-source ARM64 Android 16 Preview native suite: 16 passed with real 79M references, Stockfish, storage/lifecycle. Five feature-native tests passed for preferences/input/promotion, editor touch/drag/flip/clipboard and the real 79M outcome head/legacy bridge/header/persistence.
- Independent Ubuntu and GitHub unsigned APK SHA-256: `84134fb4a4a6d89ab1b3a871e1260022834fb6d307c40e3312952f496f70ca53`.
- Signed/public APK SHA-256: `e2fe73e0bfdf98d9c47fe256ecabd0c696a56d921bcf724444d362efedc941cb`. Established Preview signer `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`; signature reconstruction was byte-identical.
- Actual signed beta.7 → beta.8 upgrade preserved UID, preferences, games and captures. Real 79M opening/middlegame play, 3,000 independent chess positions, 512 variation trees/four roundtrips and three upgrade/restart fixtures passed.
- Actual production-signed APK in English/Japanese: offline selectors, coordinate/score settings and real restart persistence; two independent rating scores and help; editor palettes, flip, metadata and landscape; native FEN chooser without sending. Ten-language geometry and input contracts remain separately covered by host tests.
- All 400 board/piece source composites inspected. All renderer/artwork manifest blobs match immutable upstream revision `0bd34fbe720097c4a51172e2c0d8f697637eda01`. APK enforcement checks exactly 792 approved assets, hashes and licence notices; restricted/unresolved sets are absent. Qualified APK size: 455,339,048 bytes, beta.7 461,388,740, delta -6,049,692. This is the measured total artifact delta across the combined features, not a renderer-only performance claim.
- Release-APK evidence records one emulator workflow’s memory/frame statistics and real-play latency; it does not isolate artwork overhead.
- Public APK, evidence bundle, checksums and receipt matched expected hashes/GitHub digests. Downloaded APK signer/model/package/version/payload verification passed; receipt was independently downloaded and compared.

[Fresh upstream review](../dependency-audit-2026-10-26-preview-beta8.md) records current sources and update/deferral decisions: patched Flutter 3.47.8 / Dart 3.13.7 and Gradle 9.8.1 retained; 63 exact hosted-Pub/direct-Maven OSV queries had no findings. Current Stable `5f6743e` uses hosted Chessground without the artwork feature/manifest, so these feature-specific CI/APK gates must accompany a separately authorized feature promotion. Shared SDK/workspace helpers match Stable. The earlier [Stable SDK companion #61](https://github.com/Dash1971/maia-chess-android/pull/61) was already merged separately; this task changes no Stable/Dev release.

## Scope and cleanup

No translation editorial review was repeated. Catalog/terminology contracts were checked; native-speaker feedback remains welcome. Physical phone/Chessnut acceptance remains with testers. Grand Kingdom/DGT stay Dev-only. Preview needs no screenshot maintenance.

Immediately after public-download verification, checked cleanup removed task processes/emulator, bulk/APKs/archives, temporary environments, generated intermediates, completed source/model checkouts and the Linux container on all three hosts. Shared SDK/JDK/Flutter/Gradle/pub/LFS caches, signing keys and unrelated active work were preserved. Compact hashes, verification evidence and the inspected public pip CA bundle remain. README/roadmap documentation followed bulk cleanup in a source-only checkout.

Delivered issues [#177](https://github.com/Dash1971/maia-chess-android-preview/issues/177), [#178](https://github.com/Dash1971/maia-chess-android-preview/issues/178), [#186](https://github.com/Dash1971/maia-chess-android-preview/issues/186) and [#189](https://github.com/Dash1971/maia-chess-android-preview/issues/189) are closed. Camera import, physical-board work and broader landscape improvements remain separate.
