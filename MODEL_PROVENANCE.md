# Maia-3 model provenance

The official Preview flavor bundles **79M**; red-icon Dev bundles **5M**.
`pubspec.yaml` scopes the assets by flavor, and Android's BuildConfig selects
the corresponding file. Neither a source tree containing both files nor a Dev
check establishes that the official Preview APK contains or runs both models.

## Preview 79M

The 79M checkpoint, conversion and pinned export procedure are documented in
[Stable model provenance](https://github.com/Dash1971/maia-chess-android/blob/main/MODEL_PROVENANCE.md).
Preview uses the same ONNX artifact: 316,034,244 bytes, SHA-256
`3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`.

## Dev 5M

- Upstream project: [CSSLab/maia3](https://github.com/CSSLab/maia3), source revision `1e13597c42d4858b7cfd7cfdae01e297263364b2`.
- Checkpoint reference: [UofTCSSLab/Maia3-5M](https://huggingface.co/UofTCSSLab/Maia3-5M/tree/b6559de2398d7140b985f28fd2c19fb5e47ddabe), revision `b6559de2398d7140b985f28fd2c19fb5e47ddabe`.
- `maia3-5m.pt`: 20,968,049 bytes; upstream SHA-256 `ba14208b2992d85502f5fb501934abf6aaaeb355e9f3fdf90e326911f562524f`.
- Bundled conversion: `assets/models/maia3-5m.onnx`, 21,346,652 bytes.
- ONNX SHA-256: `ddae2aa893b5ca7ec94d24178871f1c337d09fd72ff38abe8d76b8ecf08cb942`.
- Licence reference: the upstream [model card](https://huggingface.co/UofTCSSLab/Maia3-5M/blob/b6559de2398d7140b985f28fd2c19fb5e47ddabe/README.md) directs code/weights licensing to the [Maia-3 repository](https://github.com/CSSLab/maia3/blob/1e13597c42d4858b7cfd7cfdae01e297263364b2/LICENSE), which provides AGPL-3.0. Its CC-BY-4.0 reference is for the paper. See [third-party notices](THIRD_PARTY_NOTICES.md).

The checkpoint reference was inspected on 24 November 2026. The bundled ONNX
hash is enforced by `tool/verify_model.py` and the Android pre-build guard.
The 79M byte-identical re-export record is not a new 5M re-export verification.

For a new export, follow the pinned Python/source setup in Stable's procedure,
verify the selected checkpoint hash, and pass `--model maia3-5m` with the 5M
output path to `tool/export_maia3_onnx.py`. Run its PyTorch/ONNX parity checks
and compare artifact hashes before proposing an asset change. Qualification
must use the actual flavor/model, with the full 79M suite for official Preview.

## Open Brilly Finder — Preview 2.7 draft

This is a separate move-classification model, not a replacement Maia engine.

- Project: [Open Brilly Finder](https://github.com/Dash1971/open-brilly-finder),
  revision `59cab58a8b63387d9775252f03a6875fe451f697`.
- Exact source: `studies/brilliant-exchange-2026-11-22/model/mute-exchange-model.json`.
- Bundled asset: `assets/classifiers/mute-exchange-model.json`, 480,186 bytes.
- SHA-256: `992a792a646b11e612486c4fe26796fc38ee47f395f2220b00d26db65ba1e27d`.
- 91 named features; 222 exported trees; cutoff `0.8193002847777424`.
  The upstream description's 400 trees is the training iteration cap, not the
  actual exported tree count. The asset is unchanged.
- License: AGPL-3.0-only, under the pinned project's LICENSE and source boundaries.

Runtime loading checks the asset's byte count and SHA-256. Dart inference is
checked against all 360 upstream parity fixtures. See the
[integration contract](docs/OPEN_BRILLY_FINDER_27.md) and
[third-party notices](THIRD_PARTY_NOTICES.md). No training stack, engine binary,
Node package or research corpus is added to the application bundle.
