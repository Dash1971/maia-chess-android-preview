# Preview 2.5.0-beta.10 qualification

Published [Preview 2.5.0-beta.10](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.10), code **2510**, from `96745a6e49c1b66962b2219ebb23e35a5a1ef1a4` through [release PR #201](https://github.com/Dash1971/maia-chess-android-preview/pull/201), after reviewed/merged #198 and corrected #199. The release merge tree equals the qualified source. Later documentation does not rebuild the APK.

Maia score circles/percentages use aligned columns with 8 dp after the rating and 4 dp after the circle. Continue from here can connect to or reuse a Chessnut board, then wait for the selected physical position before untimed play. Full FEN, side, castling/en-passant rights, rating and validated history are retained; phone continuation remains available.

**Physical Chessnut acceptance is pending owner testing with this Preview.** The requester explicitly authorized publication for that purpose. Controlled transports and emulator tests do not establish physical radio/LED behavior. The [hardware checklist](../CONTINUATION_ELECTRONIC_BOARD.md#verification-and-release-acceptance) covers connect/reuse, custom positions, LEDs, either side, reconnect, cancel, ordinary home play and phone fallback.

## Verification

- [Exact-source host/Android CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/40330898993): 1,286 host tests passed, three expected skips, plus analysis, native policy, flavor restrictions, artwork/notices, catalogs and release-tool checks.
- Local review: 88 session/continuation/score/reset tests passed; 38 spacing tests passed on the combined source. Catalog/terminology contracts cover 453 messages in ten languages, including compact/200% continuation layouts.
- Review found pre-borrow queued commands could run after the original owner was restored. The added regression failed on the original #199 source and passed after command epochs were invalidated on ownership changes. In-flight writes remain ordered. Corrected #199 head `ac685292bb237fe0f1f44fc7de6d1f85582a2785` passed CI before merge.
- Full exact-source ARM64 Android 16 native suite: 16 passed with real 79M/Stockfish/storage/lifecycle. Two additional native tests passed: score bridge/geometry, and continuation with a controlled board transport plus real 79M gameplay after piece matching and an en-passant move. Native preferences and full FEN/history/untimed continuation were checked.
- Independent Linux and GitHub unsigned APK SHA-256: `762a9f9eee78f846642d35070d34d92358de609695702f5130edfcf39affb9c0`.
- Signed/public APK SHA-256: `3dbeb86cee897c4cb796d850211791a27800029cedaa4263f214c0f054fa7acf`. Established Preview certificate `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`; signature reconstruction was byte-identical.
- Actual signed beta.9 → beta.10 update preserved UID, settings, games and captures. Real 79M opening/middlegame play, 3,000 independent chess positions, 512 variation trees/four round trips and three saved-game/archive/restart fixtures passed.
- Actual signed APK: score/title bounds stay fixed across PGN navigation/flip in English/Japanese, one/two engines and normal/200% text. Continuation checks cover native unavailable-connection recovery/retry, cancelling without changing the analysis FEN, restoring the selected phone clock and starting the same position on the phone. These are emulator recovery checks, separate from physical acceptance.
- Public APK, evidence bundle, checksums and receipt matched expected hashes/GitHub digests. Downloaded signer/model/artwork/package/version/payload checks passed; receipt was independently downloaded and compared.

[Fresh upstream review](../dependency-audit-2026-10-26-preview-beta10.md) records dated sources, 63 exact-version OSV queries without findings and package-specific deferrals for 19 available Pub updates. Patched Flutter 3.47.8 / Dart 3.13.7 and Gradle 9.8.1 remain pinned. No dependency, permission, asset, storage schema or shared build/CI/cleanup helper changed; no Stable tooling companion applies.

## Scope and cleanup

Chessnut only for arbitrary-position continuation. Grand Kingdom/DGT remain Dev-only and their position-continuation prototypes remain excluded. Stable/Dev releases are unchanged. #182’s implementation is delivered in this Preview; owner hardware acceptance remains pending. Existing approved translation reviews were preserved; new app-specific hardware guidance passed catalog/layout contracts and remains open to native-speaker feedback. Preview requires no screenshot maintenance.

Immediately after public-download verification, checked cleanup removed task processes/emulator, bulk/APKs/archives, temporary environments, generated intermediates, completed source/model checkouts and the Linux container on all three hosts. Shared SDK/JDK/Flutter/Gradle/pub/LFS caches, signing keys and unrelated active work were preserved. Compact hashes, verification evidence and an inspected public pip CA bundle remain. README/channel documentation followed bulk cleanup in a source-only checkout.
