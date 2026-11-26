# Offline board scanning — Preview 2.7 draft

In Board Editor, tap the outlined camera beside Share, then **Take a photo** or
**Choose a photo**. Recognition reads the image locally and loads the pieces into
the existing editor. Correct pieces there, set position details through the
existing controls, then use Analysis Board or Continue from here.

This follows Lichess Mobile's [Board Editor camera placement](https://github.com/lichess-org/mobile/blob/378270dcf71b654cffe8a891a41acd0334507416/lib/src/view/board_editor/board_editor_screen.dart)
and [photo-source flow](https://github.com/lichess-org/mobile/blob/378270dcf71b654cffe8a891a41acd0334507416/lib/src/view/board_editor/board_from_image.dart).
There is no Home shortcut, Analysis Board camera, separate review screen or
confirmation checkbox. Android supplies the camera and document picker.

The input supplies piece placement only. A successful reading resets the draft
to White to move, no castling rights or en-passant square, and counters 0/1.
These details remain editable. Scanning changes only the editor's draft;
existing game/analysis storage is untouched until the normal editor action.
Cancellation, failed recognition and malformed results preserve the previous
draft. Invalid chess positions remain editable and use the existing validation
before analysis or play.

## Model and scope

Uses Open Board Scanner's two INT8 models from
[models-v1](https://github.com/Dash1971/open-board-scanner/releases/tag/models-v1),
with the reference pipeline pinned to
[`dee0475dfc2cda96c0f6aa50e003536d53592ab1`](https://github.com/Dash1971/open-board-scanner/tree/dee0475dfc2cda96c0f6aa50e003536d53592ab1).
The Kotlin port uses the existing ONNX Runtime dependency, two finder passes,
perspective correction and four reader orientations. No additional native
inference or image-processing library is introduced.

| Asset | Bytes | SHA-256 |
| --- | ---: | --- |
| `boardfinder-v1-int8.onnx` | 1,428,260 | `92df98ca72bf8c9c67196a134188b3cc005681d35262724172ba61f705625f4f` |
| `boardnet-v4-int8.onnx` | 2,030,978 | `bf07e26ed1f7cd27ee5b75049b5c8fd261b157de89b026e968e779355c16ef80` |

Total model payload: **3,459,238 bytes**, about 3.5 MB. Actual APK size and
Android latency/memory have not been measured. The supported target is screenshots
and photographs of printed two-dimensional diagrams, not physical 3D boards.
Dense pages may select the wrong diagram; select a tighter source image and retry.
Automatic orientation is fallible; use the existing editor controls to correct it.
Blank/near-uniform inputs are rejected before inference.

The publisher licenses the code and weights under AGPL-3.0-only. Its
[model notice](../assets/board_scanner/MODEL-LICENSE.md) discloses noncommercial
training artwork and copyrighted diagram photographs. F-Droid acceptance of
that licensing basis remains unresolved. This draft does not claim F-Droid
approval or authorize publication. The original withdrawn scanner/model and
Pegasus remain withdrawn. Stable 2.6 is unchanged.

## Image handling

No new permissions or network calls. Images use scoped URI grants and private
temporary files, never gallery insertion, diagnostic capture or upload. Inputs
are limited to 16 MiB, decoded to at most 1600 pixels on the longer side, and
EXIF orientation is applied. Only a small re-encoded preview crosses to Flutter.
Temporary files and URI grants are released after success, failure or cancellation;
abandoned private files are cleaned at startup. If Android recreates the activity
during camera capture, a stale result is discarded rather than replacing a draft.
Inference sessions close after each scan instead of remaining loaded alongside Maia.

## Verification

November 26 host validation: **1,652 tests passed**, including 40 new scanner cases; final focused scanner/editor checks: **68 passed**. Flutter analysis reports no issues. Production Kotlin checks: **27 passed**; the Android image-source adapter also passes a host JVM source type check. These checks do not replace installed Android tests.

- `test/board_scan_test.dart`: photo/camera choices, direct editor return,
  cancellation, late disposal, error preservation, FEN metadata reset, scoped
  platform responses, and all ten languages at phone portrait/landscape and
  tablet sizes with 200% text.
- `android/native_test/BoardScanCoreTest.kt`: production Kotlin geometry,
  decoding/orientation and blank-input regressions. With the desktop ONNX Runtime
  and upstream generated integration fixtures, the production core gives the exact
  reference placement and orientation for all three images; corners differ by less
  than one pixel. These are integration fixtures, not a fresh accuracy holdout.
- `tool/board_scanner_assets_test.py`: exact bundled/runtime model pins, license
  notice, scoped provider path and absence of broad image/camera/network permissions.

Android APK/device tests, external-camera/provider behavior, lifecycle and
EXIF checks on actual Android, resource/performance measurements, merged APK
permissions and release qualification remain outstanding. No Android builds,
Actions or LFS downloads were used to prepare this draft.

Related: [#179](https://github.com/Dash1971/maia-chess-android-preview/issues/179).

Run the JVM checks with the existing cached Kotlin compiler, an installed JDK,
and the official desktop ONNX Runtime 1.24.3 JAR (not the Android AAR):

```sh
python3 tool/run_board_scan_jvm.py --java "$JAVA_HOME/bin/java" \
  --runtime /path/to/onnxruntime-1.24.3.jar --scratch /path/to/owned/bulk \
  --fixtures /path/to/upstream/docs/integration
```

The helper makes no downloads and requires a scratch directory initialized with
`tool/build_workspace.py`. Omit `--fixtures` for the synthetic decoder/geometry
checks. The fixture images stay in scratch; no research photo dataset is copied
into this application repository. This feature and its checks are Preview-only;
shared release/build/cleanup helpers and Stable source are unchanged.
