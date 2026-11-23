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

## Community

Join the [Mobile Maia forum on Mute Chess](https://mutechess.org/forum/mobile-maia) to ask
questions, share games, discuss settings, and help test Preview. Discussions
are publicly readable; posting uses a Nostr identity on Mute Chess.

Please keep using the relevant GitHub issue tracker for reproducible bugs
and feature requests.

## Current Preview status

The latest Preview release is [2.6.0-beta.12](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.12). **Recent games → ⋮ → Import PGN** saves every game from a file, including single-game files. Analysis opens only the first game and explains how to import a collection. Returning Home no longer allows a lifecycle autosave to create another saved copy. Matching 5 MiB import/export limits, duplicate detection, transactional saving and progress remain. Grand Kingdom is supported with passed user acceptance; Pegasus and camera/image recognition remain withdrawn. Preview uses 79M. [Qualification and cleanup](docs/releases/preview-2.6.0-beta.12.md) record this release. Stable remains 2.5.1; Dev remains 2.6.0-alpha.2-dev; Stable 2.6 approval and qualification remain separate.

See the [Stable user guide](https://github.com/Dash1971/maia-chess-android#readme) for released features and the [Preview release history](https://github.com/Dash1971/maia-chess-android-preview/releases) for release notes and verification. The roadmap below covers future work.

## Feature guide

### Recent games and PGN files

[Preview beta.12](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.12) provides **Recent games → ⋮ → Import PGN**, including in an empty list. It adds every validated game from a file, including a single game, without replacing the current game. Matching PGNs and repeats within a file are skipped; different annotations or metadata remain distinct. **Analysis Board → Open PGN file / Load PGN** opens only the first game and points to Recent games for a collection. Android Open with/shared attachments retain their previous routing: one game opens for analysis; a collection imports into Recent games. Both directions allow 5 MiB of UTF-8. Longer imports show progress after 300 ms. Invalid collections and storage failures expose no partial import; abandoned staging is cleaned on repository access after restart. The Home-transition autosave fix prevents newly created duplicate records; existing duplicates are not automatically merged or deleted. See the [import/export guide](docs/RECENT_GAMES_PGN_EXPORT.md).

Bulk export is published in Preview 2.6.0-beta.3 ([#226](https://github.com/Dash1971/maia-chess-android-preview/pull/226)). Long-press a Recent games entry or choose
**Select games**, select the games to export (or use **Select all**), then choose
**Export games → Save PGN file** or **Share PGN**. The result is one `.pgn` file,
in the displayed newest-first order, containing each selected game's supported
headers, result, moves, comments, clocks and variations.

Exports allow up to **5 MB** (5 MiB / 5,242,880 UTF-8 bytes, including separators).
The number of games that fit depends on their length and annotations. If the
selection exceeds the limit, export stops before opening the save/share chooser
and asks you to select fewer games. It does not save a partial collection,
silently omit games, or split the export automatically. Your selection and saved
games stay unchanged; deselect some games and try again. Missing or unreadable
selected games also stop the whole export.

Recent games import accepts every validated game in a file up to the shared 5 MiB limit. Analysis opens only the first game within that same whole-file size limit. PGN transfers games and supported annotations, not app settings or live clock/motor checkpoints. Everything works offline, with no automatic upload. An oversized individual export shows its own error and retains selection for retry.

## Roadmap

**Explicit PGN import and Home-save fix: Preview beta.12**

[PR #265](https://github.com/Dash1971/maia-chess-android-preview/pull/265) is delivered. Recent games has an explicit all-games import action; Analysis opens the first game; Home/background autosaves retain one original saved-game identity. Existing duplicate records are left intact. These changes await the separate Stable 2.6 promotion.

**PGN collection transfer and supported-board policy: Preview beta.11**

[PR #261](https://github.com/Dash1971/maia-chess-android-preview/pull/261) is delivered. Collection import, duplicate skipping, progress, shared size limits and export retry are published. Grand Kingdom is supported; Pegasus is withdrawn from current source and this Preview. [Stable promotion #82](https://github.com/Dash1971/maia-chess-android/pull/82) remains a separate unmerged draft.

**Game recovery and analysis resume: Preview beta.10**

Issues [#253](https://github.com/Dash1971/maia-chess-android-preview/issues/253),
[#254](https://github.com/Dash1971/maia-chess-android-preview/issues/254) and
[#255](https://github.com/Dash1971/maia-chess-android-preview/issues/255) are delivered.
Interrupted games remain manually recoverable from Recent games, damaged
temporary saves no longer hide the committed game, and the same open Review
resumes its unfinished full analysis after a brief interruption.
[Completed-report persistence after app restarts (#61)](https://github.com/Dash1971/maia-chess-android-preview/issues/61) remains separate; Stable promotion is separate.

**Saved-game Back returns to Recent games: Preview beta.6**

Back retraces the current browsing flow: opening a saved game from Recent games
then pressing Back returns to the list at the same scroll position. Home always
goes Home and clears that temporary position. Unfinished-game confirmation,
result-dialog dismissal and analysis navigation are preserved. No setting or
persistent navigation history is added. [Stable #77](https://github.com/Dash1971/maia-chess-android/issues/77)
tracks reporter confirmation; Stable promotion remains separate.

**Delivered in Preview: export selected games as one PGN**

[Selection, ordering, size limit and verification](docs/RECENT_GAMES_PGN_EXPORT.md).

Preview 2.6.0-beta.3 includes bulk PGN export; Stable promotion remains separate. Select individual
games or use Select all in Recent Games, then save or share one PGN file
containing the selected games for use in external analysis tools. Thanks to
@Earthless85 for the [suggestion](https://github.com/Dash1971/maia-chess-android/issues/74).
Implementation and verification are tracked in
[Preview #225](https://github.com/Dash1971/maia-chess-android-preview/issues/225).

**Offline board scanning: acceptable candidate; shipping decision pending**

The November 15 follow-up to our
[model investigation and visual comparison](https://github.com/Dash1971/mobile-maia-research/blob/main/studies/offline-board-recognition-2026-11-13/REPORT.md)
finds **ChessQ Lite V4 INT8 accuracy acceptable on our twelve-photo test set**.
Its 41.4 MB ONNX model matched the 63.1 MB V4 model on all full-photo placements
(10/12 exact positions); the smaller V5 model performed worse. These are desktop
results on a small set, with broader accuracy and Android performance unverified.

**We have not decided to restore scanning.** We need to weigh APK size, device
support and the published noncommercial license, including distribution and
F-Droid implications, before deciding. ARM64 packaging could offset the added
model size but would change device coverage; no packaging change is approved.
The plan does not depend on obtaining a more permissive license.

Preview 2.6.0-beta.3 removes the prototype, including its bundled diagram model.
Historical Preview beta.2 and the unchanged Dev alpha.2 APKs still contain it. Manual Board
Editor, FEN import, Analysis and Continue from here remain available. See
[the original proposal (#179)](https://github.com/Dash1971/maia-chess-android-preview/issues/179).

**Expand electronic-board support**

**Square Off Grand Kingdom** support is included in Preview 2.6 and Dev. **DGT Pegasus** is withdrawn from all channels because initialization licensing is unresolved. The Stable 2.6 promotion remains a separate draft. The [owner’s follow-up](https://github.com/Dash1971/maia-chess-android/issues/15#issuecomment-6863134393) attributes the earlier wrong/missed captures to hardware drift after many moves without calibration or an uneven surface, on firmware **36v5**, and reports good overall operation. The owner subsequently reported a successful game on the 79M Preview build. Preview includes assisted Maia promotion. Grand Kingdom has passed user acceptance testing. Automatic local diagnostics remain a red-icon Dev feature. Diagnostics are never uploaded automatically; Settings → Save Dev diagnostics… exports locally for voluntary sharing. The Pegasus prototype is removed from the updated source; see the support decision below. The [2.6 acceptance record](docs/ELECTRONIC_BOARD_GRAND_KINGDOM_26.md) records passed user acceptance testing, the source feedback, historical regression cases and operating limits.

We’re looking for owners of these boards who are willing to help test and report their results. See the [board testing guide](https://github.com/Dash1971/maia-chess-android-preview/blob/main/docs/ELECTRONIC_BOARD_DEV.md) and [Grand Kingdom issue](https://github.com/Dash1971/maia-chess-android-preview/issues/27).

**Expanded language support and native-speaker review**

Mobile Maia currently supports **English, Japanese, Simplified Chinese, Korean, Spanish, German, French, Russian, Hindi, and Brazilian Portuguese**. We would like to expand language support with native speakers who can help validate translations in the app. See the [localization guide](docs/L10N_REVIEW.md) for coverage and contributor instructions.

We would particularly like to hear from **Arabic, Hebrew, and Farsi (Persian) speakers**. These languages need careful testing of right-to-left layouts alongside chess notation, clocks, and evaluations. See the [right-to-left language issue](https://github.com/Dash1971/maia-chess-android-preview/issues/84).

**Adaptive layouts: available in Preview 2.6.0-beta.4**

Landscape gameplay and Analysis use more board height with controls beside the
board. Wide Home/Settings use columns, and Recent games uses a compact table
with a two-line fallback for narrow windows or large text. [Implementation and
Android qualification](docs/ADAPTIVE_LAYOUTS_26.md) record phone/tablet/constrained
profiles and rotation/input checks. [#29](https://github.com/Dash1971/maia-chess-android-preview/issues/29)
is closed for Preview delivery. Comfortable physical finger input, tablet-owner
feedback, gesture-navigation and actual split-screen checks remain recorded
verification limits; Stable promotion is separate. Published beta.9 keeps engine analysis visible while moves scroll independently, including endpoint jumps. Landscape tabs share the bottom control strip. Large text permits independent header scrolling. [Behavior and verification](docs/ANALYSIS_SCROLL_26.md) separate host renders from production APK checks; physical touch/tablet acceptance remains open.

**Under consideration: candidate moves and a rating explorer**

We are considering tappable analysis candidates that show Maia’s move probabilities alongside Stockfish evaluations, plus an optional view of how move preferences change across ratings. The [analysis candidates and Moves by rating issue](https://github.com/Dash1971/maia-chess-android-preview/issues/200) contains the proposed scope and interactive mockups for discussion.

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

Requirements: **Flutter 3.47.8** (pinned in `.fvmrc`), JDK 17, Android SDK 36,
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

## Electronic-board support

Support planned for Stable 2.6 and the updated Preview/Dev sources:

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
contain the retired prototype; no published APK is changed by this source PR.

Board owners and manufacturers are welcome to
[contact us through an issue](https://github.com/Dash1971/maia-chess-android/issues/new)
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
