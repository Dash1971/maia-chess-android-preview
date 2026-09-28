#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
flutter_bin=${FLUTTER_BIN:-flutter}

cd "$repo_root"

python3 tool/verify_model.py assets/models/maia3-5m.onnx

exec "$flutter_bin" run \
  --flavor dev \
  --target-platform android-arm64 \
  --android-project-arg=mobileMaiaArm64Only=true \
  --android-project-arg=disable-abi-filtering=true \
  "$@"
