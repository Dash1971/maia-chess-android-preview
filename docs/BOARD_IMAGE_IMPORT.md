# Assisted screenshot/diagram import: 2.6 prototype

Tracks [#179](https://github.com/Dash1971/maia-chess-android-preview/issues/179).
This is an unpublished draft implementation, separate from the Grand Kingdom
PR. No version, release, package/signing identity, e-board policy or Stable source
is changed. Keep the issue open and this PR in draft pending acceptance below.

## Workflow and safeguards

In the Preview/Dev board editor, choose From image. Android 13+ uses the system
photo picker; unavailable pickers and older Android versions use
`ACTION_OPEN_DOCUMENT`. No camera, media/storage, location-metadata or Internet
permission is added. Only the selected content URI is read. No persistent grant,
image file, image/position diagnostics or upload is created.

The source is limited to 16 MiB compressed, dimensions at most 20,000 per axis
and 100 million source pixels, and decoded with sampling to at most 1536 per
axis. PNG is returned to Flutter in memory. Crop all 64 squares using a drag or
the accessible horizontal/vertical range sliders. Find board reruns grid
localization; manual selection can override the wrong board in a multi-board
image. Rotate image handles quarter-turns; explicitly choose Black at the bottom
for an inverted diagram. This is not a physical-board/perspective-photo workflow.

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
The workflow deliberately says From image rather than copying its camera flow.
Catalog/terminology checks and 320px/200% review layouts are covered; native-speaker
review of new prose remains outstanding.

## Draft / release acceptance still required

- [ ] Compile and exercise the actual Android bridge and model on a device/emulator.
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
Preview 2.6 prototype and Stable has no image import/model. Existing shared build,
CI, verification and cleanup helpers are unchanged. Preserve the normal Linux
build/independent reproduction and full Preview release gates; this PR publishes
no APK and does not complete F-Droid qualification.
