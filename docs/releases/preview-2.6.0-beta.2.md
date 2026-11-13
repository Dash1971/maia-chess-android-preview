# Preview 2.6.0-beta.2 qualification and cleanup

Published 13 November 2026: [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.2), code 2602.
Feature #220 and release #221 are merged. Qualified source `5ef1a92d92d0dcd76e2f5f70c3648982f0790124`
is preserved by the release tag; later documentation does not rebuild the APK.

Home Scan board now launches the installed camera, reads a detected grid
automatically and opens the normal Board Editor. Framing fallback and normal
analysis/continuation remain available. This completes the UI missing from
beta.1; recognition model, accuracy, native handling and permissions are unchanged.

## Qualification

- [Exact feature-head CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/43413353510) and [full frozen-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/43413349555) passed: 1,410 host tests, 4 expected skips; Android passed.
- Independent Linux unsigned APK is byte-identical to GitHub. Production Preview signing, established signer, identity/model/licence payload verification and byte-identical signature reconstruction passed.
- Full ARM64 API36 native suite: 16 tests with real79M, plus score/diagram/continuation native tests. Expanded chess corpus: 3,000 positions and 512 variation trees/four round trips.
- 121 focused Preview tests, 27 promotion tests, Stable/unflavored exclusions (five passed and one expected skip each), static analysis and ordinary localization/layout contracts passed. No translation editorial review repeated.
- Actual production-signed beta.1 upgrade preserved UID, saved games/captures and preferences including timing off. Real79M sampling and three game/archive/restart fixtures passed.
- Fresh offline production-signed APK checked Home camera/cancel, unavailable-camera gallery fallback with automatic reading into the existing editor, framing controls/private-image cleanup, normal analysis and continuation. The emulator camera is a synthetic pipeline check; no 3D-photo/real-phone/OEM accuracy claim.
- Actual public downloads matched qualified hashes, GitHub digests, signer, identity and model/licence payloads. The release includes the compact bundle, checksums and downloadable verification receipt.

Preview uses the 79M model. The existing 5M Dev asset was materialized solely
because the shared build guard verifies both source assets; it is excluded from
the Preview APK. Initial missing-model and AVD-path setup failures were corrected
without app-source changes or guard bypasses. Compact diagnostics are retained.
The task-local upgrade driver waits for real normal-background restoration and
excludes Home from completed-game detection; no restore safeguard is disabled.

Unsigned SHA-256: `fe7e5a606db4ea27d65cc2b593ec50aad3ab5d38455f6466181ceee2cb2d24f0`.
Signed APK SHA-256: `4e57ba0bf4ccd185f7a0888ec69ce59585c2a3a53d58099724b858fa54e6a82f`.
Signer: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
79M: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`.
Diagram model: `2408717e2e0e2ed438e2f9f89f85c2e544326cef34a0c91b95168bd17336df47`.
APK 456,789,332 bytes; change from beta.1 +16,384 bytes.

[Fresh upstream/advisory review](../dependency-audit-2026-11-13-preview26-beta2.md)
recorded eleven primary source groups, 63 clear exact-version OSV queries and
19 fresh hash-verified update decisions. ONNX1.32.0 was assessed and deferred;
no dependency/toolchain changed. No Stable scan counterpart or shared helper
change requires a feature port. Existing [Stable tooling #73](https://github.com/Dash1971/maia-chess-android/pull/73)
remains open/unmerged with green CI; Stable and Dev releases are unchanged.

## Limits and cleanup

Grand Kingdom remains experimental with the explicitly accepted wrong-piece
removal at `19...Bxf8` and missed removal at `7...Nxb4` unresolved. Hardware
acceptance remains pending; DGT stays Dev-only. Image accuracy/arrow/font,
representative real-phone/OEM and broader Stable/F-Droid acceptance remain open.

Immediately after public-download verification, checked cleanup stopped the
owned emulator/idle Gradle daemon/build container and removed task intermediates,
APK/archive copies, virtual environment, emulator data and task source/model
materializations on all hosts, before this documentation pass. Shared tools,
caches, keys, Git history/tags and unrelated active checkouts were preserved.
Compact evidence and the inspected public pip CA bundle remain.

| Host | Free before/after checked cleanup (GiB) | Removed paths |
| --- | --- | --- |
| mac | 45.76 → 54.54 | `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta2/build`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta2/.dart_tool`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta2/.flutter-plugins-dependencies`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta2/android/.gradle`; `/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-beta2-results/bulk` |
| linux | 21.05 → 25.45 | `/srv/container-ssd/tmp/codex-preview26-beta2/source/build`; `/srv/container-ssd/tmp/codex-preview26-beta2/source/.dart_tool`; `/srv/container-ssd/tmp/codex-preview26-beta2/source/.flutter-plugins-dependencies`; `/srv/container-ssd/tmp/codex-preview26-beta2/source/android/.gradle`; `/srv/container-ssd/tmp/codex-preview26-beta2/bulk` |
| signing | 34.62 → 35.50 | `/Users/openclaw/.cache/codex-maia-preview26-beta2/bulk` |

Task source checkouts were then safely retired after source/tag checks; the source-only documentation checkout is removed after push. No release output waits for documentation CI.
