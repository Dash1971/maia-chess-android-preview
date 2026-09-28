#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
flutter_bin=${FLUTTER_BIN:-flutter}
output="$repo_root/build/app/outputs/flutter-apk/Mobile-Maia-Preview-Dev-arm64.apk"

cd "$repo_root"

python3 tool/verify_model.py assets/models/maia3-5m.onnx
"$flutter_bin" pub get --enforce-lockfile
"$flutter_bin" build apk --release --config-only --flavor dev
"$flutter_bin" build apk --release --no-pub \
  --flavor dev \
  --target-platform android-arm64 \
  --android-project-arg=mobileMaiaDevelopment=true \
  --android-project-arg=mobileMaiaArm64Only=true \
  --android-project-arg=disable-abi-filtering=true

cp build/app/outputs/flutter-apk/app-dev-release.apk "$output"
printf '%s\n' "$output"
