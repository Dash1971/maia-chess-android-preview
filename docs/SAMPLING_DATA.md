# Opt-in Maia sampling data (draft)

This feature implements Preview issue #122. It is off by default, entirely
local, and separate from Copy diagnostics. It observes actual Maia **play**
requests; analysis-board probability displays and Stockfish are not captured.
Turning it off stops new captures and retains existing data. Requests already
started while enabled may finish recording their outcome.

## Storage and user controls

Engine settings offers Save Maia sampling data, its information button, Export
sampling data and Clear sampling data. The preference survives restart. Export
uses Android's document picker and streams JSON Lines to the location the user
chooses. No Internet/storage permissions or automatic uploads are added.

Capture files live under the app's private `sampling-data/` directory, never in
Recent Games. **At 64 MiB, the oldest captured games are deleted first, as whole
groups.** Saved games/PGNs are unaffected. The active game and requests still in
flight are protected. If an exceptionally long active game fills the entire
allowance, further records are dropped and the export reports the loss; the
limit is not exceeded. Individual records are limited to 512 KiB. Export early
if you want to retain an older capture.

There is no guarantee of a complete game: enabling midway, turning capture off,
clearing data, a process kill, storage failure, or backpressure can leave gaps.
Every record and the manifest say `captured-decisions-only`. `pending` is an
incomplete checkpoint, **not** evidence that the move was played. Clear invalidates
in-flight capture tickets before deleting files, so a late result cannot restore
cleared data.

Pending input and final outcome are written atomically on worker isolates.
There are at most eight in-flight tickets, and new capture stops accepting work
at 16 queued writes (terminal writes for accepted tickets may still enqueue).
Gameplay never awaits a capture write or an export. The actual sampler consumes
exactly its existing random draw; identifiers do not use its RNG. Raw probability
calculation, float encoding, hashing and file I/O happen off the UI isolate.
Input/output snapshots and the small sampling trace are copied synchronously.

An export is a coherent cutoff in the write queue. Captures can continue after
that cutoff. Two temporary export copies can use approximately another 128 MiB
while the document picker is open, in addition to the 64 MiB store and the file
at the chosen destination. The Dart and native temporary files are removed when
the picker finishes; Clear also removes the internal export. Android may reclaim
the cache copy. A process kill may leave a temporary file until the next export
or Clear. There is no automatic expiry of the captured games.

## JSON Lines schema 1

UTF-8, one JSON object per line, newline terminated:

1. `type: manifest`: schema/algorithm versions, coverage, creation time,
   `prunedGames`, `droppedRecords`, `storageErrorObserved`, and interpretation of
   pending records. Dropped counts cover missed writes/requests, not necessarily
   distinct moves. Storage errors are known errors in the current process; a
   process kill cannot reliably record its own failure.
2. Decision envelopes: `record` is a JSON **string** containing the payload;
   `sha256` hashes the UTF-8 bytes of that exact string. Parse and verify it
   before interpreting the nested JSON. This avoids cross-language JSON
   canonicalization assumptions.
3. `type: footer`: record count and `contentSha256`, SHA-256 of **all preceding
   bytes**, including the manifest and every terminating newline. The footer
   itself is excluded. A missing footer means the export is incomplete.

Each payload contains:

- `requestId`, `gameId`, generation, zero-based ply within this played segment,
  FEN, side, FEN full-move number and timestamps. Game ID persists with the
  session; takebacks retain it, new games/Continue from here receive a new ID.
  Request ID distinguishes retries and revisiting the same position.
- App version/code/flavor, configured model identity and verified-model hash,
  ONNX Runtime version and CPU provider. `sourceRevision` is empty if the
  build did not supply `--dart-define=MAIA_SOURCE_REVISION=<commit>`; do not infer
  a commit from it. Injected evaluators are identified separately in tests.
