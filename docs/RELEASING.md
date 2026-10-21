# Preview and Dev release procedure

Use this guide for Preview and Dev releases. Channel identities and acceptance
limits are in [BUILD_CHANNELS.md](BUILD_CHANNELS.md); host/disk safeguards and
cleanup commands are in [BUILD_WORKSPACE.md](BUILD_WORKSPACE.md). Stable uses its
own [authoritative procedure](https://github.com/Dash1971/maia-chess-android/blob/main/docs/RELEASING.md).

## Preview

1. Check free space on all build/test hosts; reuse shared tools and caches.
2. The release operator or agent must review upstream security advisories and
   available updates before each release, without waiting for a user reminder.
   Check Flutter/Dart, Gradle/AGP/Kotlin and Android tools, locked Pub packages,
   ONNX Runtime, Stockfish, Maia model/inference sources and pinned chess/UI
   packages. Record the check date, versions, advisory/release sources and what
   was upgraded or deferred, with reasons, in the release evidence. Investigate
   known security findings before release; do not update every dependency blindly.
3. Prepare the version and release notes, then freeze the full source commit.
4. Run GitHub Checks on that exact commit, including the manual unsigned Android
   build (`build_android=true`, `expected_source_sha=<full SHA>`). Require the
   test and Android jobs to pass and verify the run's source SHA.
5. Independently build that same source on Linux using the pinned release wrapper.
   Compare unsigned APK SHA-256 values with GitHub: require an exact match.
6. Sign the verified Linux APK with the existing Preview key. Verify package,
   version, model, payloads, signature continuity and signature reconstruction
   from the independent unsigned APK using the release verification tools.
7. Run the full Preview native suite on an ARM64 Android emulator for the exact
   candidate source, using the real 79M model. Test the actual signed upgrade
   from the preceding Preview release and preservation of games/settings, plus
   changed features. Use an Apple Silicon Mac or another suitable host; a Mac
   integration-test build does not replace the qualified Linux release APK.
8. Publish the signed APK, release notes, checksum and compact verification
   evidence as a GitHub prerelease in this Preview repository.
9. Download the public APK and verify its hash, established signer and payloads
   against the qualified artifact. Record the channel status and evidence.
10. Stop task-owned processes and clean bulk output on every participating host.
    Retain compact evidence, shared caches and signing keys.
11. Complete a documentation pass: update the README and roadmap where appropriate,
    mark delivered work, identify work awaiting Stable promotion and link the
    release notes/status. Record changes or that no update was needed. Preview
    has no screenshot-maintenance requirement. Do not delay cleanup for docs.

The agent handling the release owns the upstream review in step 2 and records
its results as part of the release. Do not ask the user to initiate this check.
Preview CI enforces the reviewed Gradle pin and dependency lockfile; it currently
has no separate Stable-style dependency/advisory-audit job. A passing build or an
older review is not evidence that current upstream advisories were checked.

GitHub runs code analysis, chess/game and storage regressions, settings/layout
and translation checks, board restrictions/native policies and verification-tool
tests. It does not run the full Android native suite or signed-upgrade checks.
Emulator tests exercise real Maia/Stockfish, gameplay/analysis, Android storage,
sharing, restart recovery and upgrade preservation. Real Bluetooth, LEDs, board
buttons and motors still need physical hardware acceptance. Preview publication
does not publish Stable, F-Droid or Zapstore, or enable Dev-only board adapters.

Commands and detailed acceptance criteria remain in
[RELEASE_CHECKS.md](../tool/hardening/RELEASE_CHECKS.md) and the
[hardening guide](../tool/hardening/README.md). Preserve the full Preview native
suite gate; Dev's 5M smoke tests cannot substitute for it.

## Dev

A Dev release request includes publication to the separate
[Dev repository](https://github.com/Dash1971/maia-chess-android-preview-dev) by
default. A build-only request remains build-only. This repository is the canonical
source; the Dev repository is a release feed, not a second source/build pipeline.

1. Check free space and reuse the existing shared tools/caches.
2. Review security concerns relevant to the changes. Dev does not require the
   complete per-release Preview/Stable upstream review.
3. Run relevant automated checks for the changes; record the source commit and
   results. Do not add full release qualification solely to publish a Dev build.
4. Build once on a suitable host with `tool/build_android_snapshot.sh`: ARM64-only,
   release mode, 5M model and the existing development signing identity. Keep the
   separate Dev package and use a new version/code for a new published snapshot.
5. Install that APK on a suitable phone or emulator and smoke-test the changed
   functionality. Check upgrade/data behavior when changes affect it; retain
   development-signature continuity for existing Dev installs.
6. Publish that tested APK as a prerelease in the Dev repository by default, with
   brief change notes, the canonical source SHA and known limitations. Confirm
   the release/upload command succeeded and record the release URL.
7. Stop task-owned processes and clean temporary output; keep compact source,
   APK/model hashes and test/publication notes.

No second matching build, full 79M suite, production signing, F-Droid/Zapstore
qualification, screenshot pass, or published-APK re-download/verification is
required for Dev. No separate post-publication download gate should be added to
cleanup. Routine tests still apply to source changes; a lightweight publication
is not evidence of Preview or Stable readiness. Preserve Dev-only experimental
board restrictions in the other channels.
