#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
python3 "$repo_root/tool/build_workspace.py" preflight
flutter_bin=${FLUTTER_BIN:-flutter}
flutter_path=$(command -v "$flutter_bin")
dart_bin=${DART_BIN:-$(dirname -- "$flutter_path")/dart}
output="$repo_root/build/app/outputs/flutter-apk/Mobile-Maia-Preview-Dev-arm64.apk"

cd "$repo_root"

python3 tool/verify_model.py assets/models/maia3-5m.onnx
# Drop snapshots compiled before package-URI preparation; an incremental kernel
# can otherwise retain the old absolute registrant path despite the new config.
"$flutter_bin" clean
"$flutter_bin" pub get --enforce-lockfile
"$flutter_bin" build apk --release --config-only --flavor dev
# Keep the generated plugin registrant's local path out of the published APK,
# using the same package-URI preparation as the canonical release wrapper.
"$dart_bin" tool/prepare_reproducible_package_config.dart \
  .dart_tool/package_config.json
"$flutter_bin" build apk --release --no-pub \
  --flavor dev \
  --target-platform android-arm64 \
  --android-project-arg=mobileMaiaDevelopment=true \
  --android-project-arg=mobileMaiaArm64Only=true \
  --android-project-arg=disable-abi-filtering=true

cp build/app/outputs/flutter-apk/app-dev-release.apk "$output"
printf '%s\n' "$output"
