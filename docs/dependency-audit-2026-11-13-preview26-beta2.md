# Preview 2.6.0-beta.2 upstream review — 13 November 2026

A fresh check before freezing beta.2 fetched all eleven primary source groups
in the [same-day beta.1 review](dependency-audit-2026-11-13-preview26.md), current
Pub metadata/changelog archives, and 63 exact Pub/Maven OSV queries (no findings).
All sources are unchanged except ONNX Runtime now lists 1.32.0. Nineteen Pub
updates retain the same versions, archive hashes and package-specific deferrals.
Flutter/Dart, Gradle/AGP/Kotlin/Android tools, Stockfish, Maia and chess/UI pins
and advisory decisions were rechecked. Gradle 9.9.1 remains the security-fixed pin.

[ONNX Runtime 1.32.0](https://github.com/microsoft/onnxruntime/releases/tag/v1.32.0)
adds model/graph validation, operator shape/bounds fixes, CPU/GPU MoE and session
initialization improvements. The app accepts no external ONNX/ORT graphs or
prepacked weights: both models are trusted hash-pinned APK assets. Inputs are
fixed-shape bounded finite tensors, diagram input is float32 and inference is
serialized; the new graph-loading, dynamic-rank, external-weight, CUDA/WebGPU,
MoE and FP16-grouped-convolution cases do not add an applicable untrusted graph
path in this camera UI change. Retain 1.24.3 and qualify a runtime/ABI/performance
migration separately, including Maia numerical behavior and image-model results.
No published upstream advisory or exact-version OSV finding newly requires a
pin change. This is a scoped assessment, not a claim that the older runtime
contains every upstream reliability fix.

No shared build/CI/verification/cleanup helper changed. Stable has no Home scan
feature; no companion feature port applies. Existing shared pin/tooling parity
is unchanged, with [Stable #73](https://github.com/Dash1971/maia-chess-android/pull/73)
still tracked separately. Stable/Dev app releases remain unchanged. No general
translation editorial review was repeated; normal catalog/terminology/layout
regressions cover the six new labels.
