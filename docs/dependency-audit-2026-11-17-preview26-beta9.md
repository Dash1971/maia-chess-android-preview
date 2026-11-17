# Preview 2.6.0-beta.9 upstream review — 17 November 2026

Fresh beta.9 requests checked eleven primary-source groups (Flutter/Dart,
Gradle/AGP/Kotlin, Android tools, ONNX Runtime, Stockfish, Maia and pinned
chess/UI packages), with no fetch errors. All 63 exact hosted Pub/direct Maven
OSV queries returned no findings. Nineteen Pub update archives were freshly
downloaded and SHA-256 verified. Their current/latest versions and archive hashes
match the [earlier same-day beta.8 review](dependency-audit-2026-11-17-preview26-beta7.md);
each recorded upgrade/deferral reason was reassessed for this layout release.
Compact evidence includes the new responses, hashes and per-package decisions.

The [Dart stable changelog](https://github.com/dart-lang/sdk/blob/stable/CHANGELOG.md)
now explicitly dates 3.14.1 to 17 November: the previously reviewed fix is an AOT
pattern-switch captured-final compiler crash. Retain Flutter 3.47.8/Dart 3.13.7
(including its TLS fix) rather than make an SDK migration for this UI change.
Flutter, Gradle, Kotlin, ONNX Runtime, Stockfish and Maia release/advisory records
are unchanged from the earlier review. AGP 9.6.0-alpha04 remains a prerelease;
retain AGP 9.1.0 and reviewed Gradle 9.9.1. Retain ONNX Android CPU 1.24.3 with
trusted pinned Maia graphs pending separate ABI/numerical qualification of core
1.32; WebGPU/CUDA plugins are unused. Stockfish development NNUE/search changes
retain the compatibility and reproducibility deferral. No applicable finding
requires a pin change.

The full [Android Platform-Tools revision article](https://developer.android.com/tools/releases/platform-tools)
was fetched and its article body reviewed, separately from changing site chrome.
37.0.3 is Canary (November 2026), with USB/mDNS/logging improvements and fixes
for particular Mac configurations; 37.0.2 never passed Canary. The reused Mac
ADB is stable 37.0.1-15733141. Retain that stable test tool for the task-owned
ARM64 emulator; do not migrate a shared toolchain to Canary. Primary package
changelogs and available updates were reviewed using fresh hash-verified archives,
not changing Pub site counters or stylesheets.

PR #249 changes app fixed-pane layout/navigation and its tests/docs only. Current Stable
main was inspected; the four shared build/workspace helpers/docs are identical,
and all 12 helper checks pass in each repository. No tooling port applies;
Stable app promotion and Dev publication are separate. Ordinary catalog and
terminology contracts pass; translation editorial review was not repeated.
Grand Kingdom remains experimental, with the owner's hardware-drift/calibration
explanation for historical capture symptoms; DGT remains Dev-only.
