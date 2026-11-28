# Mobile Maia Preview

> **Prerelease channel:** Preview is the testing channel for future Mobile Maia
> changes. It has a separate Android package and can be installed beside Stable.
> Preview 2.6.0-beta.13 currently offers the same features as Stable 2.6.0.
> Future Preview features may change or be withdrawn before a Stable release.

Mobile Maia is an offline-first Android chess app for playing against
[Maia-3](https://github.com/CSSLab/maia3), reviewing games with Maia and
Stockfish, and exporting PGN. The Maia model and analysis engines run locally
on the device. Play, both Maia analysis controls, and Continue from here offer
target-player ratings from 600 to 2600.

For the current stable release, complete user guide, feature overview, and
screenshots, see the
[Mobile Maia repository](https://github.com/Dash1971/maia-chess-android).

[Build-channel status and testing scope](docs/BUILD_CHANNELS.md) ·
[Preview and Dev release instructions](docs/RELEASING.md)

## Community

Join the [Mobile Maia forum on Mute Chess](https://mutechess.org/forum/mobile-maia) to ask
questions, share games, discuss settings, and help test Preview. Discussions
are publicly readable; posting uses a Nostr identity on Mute Chess.

Report reproducible bugs in the tracker for the channel you use; see
[Testing Preview](docs/TESTING_PREVIEW.md). Feature discussion usually starts in Preview.

## Current Preview status

[Preview 2.6.0-beta.13](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.13)
is published. It uses the **79M Maia-3 model**. Grand Kingdom has passed user
acceptance; Pegasus and the former camera/image prototype are withdrawn.
See [qualification and cleanup](docs/releases/preview-2.6.0-beta.13.md).

Preview beta.13 currently offers the same features as
[Stable 2.6.0](https://github.com/Dash1971/maia-chess-android/releases/tag/v2.6.0).
Use [Stable distribution status](https://github.com/Dash1971/maia-chess-android/blob/main/docs/BUILD_CHANNELS.md)
for GitHub, F-Droid and Zapstore delivery.

Dev remains 2.6.0-alpha.2-dev with the 5M model and its historical prototype
payload. See [Testing Preview](docs/TESTING_PREVIEW.md) for installation,
reports and the path to Stable.

## Feature guide

<a id="new-in-26-awaiting-stable"></a>

### Promoted in Stable 2.6

| Feature | Available in Preview | Guide |
| --- | --- | --- |
| Saved PGN evaluations, move-quality symbols and restored graphs; optional analysis in exported copies | beta.13 | [Saved analysis](docs/PGN_ANALYSIS.md) |
| Explicit all-games import, duplicate skipping, progress and selected-game collection export; shared 5 MiB limit | beta.12, building on beta.3/beta.11 | [PGN import and export](docs/RECENT_GAMES_PGN_EXPORT.md) |
| Manual interrupted-game recovery, stable Home-save identity and analysis pause/resume | beta.10–beta.12 | [Storage and recovery](docs/session-storage.md#preview-26-recovery-and-interrupted-analysis) |
| Fixed analysis controls with independent move scrolling | beta.9 | [Analysis layout](docs/ANALYSIS_SCROLL_26.md) |
| Back from a saved game returns to Recent games at the previous scroll position | beta.6 | [Release notes](docs/releases/preview-2.6.0-beta.6.md) |
| Landscape layouts and wider Home, Settings and Recent games views | beta.4 | [Adaptive layouts](docs/ADAPTIVE_LAYOUTS_26.md) |
| Grand Kingdom: standard-position untimed play and assisted Maia promotion | beta.1 onward | [Board support and acceptance](docs/ELECTRONIC_BOARD_GRAND_KINGDOM_26.md) |

PGN transfers games and supported annotations, not app preferences or live
clock/motor checkpoints. Physical touch/tablet feedback remains welcome; host
renders and emulator checks do not establish every device's usability.
The [Stable user guide](https://github.com/Dash1971/maia-chess-android/blob/main/docs/USER_GUIDE.md)
covers features already released in Stable.

<a id="saved-analysis-in-pgn--preview-beta13"></a>
<a id="recent-games-and-pgn-files"></a>

## Roadmap

**Offline board scanning: Open Board Scanner candidate for 2.7**

We are considering [Open Board Scanner](https://github.com/Dash1971/open-board-scanner)
for Mobile Maia 2.7. Its board-finder and piece-reader models total **3.5 MB**
and run entirely offline, reading screenshots and photos of printed chess diagrams.
In our desktop test, it read all 64 squares correctly in **87 of 88 photos**.
See the [results and visual comparison](https://github.com/Dash1971/open-board-scanner/blob/main/REPORT.md).

**The code and model weights are published under AGPL-3.0-only**, the same
licence as Mobile Maia. Training included noncommercial piece artwork and
copyrighted diagram photos. Our understanding is that the trained weights are
not derivative works of those images; before including the scanner, we want
F-Droid to confirm that it accepts this licensing basis. The
[model licence and provenance](https://github.com/Dash1971/open-board-scanner/blob/main/MODEL-LICENSE.md)
sets out the details.

Manual Board Editor, FEN import, Analysis and Continue from here remain
available. See [the original proposal (#179)](https://github.com/Dash1971/maia-chess-android-preview/issues/179).

**Expanded language support and native-speaker review**

Mobile Maia currently supports **English, Japanese, Simplified Chinese, Korean, Spanish, German, French, Russian, Hindi, and Brazilian Portuguese**. We would like to expand language support with native speakers who can help validate translations in the app. See the [localization guide](docs/L10N_REVIEW.md) for coverage and contributor instructions.

We would particularly like to hear from **Arabic, Hebrew, and Farsi (Persian) speakers**. These languages need careful testing of right-to-left layouts alongside chess notation, clocks, and evaluations. See the [right-to-left language issue](https://github.com/Dash1971/maia-chess-android-preview/issues/84).

**Under consideration: candidate moves and a rating explorer**

We are considering tappable analysis candidates that show Maia’s move probabilities alongside Stockfish evaluations, plus an optional view of how move preferences change across ratings. The [analysis candidates and Moves by rating issue](https://github.com/Dash1971/maia-chess-android-preview/issues/200) contains the proposed scope and interactive mockups for discussion.

**Open Brilly Finder — target 2.7**

The [draft integration](docs/OPEN_BRILLY_FINDER_27.md) replaces Brilliant-move
classification with [Open Brilly Finder](https://github.com/Dash1971/open-brilly-finder),
using existing offline Stockfish analysis and a 469 KiB model. Host parity and
review tests pass; Android performance and release qualification remain pending.
See [#273](https://github.com/Dash1971/maia-chess-android-preview/issues/273).

**More device and board feedback**

Chessnut Pro owners and Grand Kingdom owners are welcome to help test the
[supported-board flows](docs/ELECTRONIC_BOARD_DEV.md). Report new board problems in the running channel’s tracker.
[Stable #15](https://github.com/Dash1971/maia-chess-android/issues/15) retains the
original Grand Kingdom hardware feedback and delivery history.
Further physical-tablet, landscape, large-text and split-screen feedback will
help refine the [adaptive layouts](docs/ADAPTIVE_LAYOUTS_26.md).

**Suggestions from users**

Feature suggestions are welcome in [Preview issues](https://github.com/Dash1971/maia-chess-android-preview/issues).
Report bugs in the repository for the channel you use: [Preview](https://github.com/Dash1971/maia-chess-android-preview/issues)
or [Stable](https://github.com/Dash1971/maia-chess-android/issues). Link existing
shared hardware discussions so their testing history stays together.

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

For manual downloads, see [Preview releases](https://github.com/Dash1971/maia-chess-android-preview/releases)
and [Verify your download](docs/VERIFY_DOWNLOAD.md).

## Testing and contributing

Use [Testing Preview](docs/TESTING_PREVIEW.md) for installation, reports and
promotion status. See [Contributing](CONTRIBUTING.md), [Security](SECURITY.md),
[Privacy](PRIVACY.md) and the [documentation index](docs/README.md).

## Build

See [Reproducible builds](REPRODUCIBLE_BUILDS.md) for source pins and APK comparison.

Requirements: **the Flutter version and revision pinned in the checked-out `.fvmrc` and CI**, JDK 17, Android SDK 36,
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

The [download verification guide](docs/VERIFY_DOWNLOAD.md) lists the official signer and checksum commands.

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

## Re-export Maia-3

Use the pinned checkpoints, source revision, dependencies and verification steps
in [Model provenance](MODEL_PROVENANCE.md). Model re-export is separate from an
ordinary app build; it is not needed to use the checked-in LFS assets.

## Electronic-board support

Supported in Stable 2.6 and the current Preview/Dev sources:

| Board | Support | Hardware testing | Notes |
| --- | --- | --- | --- |
| Chessnut Air | Supported | Fully tested | Piece recognition and LED guidance. |
| Chessnut Go | Supported | Fully tested | Piece recognition and LED guidance. |
| Chessnut Pro | Supported | Not fully tested | Uses the shared Chessnut protocol; further device testing is welcome. |
| Square Off Grand Kingdom | Supported | Passed user acceptance testing | Untimed games from the standard position; assisted Maia promotion. |
| DGT Pegasus | Not supported | — | Prototype withdrawn because initialization licensing and downstream redistribution permission remain unresolved. |

The [support decision](docs/decisions/2026-11-22-electronic-board-support.md)
records the Pegasus withdrawal. The uncertainty concerns initialization
permission, not the GPL-licensed MoveAPiece protocol code. Older Dev APKs may
contain the retired prototype. Current Preview and Stable 2.6 exclude it.

Board owners and manufacturers are welcome to
[contact us through a Preview issue](https://github.com/Dash1971/maia-chess-android-preview/issues/new)
to help test devices, document protocols, and expand supported models. The
[board testing guide](docs/ELECTRONIC_BOARD_DEV.md) describes the supported
workflows and the [Grand Kingdom acceptance record](docs/ELECTRONIC_BOARD_GRAND_KINGDOM_26.md)
records its passed user acceptance testing, source feedback and operating limits.

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
Opening names and ECO codes come from the CC0
[Lichess chess-openings dataset](https://github.com/lichess-org/chess-openings),
pinned to the source revision recorded in
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md). Analysis Board interactions
are also informed by the open-source
[Lichess Mobile analysis experience](https://github.com/lichess-org/mobile).
Mobile Maia is independently implemented and is not affiliated with Lichess.

Chessnut support uses Chessnut's
[published e-board API](https://github.com/chessnutech/Chessnut_eBoards) and
MIT-licensed [EasyLinkSDK](https://github.com/chessnutech/EasyLinkSDK), and was
cross-checked against Roberto Marabini's GPL-3.0
[chessnutair](https://github.com/rmarabini/chessnutair) reference
implementation. Mobile Maia's Bluetooth transport uses Android's native BLE
APIs. Protocol sources, copyright notices, licence terms, and adaptation
details are recorded in [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

Grand Kingdom protocol support references
[square-off-remote](https://github.com/greghope667/square-off-remote), the
GPL-3.0-or-later Grand Kingdom implementation by
[greghope667](https://github.com/greghope667). See our
[protocol notes](docs/ELECTRONIC_BOARD_NATIVE_PROTOCOL.md) for the pinned source
and implementation details.

Game Review's move-classification and sacrifice-detection heuristics are
adapted and translated to Dart from
[En Croissant](https://github.com/franciscoBSalgueiro/en-croissant), the
open-source chess GUI by Francisco Salgueiro and contributors. Mobile Maia
retains those rules for other move grades. The 2.7 draft uses
[Open Brilly Finder](https://github.com/Dash1971/open-brilly-finder) for Brilliant
moves, with Dart feature extraction and background model inference. The pinned
upstream revision and licence details are recorded in
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

The double-press NEW GAME Chessnut e-board behavior was inspired by [MoveAPiece](https://github.com/egdels/moveapiece) by [egdels](https://github.com/egdels).

The **Max variety in opening** idea is credited to
[Maia3-tauri](https://github.com/outusuke/maia3-tauri) by outusuke. This is an
idea attribution; no Maia3-tauri source code is incorporated for this feature.

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
