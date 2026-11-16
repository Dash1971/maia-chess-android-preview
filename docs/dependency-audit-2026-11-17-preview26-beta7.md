# Preview 2.6.0-beta.7 upstream review — 17 November 2026

Fresh metadata covers eleven primary-source groups: Flutter/Dart, Gradle/AGP/
Kotlin, Android tools, ONNX Runtime, Stockfish, Maia and pinned chess/UI packages.
No fetch errors; 63 exact Pub/Maven OSV queries returned no findings. Nineteen
Pub update archives were freshly fetched and SHA-256 checked; current/latest
versions and hashes match [beta.6](dependency-audit-2026-11-16-preview26-beta6.md).
Per-package deferrals were reassessed and retained in the compact evidence.

New since beta.6: Dart 3.14.1 fixes an AOT pattern-switch closure compiler crash;
retain the qualified Flutter 3.47.8/Dart 3.13.7 pairing rather than migrate the
SDK for this UI release. AGP 9.6.0-alpha04 is a prerelease; retain AGP 9.1.0 and
reviewed Gradle 9.9.1. ONNX's WebGPU plugin 0.6.0 adds operator/performance/provider
features and is not used by this Android CPU app. ONNX core 1.32's trusted/pinned
Maia graph and fixed-tensor assessment remains; retain CPU 1.24.3 pending separate
ABI/numerical qualification. The CUDA plugin is also unused. Stockfish's 15 November
development NNUE/search migration and other SDK/package updates retain the
recorded compatibility/reproducibility deferrals. No applicable finding requires
a pin change. The pinned Flutter/Dart TLS fix remains in place.

Both PR #242 and PR #243 are app UI/navigation changes. Shared build/workspace/
verification/cleanup helpers remain identical to current Stable; 12 helper tests
pass in each repository. No tooling port applies. Stable promotion and Dev
publication remain separate. Ordinary localization/terminology contracts pass;
no translation editorial review was repeated. Grand Kingdom's historical
capture symptoms retain the owner's hardware-drift/calibration explanation.
