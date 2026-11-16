# Preview 2.6.0-beta.6 upstream review — 16 November 2026

Fresh release-specific metadata covers eleven primary-source groups for
Flutter/Dart, Gradle/AGP/Kotlin, Android tools, ONNX Runtime, Stockfish, Maia and
chess/UI packages. No fetch errors; 63 exact Pub/Maven OSV queries were clear.
Nineteen Pub update archives were freshly fetched and SHA-256 checked; versions
and hashes match [beta.5](dependency-audit-2026-11-16-preview26-beta5.md).
Each deferral was reassessed and retained in the compact release evidence.

Primary release/advisory metadata is unchanged. Retain Flutter 3.47.8/Dart 3.13.7's
TLS fix and reviewed Gradle 9.9.1 pin. ONNX 1.32 retains the trusted/pinned Maia
graph and fixed-tensor assessment; keep Android CPU 1.24.3 pending independent
ABI/numerical qualification. CUDA is unused. Stockfish's 15 November development
NNUE/search update remains a separately qualified strength/reproducibility
migration, not a stable/security update. Other recorded package/SDK deferrals
remain applicable; no finding requires a pin change for this navigation fix.

PR239 changes app navigation and in-memory list position only. Shared helpers
match Stable; 12 workspace tests pass in each repository. No shared build/CI/
verification/cleanup helper changed, so no tooling port applies. Stable app
promotion remains separate. Ordinary localization/terminology contracts pass;
no translation editorial review was repeated. Grand Kingdom's historical
capture symptoms retain the owner's hardware-drift/calibration explanation.
