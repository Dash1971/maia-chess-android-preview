# Preview 2.6.0-beta.4 upstream review — 15 November 2026

Fresh release/advisory metadata for Flutter/Dart, Gradle/AGP/Kotlin, Android tools,
ONNX Runtime, Stockfish, Maia and chess/UI packages was checked before freezing
beta.4. Eleven primary-source groups were fetched without errors and 63 exact
Pub/Maven OSV queries returned no findings. Nineteen current Pub update archives
were freshly fetched and hash-checked; versions/hashes and the package-specific
[beta.3 deferrals](dependency-audit-2026-11-15-preview26-beta3.md) remain unchanged.
The compact release evidence records dated sources and each decision.

New since beta.3's morning review: the [15 November Stockfish development build](https://github.com/official-stockfish/Stockfish/releases/tag/stockfish-dev-20261115-5d03b6e5)
updates its main NNUE network and includes king-threat/history-pointer
optimizations. It is a development strength/search update, not a new stable
engine or applicable security fix. Retain the pinned engines and verified NNUE
inputs; a separate numerical/strength/reproducibility qualification is needed
before changing them.

The remaining upstream release/advisory metadata has no new delta from the fresh
beta.3 review. ONNX core 1.32.0 retains the scoped trusted/pinned Maia graph and
fixed-tensor assessment; retain Android CPU runtime 1.24.3 pending a separately
qualified runtime/ABI/numerical migration. The CUDA plugin is not used. The
Flutter 3.47.8 / Dart 3.13.7 TLS fix and reviewed Gradle 9.9.1 pin remain in use;
the Flutter 3.50 migration and AGP/Kotlin/other package updates remain deferred
for the recorded compatibility reasons. No new finding requires a pin change.

This is a Preview 2.6 product-layout feature. Shared workspace helpers/documents
remain identical to current Stable; twelve helper tests pass in each repository.
No shared build/CI/verification/cleanup change requires a companion port. Stable
and Dev app releases are unchanged. Ordinary localization and terminology
contracts cover the 468-message catalogs; no translation editorial review is
repeated. Four new layout headings retain their documented context fallbacks.
Grand Kingdom's earlier capture symptoms have the owner's hardware-drift/
calibration explanation; they are not unresolved app capture defects.
