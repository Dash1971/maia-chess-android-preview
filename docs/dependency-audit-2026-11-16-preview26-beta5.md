# Preview 2.6.0-beta.5 upstream review — 16 November 2026

Fresh primary release/advisory metadata was fetched for eleven groups covering
Flutter/Dart, Gradle/AGP/Kotlin, Android tools, ONNX Runtime, Stockfish, Maia and
chess/UI packages. No errors; 63 exact Pub/Maven OSV queries returned no findings.
Nineteen Pub update archives were freshly fetched and SHA-256 checked. Current/
latest versions and archive hashes match beta.4; package-specific deferrals were
reassessed and retained in the compact release evidence.

Primary release/advisory metadata is unchanged from the [beta.4 review](dependency-audit-2026-11-15-preview26-beta4.md).
Retain the Flutter 3.47.8/Dart 3.13.7 TLS fix and reviewed Gradle 9.9.1 pin.
ONNX 1.32.0 has the same trusted/pinned Maia graph and fixed-tensor assessment;
retain Android CPU 1.24.3 pending separate numerical/ABI qualification. The CUDA
plugin is unused. Stockfish's 15 November development NNUE/search update is
not a stable/security release; retain pinned engines and verified NNUE inputs.
Other SDK/package migrations remain deferred for recorded compatibility reasons.
No applicable finding requires a dependency/toolchain change for this release.

PR235 changes Android Back handling only. Shared workspace helpers/documents
match current Stable; twelve helper tests pass in each repository. No shared
build/CI/verification/cleanup change needs a port. Stable feature companion #78
is draft and unmerged; this Preview does not promote or publish Stable or Dev.
Ordinary localization/terminology checks are retained; no translation editorial
review is repeated. Grand Kingdom's historical capture symptoms retain the
owner's hardware-drift/calibration explanation, not unresolved app defects.
