# Mobile Maia Preview

> **Prerelease channel:** This repository contains experimental Mobile Maia
> builds. The Android package ID is separate from the stable app, so **Mobile
> Maia Preview** can be installed beside **Mobile Maia** without replacing it.
> Preview features may change or be withdrawn before a stable release.

Mobile Maia is an offline-first Android chess app for playing against
[Maia-3](https://github.com/CSSLab/maia3), reviewing games with Maia and
Stockfish, and exporting PGN. The Maia model and analysis engines run locally
on the device. Play, both Maia analysis controls, and Continue from here offer
target-player ratings from 600 to 2600. These describe the human moves Maia
imitates, not a calibrated engine playing strength.

For the current stable release, complete user guide, feature overview, and
screenshots, see the
[Mobile Maia repository](https://github.com/Dash1971/maia-chess-android).

## Next development cycle

Preview 2.3.0-beta.3 incorporates the Stable 2.2.2 application baseline,
including the 600–2600 Maia rating controls and saved-setting migration. It
retains the separate Preview package and release identity; new 2.3 features
will be developed and qualified here before any Stable promotion. The in-app
Temperature and Top-P help opens the same current
[sampling research](https://github.com/Dash1971/maia-chess-android/blob/main/docs/research/maia3-sampling/REPORT.md)
as Stable.

The source includes German, French, Russian, Hindi, Japanese, Simplified Chinese,
Korean and Spanish UI catalogs alongside English. German, French, Russian and Hindi
are new for the next Preview build. Choose a language in Settings or follow
the device language. Native-speaker review is still pending; see the
[localization guide](docs/L10N_REVIEW.md) for coverage, intentional technical-text
exceptions, contributor instructions and the ARB reviewer guide.

Development snapshots use the same Preview source with a separate Dev package,
development signer, ARM64-only APK, and smaller 5M Maia model for rapid phone
testing. They are not production-parity or qualified Preview releases.

## Install and update with Obtainium

[Obtainium](https://github.com/ImranR98/Obtainium) installs Android apps directly
from their official release pages and can notify you when updates are available.

1. Install Obtainium from its
   [official releases page](https://github.com/ImranR98/Obtainium/releases/latest).
2. Open Obtainium, select **Add App**, and paste this URL into **App Source URL**:

   ```text
   https://github.com/Dash1971/maia-chess-android-preview
   ```

3. Confirm that Obtainium detects **GitHub** as the source and enable
   **Include prereleases**.
4. Select **Add**, open **Mobile Maia Preview** in Obtainium, and select
   **Install**.
5. If Android asks, allow Obtainium to install unknown apps, then approve the
   Mobile Maia Preview APK installation.

After setup, use Obtainium's update check to download and install future Mobile
Maia Preview releases. Android may ask you to confirm each update.

## Build

Requirements: **Flutter 3.47.5** (pinned in `.fvmrc`), JDK 17, Android SDK 36,
Python 3, and Git LFS. Use the locked dependencies. A GitHub source ZIP contains
an LFS pointer rather than the 316 MB Maia model, so clone with Git LFS:

```sh
git clone https://github.com/Dash1971/maia-chess-android-preview.git
cd maia-chess-android-preview
git lfs install
git lfs pull
python3 tool/verify_model.py
flutter pub get --enforce-lockfile
flutter analyze
flutter test
tool/build_android_release.sh
```

The universal release APK is written to
`build/app/outputs/flutter-apk/app-release.apk`.
It packages the same ARMv7, ARM64, and x86_64 ABI set as Stable so Preview
exercises the production artifact shape before promotion.
Use this same script for official releases and independent rebuilds. It sets a
fixed source timestamp, prepares stable generated Dart source URIs, and leaves
Dart obfuscation disabled. R8 still shrinks, optimizes, and obfuscates
Java/Kotlin bytecode using the checked-in ONNX/JNI keep rules. Gradle also
verifies the model's exact size and SHA-256, so a direct `flutter build` cannot
silently package a placeholder or altered model. The build downloads
dependencies; installed release apps work offline.

To check reproducibility, build the **same commit** in two clean directories
with the same pinned toolchain and no signing variables, then compare the
unsigned APKs using `sha256sum`. Retain both hashes with the release notes; the
procedure is not itself evidence that a particular release reproduced. The
manual Checks workflow can build an unsigned APK; pull requests run the Dart
analyzer and regression tests.

## Fast phone iteration

Development builds install as **Mobile Maia Preview Dev** with package ID
`com.dash1971.maia_chess.preview.dev`. They can coexist with Stable and the
officially signed Preview app, and their separate data cannot overwrite either
installation. Dev uses the same launcher mark in red so it remains visibly
distinct from the gold official Preview app.

The canonical source and development scripts remain in this repository.
Versioned Dev snapshots for phone testing and Obtainium are published through
the separate release-only
[Mobile Maia Preview Dev repository](https://github.com/Dash1971/maia-chess-android-preview-dev).
That feed is not an official Preview or Stable release channel.

For interactive UI and behavior work, connect an authorized Android phone over
USB debugging and run:

```sh
flutter devices
tool/run_android_dev.sh -d <device-id>
```

Flutter installs the ARM64-only Dev app and supports hot reload or hot restart.
Dev packages Maia3-5M to keep the initial install and full rebuild small. For a
longer private phone test, build one cached ARM64 release-mode snapshot:

```sh
tool/build_android_snapshot.sh
adb install -r build/app/outputs/flutter-apk/Mobile-Maia-Preview-Dev-arm64.apk
```

The snapshot retains release mode, R8, and model-integrity checks, but uses the
smaller Maia3-5M model and Android's development signer. It is not a
reproducible or publishable release artifact by itself. Do not tag or attach an
arbitrary local snapshot to this official Preview repository, and do not use it
as Stable-release evidence. When a tested Dev snapshot is requested, rebuild
and verify it through the Dev publication workflow, then publish it only to the
separate Dev repository above. Use `tool/build_android_release.sh` and the full
qualification process once a feature is substantially settled.

The [release verification guide](tool/hardening/RELEASE_CHECKS.md) includes
portable APK checks, sanitized saved-game upgrade fixtures, emulator commands,
and CI artifact retention. See the
[hardening guide](tool/hardening/README.md) for the full regression suites and
independent chess/variation corpora.

Official releases are signed with the dedicated Mobile Maia app-signing key.
The build reads `MOBILE_MAIA_KEYSTORE`, `MOBILE_MAIA_STORE_PASSWORD`, and
`MOBILE_MAIA_KEY_PASSWORD` from the environment; no signing secrets belong in
this repository. When those variables are absent, Gradle produces an unsigned
release suitable for independent verification.

The official signing certificate SHA-256 digest is:

```text
cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e
```

## Re-export Maia-3

The checked-in ONNX models were exported from the official Maia-3 5M and 79M
checkpoints. The exporter verifies ONNX Runtime outputs against PyTorch before
succeeding.

```sh
python -m pip install /path/to/maia3 onnx onnxruntime
python tool/export_maia3_onnx.py --model maia3-5m --output assets/models/maia3-5m.onnx
python tool/export_maia3_onnx.py --model maia3-79m --output assets/models/maia3-79m.onnx
```

## Credits and attributions

Mobile Maia uses the
[Maia-3 project](https://github.com/CSSLab/maia3) and its 5M and 79M models. Maia-3 was
created by the University of Toronto Computational Social Science Lab to model
human chess move choices at different rating levels. The app includes an About
screen linking directly to the upstream project and source code.

The board interface is provided by
[Lichess Flutter Chessground](https://github.com/lichess-org/flutter-chessground),
including the default Lichess brown theme and Cburnett pieces. Local Stockfish
support uses
[Lichess multistockfish](https://github.com/lichess-org/dart-multistockfish).
Both Lichess projects are credited and linked in the app's About screen.

Experimental Chessnut support uses Chessnut's
[published e-board API](https://github.com/chessnutech/Chessnut_eBoards) and
MIT-licensed [EasyLinkSDK](https://github.com/chessnutech/EasyLinkSDK), and was
cross-checked against Roberto Marabini's GPL-3.0
[chessnutair](https://github.com/rmarabini/chessnutair) reference
implementation. Mobile Maia's Bluetooth transport uses Android's native BLE
APIs. Protocol sources, copyright notices, licence terms, and adaptation
details are recorded in [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

Game Review's move-classification and sacrifice-detection heuristics are
adapted and translated to Dart from
[En Croissant](https://github.com/franciscoBSalgueiro/en-croissant), the
open-source chess GUI by Francisco Salgueiro and contributors. Mobile Maia
retains the upstream classification rules while adding background-isolate
execution and its own review integration. The pinned
upstream revision and licence details are recorded in
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

## Licensing

Copyright (c) 2026 Dash. Original application code in this repository is
licensed under the [GNU Affero General Public License v3.0 only](LICENSE)
(`AGPL-3.0-only`). Contributions are accepted under the same licence.

Mobile Maia Preview as a combined application is distributed under
AGPL-3.0-only. Individual third-party components retain their respective
copyright notices and licences, notably Maia-3 (AGPL-3.0),
Stockfish/multistockfish (GPL-3.0), dartchess (GPL-3.0), and adapted
En Croissant code (GPL-3.0). See
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

This is an independent community project and is not an official Maia Chess,
University of Toronto CSSLab, Stockfish, Lichess, or En Croissant application.
