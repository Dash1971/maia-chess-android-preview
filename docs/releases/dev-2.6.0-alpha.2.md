# Dev 2.6.0-alpha.2-dev — 2026-10-29

Published [red-icon Dev snapshot](https://github.com/Dash1971/maia-chess-android-preview-dev/releases/tag/v2.6.0-alpha.2-dev), code 2602, package `com.dash1971.maia_chess.preview.dev`, ARM64/5M.

Source `dd4e041db6f4d2a84e9b8af91d6e8563ff2b1026`, tag `dev-v2.6.0-alpha.2-dev`.
Diagnostics [#214](https://github.com/Dash1971/maia-chess-android-preview/pull/214) merged at `011aac7258fe62430fb6ffa8ec23c0bbb7695a79`.
Dev includes Grand Kingdom #209 (`ae8fc4a`) and the latest camera #210 (`f405117`); those Preview feature drafts remain unmerged. Source integration and localization preserve both features and the existing motor/promotion safety checks.

- Automatically records detailed Grand Kingdom intent/position/PGN, outgoing wire bytes, bounded incoming messages, GATT/queue/session state, and general Dev lifecycle/errors, engine phases, memory-pressure and camera/import phases. No switch. [Local recording/export limits](../DEV_DIAGNOSTICS.md) describe bounded private no-backup storage, seven-day segment expiry, manual export and failure isolation. Preview/Stable do not record it.
- Camera uses the installed app for flat printed diagrams with offline recognition and mandatory review. No new dependency, permission or network API. Three diagnostics messages are localized across ten catalogs.
- Local full Dev suite: **1,379 passed, four expected skips**. Preview integration: 42 passed/one skip; Stable restriction/diagnostics: eight passed/two skips. Analysis, 479-message ten-language catalog/terminology checks, native protocol/camera/store tests, direct Android-recorder compilation, nine build contracts and 12 shared-helper checks in each repository passed.
- Actual signed APK upgraded published Dev 2601: UID 10150 and active game/preferences preserved, byte-identical before first launch. Real Maia inference and Stockfish/Maia analysis worked offline. Automatic trace and restart persistence passed. Camera cancellation and successful return removed owned JPEGs; real ONNX reached review with Done disabled. AOSP virtual scene tests plumbing, not recognition accuracy. Local export cancellation wrote nothing; successful Downloads text export included version and real engine/camera events.
- No physical Grand Kingdom was connected. Capture failures remain unresolved; GATT success does not establish motor completion. [Owner instructions](https://github.com/Dash1971/maia-chess-android/issues/15#issuecomment-6489649516) request standard-start testing, the first physical mismatch, manual diagnostic export, PGN/video and assisted Maia promotion. Edited-FEN continuation remains unavailable for Grand Kingdom.

## Artifact and provenance

- APK bytes: `82200842`
- APK SHA-256: `9fddd4165813e1b609c9a7be7d77b71838a7233aa269fc4c35f90601f86423cd`
- Existing Dev signer SHA-256: `907a6e676235c52ade43c253e27b37aa4544ee8fb23e395715986cec62959d92`
- Maia3-5M SHA-256: `ddae2aa893b5ca7ec94d24178871f1c337d09fd72ff38abe8d76b8ecf08cb942`
- Diagram model SHA-256: `2408717e2e0e2ed438e2f9f89f85c2e544326cef34a0c91b95168bd17336df47`
- Package/version, signer, pinned models, ARM64-only payload, 79M absence, no Internet permission, ZIP/ELF 16 KiB alignment and absence of embedded local source paths passed. Release upload succeeded; GitHub asset digest/size matched. Dev procedure requires no second matching build or published-APK re-download.
- Local Mac shared Flutter/JDK/SDK/Gradle/pub installations and existing verified models only. No GitHub Actions or Git LFS downloads. The initial all-model guard failure was resolved using the already-local 79M original; it is not packaged. An interrupted test run was discarded and rerun without concurrent build cleanup before the passing final checks.
- Four shared workspace helpers remain identical to Stable. The Dev native test-runner addition has no Stable feature counterpart; the camera Dev-wrapper preparation was already assessed in #210. Canonical Linux and independent reproduction gates remain unchanged. Stable source/release unmodified; no companion merge or app/store promotion.

## Completed cleanup

Immediately after successful Dev publication, stopped task-owned Gradle 255, Kotlin 2391 and emulator 5588 after verifying ownership. Deleted both task checkouts’ generated build/Dart/Gradle data and the owned bulk directory, including APK copies, native-check downloads, exported test data and AVD data. Temporary protected signing-key copy was removed immediately after signing; the original remains on its signing host. Both task model copies were restored to committed LFS pointer text; shared originals/caches and source/history/tags remain.

Free bytes across checked cleanup: `61196816384` → `64144809984`. Compact evidence is retained in `dev-diagnostics-results/evidence`; no bulk output remains. The source integration branch is retained because its #209/#210 feature work and camera breadcrumbs remain unmerged into main. Cleanup preceded this documentation PR.
