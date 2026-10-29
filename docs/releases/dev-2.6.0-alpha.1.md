# Dev 2.6.0-alpha.1 — 29 October 2026

Published [red-icon Dev 2.6.0-alpha.1-dev](https://github.com/Dash1971/maia-chess-android-preview-dev/releases/tag/v2.6.0-alpha.1-dev), code 2601,
package `com.dash1971.maia_chess.preview.dev`. Obtainium uses the same Dev feed
with prereleases enabled. Upgrades from alpha.2 preserve the separate Dev app.
Preview/Stable and F-Droid/Zapstore publication are unchanged.

Canonical source: [5c43145c172a64d2b0527d3cfbe6fca573ef9887](https://github.com/Dash1971/maia-chess-android-preview/tree/5c43145c172a64d2b0527d3cfbe6fca573ef9887),
source tag `dev-v2.6.0-alpha.1-dev`; integration [PR #211](https://github.com/Dash1971/maia-chess-android-preview/pull/211).
Current Preview base `130f571` contains current Stable app fixes; source includes
experimental #209 (`ae8fc4a`) and #210 (`892458d`). Both original feature PRs remain
draft. Later documentation commits do not rebuild this APK.

- ARM64 release-mode APK: 82,135,306 bytes; SHA-256
  `00717b834d1658e94b3d683bca733e1e6b01fe4fe605374ebe94c0a57810f7cd`.
- Continuous original Dev signer: `907a6e676235c52ade43c253e27b37aa4544ee8fb23e395715986cec62959d92`.
- Maia3-5M: `ddae2aa893b5ca7ec94d24178871f1c337d09fd72ff38abe8d76b8ecf08cb942`; fixed PGN “79M” text is not model evidence.
- Diagram model: `2408717e2e0e2ed438e2f9f89f85c2e544326cef34a0c91b95168bd17336df47`.

## Local verification

Built on macOS ARM64 using the shared pinned Flutter 3.47.8/JDK/Android SDK and
existing checksum-verified local models. **No GitHub Actions or LFS downloads.**
The wrapper's generated-package preparation removes local plugin paths using the
same helper as the canonical release wrapper. Existing Linux/reproduction gates
for Preview/Stable are preserved; this is a Dev snapshot, not their qualification.

1,361 Flutter tests passed with four intentional skips; 89 Python checks, native
board checks, analysis and catalog/terminology checks (472 messages × ten locales)
passed. The only change after the full app suite was the Dev wrapper preparation;
app/runtime/test code is identical. Nine Preview build contracts and 18 unchanged
Stable helper checks passed. All four shared cleanup/build files are identical.
Stable has no Dev snapshot wrapper and its canonical wrapper already performs the
preparation, so no companion port applies. Stable source remains unchanged.

The APK passed identity/version, continuous signature, pinned model, ARM64-only,
no-Internet permission, local-path/privacy, ZIP and ELF 16 KiB alignment checks.
A task-owned AOSP ARM64 API 36 emulator upgraded from published alpha.2: UID and
saved-game/preference files were preserved, and the prior game reopened. Offline
fresh gameplay (real Maia reply), Stockfish/Maia analysis, native selected-image
picker/cancellation, first diagram inference, mandatory side/review confirmation,
edit/reconfirmation and applying the reviewed placement to analysis passed.
One synthetic diagram is a smoke test, not broad recognition/phone acceptance.
Compact verification/checksum and cleanup evidence are attached to the Dev release.

## Hardware limits

The [two ordinary Grand Kingdom capture failures](../ELECTRONIC_BOARD_GRAND_KINGDOM_26.md)
remain unresolved. Assisted promotion does not fix those failures. Reproduce
captures before promotion qualification; no board/firmware was connected for
this release. Midgame motor restoration and takebacks use phone continuation.
Image import supports screenshots/2D diagrams with full manual review, not physical
board photos or guaranteed arrow/overlay recognition. Original feature issues stay open.

## Cleanup

After successful upload/digest confirmation, stopped the task-owned emulator and
Gradle/Kotlin daemons and removed build, .dart_tool, generated plugin metadata,
android/.gradle and task-owned bulk output (APK copies, raw logs, test venv and
emulator data). Restored task model copies to committed pointer text. The temporary
Stable audit checkout and protected temporary signing-key copy were removed.

Checked cleanup free bytes: 59650445312 →
62491742208; after restoring model copies:
62829060096. Compact evidence and original model
files, shared toolchains/caches, Git history/tags and the original signing-host
key are retained. Dev requires successful upload confirmation, not an additional
published-APK download; none was added.
