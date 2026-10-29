# Assisted screenshot/diagram import: 2.6 prototype

Tracks [#179](https://github.com/Dash1971/maia-chess-android-preview/issues/179).
The image-import feature PR remains draft, separate from Grand Kingdom. Its
original implementation is in red-icon Dev 2.6.0-alpha.1; the camera addition below
is new source work and is not in that published APK. No new version, release,
package/signing identity, e-board policy or Stable source changes in this update.
Keep the issue open and this PR in draft pending broader acceptance below.

## Workflow and safeguards

In the Preview/Dev board editor, choose From image, then Choose image or Take
photo. Neither source launches automatically. Choose image uses Android 13+'s
system photo picker, with `ACTION_OPEN_DOCUMENT` on older systems or when the
picker is unavailable. Take photo delegates `ACTION_IMAGE_CAPTURE` to the installed
camera, including FOSS camera apps, without requiring a named app or Google SDK.
No camera, media/storage, media-location or Internet permission is added.

The camera receives a temporary read/write grant to one random JPEG in the app's
private `cache/board-image-capture/` folder through its existing non-exported
FileProvider. Only that narrow cache subdirectory is added to the provider; no
root/cache-wide path is shared. The result is read from this output URI even when
the camera's result Intent is null; thumbnail extras and other returned URIs are
ignored. Duplicate results cannot start a second decode. Completion, cancellation,
launch/decode failure and activity teardown revoke the grant and remove our output.
The next bridge startup prunes abandoned capture files after process death; it
does not restore an unfinished import. Android can keep the external camera task
open after Maia is stopped; dismiss that camera before cold-launching Maia.
Unrelated cache/gallery files are untouched.
A camera app's own independent storage/settings remain under that app's control.

Both inputs use the same bounded decoder, EXIF rotation/mirroring normalization,
and metadata-free PNG conversion. Camera metadata, including location fields, is
not forwarded to Flutter, logged or saved as a recognized position. No persistent
URI grant, gallery insertion, image diagnostics, cloud recognition or upload is
introduced. A missing/failing camera shows a localized Choose image alternative;
cancel or a late result cannot alter the original editor.

The source is limited to 16 MiB compressed, dimensions at most 20,000 per axis
and 100 million source pixels, and decoded with sampling to at most 1536 per
axis. PNG is returned to Flutter in memory. Crop all 64 squares using a drag or
the accessible horizontal/vertical range sliders. Find board reruns grid
localization; manual selection can override the wrong board in a multi-board
image. Rotate image handles quarter-turns; explicitly choose Black at the bottom
for an inverted diagram. Photograph printed diagrams directly from above. Real three-dimensional boards
and perspective correction remain outside the workflow; this adds an input source,
not improved classification or perspective recognition.

Grayscale, alpha compositing, lattice detection, area-resampling and rule-assisted
square decoding are adapted from the pinned MIT CrispChess diagram pipeline.
CPU preprocessing runs in a separate isolate without capturing widget/native
state. Inference uses the already bundled Android ONNX Runtime and a short-lived
session/tensor/result, all closed after each operation. The 835,655-byte model is
loaded directly from the APK asset without a second permanent model file.
Model bytes and SHA-256 are verified before inference. No second runtime or
first-use download is introduced.

Recognition opens a separate manual editor draft. All squares remain editable,
including confident false pieces such as the benchmark's arrow-induced queen
on c6. Nothing is applied merely because confidence is high. Choose the side to
move explicitly; castling/en-passant start at none and counters at 0/1. Position
settings allow correction of all FEN metadata. Done/Analysis/export remain
unavailable until the side and full review are confirmed; edits revoke review.
Existing legal-position validation is still required. Confirming returns the
FEN to the original editor; its normal Analysis / Continue from here actions
retain the existing parent-session replacement rules. Cancelling the picker,
crop, inference or review leaves that original position unchanged. Late results
from disposed widgets/activities are ignored. Activity/process recreation discards
the temporary image/import operation; it does not commit recognized placement.

## Provenance and known quality limits

[Model/code pins](../third_party/board_image/provenance.json),
[MIT licence](../third_party/board_image/LICENSE),
[weight-specific grant and training-source attribution](../third_party/board_image/NOTICE.md).
CrispChess revision `0d01798daf9661076675f8505b4cc6995a6529da`;
model SHA-256 `2408717e2e0e2ed438e2f9f89f85c2e544326cef34a0c91b95168bd17336df47`.
The runtime performs the same square classifier, not the incompatible Lichess
ChessQ weights or CrispChess's physical-photo models.

The [published baseline](https://github.com/Dash1971/mobile-maia-research/blob/main/studies/board-image-import-2026-10-28/REPORT.md)
remains authoritative. This implementation adds assisted framing/correction; it
does **not** claim improved arrow or print/font classification accuracy. The
high-confidence c6 failure is a mandatory-review/correction regression, not a
claim that the detector now recognizes arrows. Fresh holdout quality and
lower-end Android performance are still required before broad support claims.
The raw model payload is not a measured APK or installed-size increase.

## Translation sources

Existing chess/editor/FEN terms use the pinned Lichess catalogs. The inspected
image-import UI at Lichess `c73864de4c6373637a5442e2a0f7c3a37fbb930e`
(`board_from_image.dart`, `board_editor_screen.dart`) uses hard-coded English
photo/reading labels and has no localized equivalents for this crop/review flow
in the ten supported catalogs. New app-specific image-import messages therefore
have reasoned native-language wording in all ten catalogs, not English fallbacks.
The additional Choose image / Take photo platform actions follow Google's
[Android image-note help](https://support.google.com/keep/answer/6395566?co=GENIE.Platform%3DAndroid&hl=en),
inspected in all ten actual locales (`en`, `ja`, `zh-Hans`, `ko`, `es`, `de`, `fr`,
`ru`, `hi`, `pt-BR`). The platform labels were present in those languages; the
camera-specific top-down printed-diagram and fallback instructions retain
Mobile Maia's meaning in native-language prose. These are wording references,
not runtime Google dependencies. No Lichess equivalent is invented for this
app-specific camera/import workflow.
Catalog/terminology checks and 320px/200% review layouts are covered; native-speaker
review of new prose remains outstanding.

## F-Droid design boundary

[Android's permission-minimization guidance](https://developer.android.com/privacy-and-security/minimize-permission-requests#take-photo)
explicitly supports delegated camera capture without declaring CAMERA.
The existing AndroidX FileProvider and platform EXIF APIs add no dependency.
Under the current [F-Droid anti-feature definitions](https://f-droid.org/docs/Anti-Features/),
this design adds no proprietary dependency/service, tracking or non-free asset;
camera use alone is not an anti-feature. This is a design assessment, not an
F-Droid acceptance decision. Stable promotion still requires its normal source,
licence, build/scan and reproducibility gates.

## Draft / release acceptance still required

- [x] Compile the native camera/import bridge locally and exercise AOSP camera
      capture, cancellation, missing handler and interrupted-import cold-start
      cleanup on an API 36 ARM64 emulator. This is not OEM/real-phone acceptance.
- [ ] Validate OEM/FOSS cameras, missing camera, cancellation, full-size output,
      EXIF orientations, temporary URI scope, activity/process recreation and
      output cleanup on real phones.
- [ ] Validate real system picker and Google-free SAF fallback, cancellation,
      permission denial/provider revocation, corrupt/oversized input and activity
      recreation; verify prior position/session preservation.
- [ ] Measure native latency, peak memory and model lifetime on lower-end Android.
- [ ] Measure packaged APK and installed/app-private storage separately; inspect
      merged-APK permissions including all transitive manifests and model hash.
- [ ] Demonstrate fresh-install airplane-mode operation and no retained images.
- [ ] Improve arrow/overlay and print/font failures and remeasure whole-board
      accuracy/correction burden on fresh reserved inputs before broad readiness.
- [ ] Complete language/accessibility and actual-image crop/rotation review.
- [ ] Before Stable release, perform its separate promotion, canonical Linux/
      F-Droid scans/build and signed/developer-APK reproducibility, preserving
      upstream tag-based automatic updates and signing/package continuity.

Stable main `0957d87` was inspected. No companion feature PR applies: this is the
Preview 2.6 prototype and Stable has no image import/model. The host native-test script adds the new feature-specific capture/EXIF checks;
Stable has no camera-import feature to port them to. All four shared build/cleanup
files and canonical release wrappers remain unchanged. The Dev snapshot wrapper
also carries forward the generated-path normalization already published in Dev
source `5c43145`, with a clean before preparation to prevent stale incremental
kernels retaining the old absolute path. Stable has no Dev wrapper and its
canonical wrapper already cleans and performs that preparation, so no companion
port applies. Preserve the normal Linux
build/independent reproduction and full Preview release gates; this PR publishes
no APK and does not complete F-Droid qualification.
