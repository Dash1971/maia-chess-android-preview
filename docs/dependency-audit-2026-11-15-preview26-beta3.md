# Preview 2.6.0-beta.3 upstream review — 15 November 2026

Fresh release/advisory metadata for Flutter/Dart, Gradle/AGP/Kotlin and Android
tools, ONNX Runtime, Stockfish, Maia and chess/UI sources was checked before
freezing beta.3. Eleven primary source groups were fetched without errors;
63 exact-version Pub/Maven OSV queries returned no findings. Nineteen current
Pub update archives were freshly fetched, hash-checked and compared with the
[beta.2 decisions](dependency-audit-2026-11-13-preview26-beta2.md); versions,
archive hashes and package-specific deferrals remain unchanged.

The newly listed [ONNX CUDA plugin0.4.0](https://github.com/microsoft/onnxruntime/releases/tag/plugin-ep-cuda/v0.4.0)
is not used by this Android CPU app. ONNX core1.32.0's graph validation and
operator fixes retain the prior scoped assessment: no external graphs are
accepted, the packaged Maia graph is trusted/hash-pinned and tensor shapes are
fixed. Diagram recognition and its model are removed in this candidate. Retain
1.24.3 and separately qualify a core/runtime/ABI/numerical migration.

The [Stockfish14November development build](https://github.com/official-stockfish/Stockfish/releases/tag/stockfish-dev-20261114-1e7e6bde)
contains search, repetition-hash and cleanup changes. It is a development build,
not an applicable security update. Retain the locked engines/NNUE/model inputs
rather than combine an unqualified engine/strength change with PGN export.
No new published advisory requires a pin change. Flutter3.47.8/Dart3.13.7 already
include the prior TLS fix; retain their reproducible pin and defer the3.50 SDK
migration. Gradle9.9.1 remains the reviewed security pin. AGP/Kotlin/Android tools
and the other upstream source groups show no new release/advisory delta from
the previous review. Links/raw dates and package decisions are in release evidence.

No generic build/CI/verification/cleanup helper changed. The four shared
workspace helpers/documents are identical to current Stable and all12 helper
tests passed in each repository. Only removed recognition-specific native-test
inputs differ; Stable never contained that feature. No tooling companion port
applies. Stable's batch-export request74 and existing Gradle companion73 remain
separate; this Preview release does not promote or publish Stable/Dev.
No translation editorial review was repeated. Integration mechanically preserves
the camera-label deletions and PGN-label additions and regenerates464 messages
across ten catalogs, with the normal terminology/layout contracts.
