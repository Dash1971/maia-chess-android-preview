#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
flutter_bin=${FLUTTER_BIN:-flutter}
output="$repo_root/build/app/outputs/flutter-apk/Mobile-Maia-Preview-Dev-arm64.apk"

cd "$repo_root"

python3 tool/verify_model.py
"$flutter_bin" pub get --enforce-lockfile
"$flutter_bin" build apk --release --config-only
"$flutter_bin" build apk --release --no-pub \
  --split-per-abi \
  --target-platform android-arm64 \
  --android-project-arg=mobileMaiaDevelopment=true

cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$output"
printf '%s\n' "$output"
