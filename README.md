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

[Build-channel status and testing scope](docs/BUILD_CHANNELS.md) ·
[Preview and Dev release instructions](docs/RELEASING.md)

## Preview 2.5.0 beta

The latest release in this development cycle is [2.5.0-beta.6](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.6).

The 2.5 cycle adds optional appearance settings, revised Maia defaults and help, translation corrections, and analysis-board interaction improvements. Existing saved preferences are retained. These changes are delivered in Preview and await separate Stable acceptance and promotion; Stable and Dev remain unchanged.

Game Review and imported-PGN analysis clear stale piece selection and legal-move dots when navigating. Navigation cancels held drags and pending promotion, while engine-result updates retain selection and played moves retain their tap/drag animation. See [beta.4 qualification](docs/releases/preview-2.5.0-beta.4.md).

Analysis arrows step along the current line. Within an analysis variation, Hold Left returns to the outermost main-line branch point; Hold Right selects one main-line move after that point, clamping at the game end. The destination is independent of variation length, nesting and selected move. Ordinary taps and main-line endpoint holds retain their behavior; live-game navigation is unchanged. See [beta.6 qualification](docs/releases/preview-2.5.0-beta.6.md).

For release notes and verification from earlier development cycles, see the [release history](https://github.com/Dash1971/maia-chess-android-preview/releases).

## Roadmap

These are the areas we would like to work on next.

**Expand electronic-board support**

Experimental work on **Square Off Grand Kingdom** and **DGT Pegasus** is available in Dev builds, but neither board is enabled in Preview or Stable yet. Grand Kingdom needs physical testing of piece movement, resets, reconnection, and recovery. Pegasus also needs a FOSS-compatible way to initialize boards with locked firmware before we can offer support.

We’re looking for owners of these boards who are willing to help test and report their results. See the [board testing guide](https://github.com/Dash1971/maia-chess-android-preview/blob/main/docs/ELECTRONIC_BOARD_DEV.md) and [Grand Kingdom issue](https://github.com/Dash1971/maia-chess-android-preview/issues/27).

**Languages and native-speaker review**

Mobile Maia currently supports **English, Japanese, Simplified Chinese, Korean, Spanish, German, French, Russian, Hindi, and Brazilian Portuguese**. We have no general expansion beyond these ten languages planned, but we will consider requests when native speakers are willing to help us validate the translations in the app. Choose a language in Settings or follow the device language. See the [localization guide](docs/L10N_REVIEW.md) for coverage and contributor instructions.

We would particularly like to hear from **Arabic, Hebrew, and Farsi (Persian) speakers**. We would love to add these languages, but right-to-left layouts—especially alongside chess notation, clocks, and evaluations—need careful testing. See the [right-to-left language issue](https://github.com/Dash1971/maia-chess-android-preview/issues/84).

**Temperature and Top-P research: defaults decision**

[The 79M sampling study](https://github.com/Dash1971/mobile-maia-research/blob/main/studies/opening-variety-2026-10-18/REPORT.md) is complete: 3,000 full games, 5,400 opening rollouts and 180 quality positions. Temperature 1.0 / Top-P 0.95 with **Max variety in opening** scored 60.7% against 1.0 / 1.0 at the 1600 rating input (95% interval: 56.8–64.6%) and preserved the measured broad opening mix. Finer opening variation and human-move fidelity remain uncertain.

The **Preview 2.5 defaults** are **Temperature 1.0 / Top-P 0.95 with Max variety in opening on**. They apply to new settings and Settings resets; existing saved preferences and frozen game profiles are retained. Play and primary analysis start at 1500; the optional second analysis engine starts at 2600 and remains off until enabled. The [visual settings guide](https://github.com/Dash1971/mobile-maia-research/blob/main/guides/choosing-maia-settings/README.md) explains the choice. These changes are available in [Preview 2.5.0-beta.6](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.6), including the refined Simple explanation, shorter settings notices and completed translation corrections; Stable is unchanged.

Engine help offers **Simple explanation** and **Technical explanation** in all ten languages. At Temperature 0, Top-P is disabled and labelled “Not used”; its value is retained for when Temperature is raised again. Contextual notices describe full sampling, narrower opening choices and deterministic play without running extra inference.

**Colors and appearance**

Preview 2.5.0-beta.1 adds **Appearance** below Language: Light, Dark or System, optional Android system colors, and a pure-black background in dark mode. Beta.2 darkens the panels when pure-black mode is enabled; other themes are unchanged. The current green dark theme stays the default. System colors require Android 12 or later and a supported palette. Board, clock and analysis colors retain their chess meaning. See the [theme issue](https://github.com/Dash1971/maia-chess-android-preview/issues/124).

**Board and piece designs**

We plan to add independent board-design and piece-set choices in Settings, with visual previews and offline availability. Mobile Maia already uses Lichess’s chessboard library, which provides the designs; the work is to expose suitable styles consistently across play, review and the board editor while preserving the current appearance for existing users. Included assets need verified redistribution rights and attribution. See the [board and piece design issue](https://github.com/Dash1971/maia-chess-android-preview/issues/177).

**Configurable board aids**

Last-move highlighting, legal-move dots, coordinates, piece animation, magnified dragging and a circular drag target already work in Mobile Maia. We plan to make these configurable in Settings, retaining today’s behavior by default and saving the choices across restarts. See the [configurable board aids issue](https://github.com/Dash1971/maia-chess-android-preview/issues/178).

**Landscape and tablet layouts**

We want to improve the existing side-by-side layout so the board makes better use of the available space on landscape phones and tablets, with clocks and essential controls easy to reach. This includes constrained-width windows and large text, plus physical-device testing of comfortable touch input. The work can share board configuration and visual checks with the design and board-aid settings above. Feedback from phone and tablet users is welcome in the [landscape layout issue](https://github.com/Dash1971/maia-chess-android-preview/issues/29).

**Suggestions from users**

Suggestions are always welcome. Please open an issue in the [Preview repository](https://github.com/Dash1971/maia-chess-android-preview/issues) or the [Stable repository](https://github.com/Dash1971/maia-chess-android/issues) so we can discuss and consider it.

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
smaller Maia3-5M model and Android's development signer. For a Dev release, run
relevant automated checks, build once, smoke-test the changed functionality and
publish that tested APK to the separate Dev repository by default. No second
matching build or published-download check is required. Follow the
[lightweight Dev release instructions](docs/RELEASING.md#dev), including cleanup.
Keep local snapshots out of this official Preview release feed. Dev results do
not qualify Stable or Preview; use `tool/build_android_release.sh` and the full
Preview qualification process once a feature is substantially settled.

The [release verification guide](tool/hardening/RELEASE_CHECKS.md) includes
portable APK checks, sanitized saved-game upgrade fixtures, emulator commands,
and CI artifact retention. See the
[hardening guide](tool/hardening/README.md) for the full regression suites and
independent chess/variation corpora.

Before changing saved-game formats, dates, or migration behavior, follow the
[saved-game history and compatibility contract](docs/session-storage.md).
It documents the required regression tests and the rules for preserving older
users' games.

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