- Actual ratings, history flag, ordered position history, continuation prefix,
  effective padded eight-FEN window, exact input tensor and returned logits.
  Tensor/logit objects contain `encoding: float32-le-base64`, float count,
  base64 bytes and SHA-256 of those decoded bytes. The layout is `[64, 97]`,
  eight 12-piece planes per square plus the zero ponder channel. Each FEN is
  oriented for its own side to move. Non-finite output remains representable
  in the binary encoding and is rejected before sampling.
- `cache: no-play-policy-cache`; queue stage; the actual legal UCI move order
  and model indices; raw legal probabilities; sampling trace below.
- `outcome`: `pending`, `committed`, `cancelled-or-stale`, `clock-expired`,
  `invalid-output`, `timeout`, or `error`. Only committed records contain the
  actual move and resulting FEN. Input/result FEN hashes permit identity checks.
  Errors record the exception type rather than an unbounded exception dump.

The game grouping is an optional additive session field, `samplingGameId`.
Legacy sessions without it get a fresh local ID; there is no migration or saved
chess-data rewrite requirement.

## Sampler `mobile-maia-sampler-v1`

The trace records requested and effective Temperature/Top-P, selected UCI,
legal move order, and `mode`. Ratings/history are frozen at inference submission;
Temperature/Top-P are the values the sampler actually used when output arrived.

- Temperature <= 0: first highest legal logit in the original legal move order.
  Mode is `argmax`, `random` is null, and no draw occurs.
- Otherwise temperature is clamped to [0.001, 1], Top-P to [0, 1]. Divide legal
  logits by temperature, subtract their maximum, and exponentiate. Sort weights
  descending. The trace stores the **actual resulting order**, including ties.
- Retain the smallest prefix reaching Top-P, including the crossing move. Top-P
  1 retains every candidate; Top-P 0 retains the first. The latter still draws
  once, preserving existing behavior.
- Multiply the recorded `draw` by retained weight `total`. In order, subtract
  each weight and select the first where the remainder is <= 0; fall back to
  the final candidate on floating-point remainder. Do not replace this with a
  different summation order when checking exact boundary cases. `lower`/`upper`
  describe the selected weight interval; `target`, `nucleusCount`, and every
  sorted candidate weight are recorded.
- Raw legal probabilities use unscaled logits: `exp(logit - max)` divided by
  their total in original legal order. These are separate from the distribution
  after temperature/nucleus filtering.

`test/support/sampling_replay.dart` independently checks exported checksums,
input planes, vocabulary indices, legal policy, nucleus and selected draw,
and the resulting board, with stage-specific assertion messages. This is app
regression code, not a research data collection tool. Research reports, datasets
and standalone analysis tools belong in
[mobile-maia-research](https://github.com/Dash1971/mobile-maia-research).

## Qualification before leaving draft

Automated coverage is in `test/sampling_capture*_test.dart`. The small Qf5
fixture is explicitly a **reconstructed desktop** output, not a recovered phone
trace. Neither unit tests nor widget tests with a mocked native channel prove
real ONNX inference, Android document-provider behavior, or phone performance.

Before merge/release, verify an actual Android build through normal play and
export/replay (including the Qf5 position), document-provider save/cancel,
process restart, and capture-on/off overhead in 1+0. Exercise takeback/branch,
resume and Continue from here, settings changes and interrupted inference.
Do not label this feature release-qualified solely because host CI is green.

### Initial host evidence

The initial full Flutter run passed 934 tests with one existing flavor-gated
skip; the additional takeback/branch capture regression passed separately.
Static analysis and both localization checks passed. All ten locale settings
and help dialogs were exercised at 320 × 568 with 150% text scaling.

On this Mac, a debug host microbenchmark measured roughly 6–7 µs per plain
sample, 18 µs with the trace callback, and 0.13–0.18 ms of synchronous capture
work per decision. Two asynchronous checkpoint writes averaged about 5 ms
including worker startup and disk I/O in a small store. These are observations,
not timing guarantees or phone/bullet/full-store qualification.
