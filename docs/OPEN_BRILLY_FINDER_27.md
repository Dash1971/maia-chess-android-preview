# Open Brilly Finder — target Preview 2.7

Draft implementation for [#273](https://github.com/Dash1971/maia-chess-android-preview/issues/273).
Not published. Android performance and exact-source release qualification remain
pending; the checks below are host tests. Stable is unchanged.

## Classification contract

The pinned [Mute Exchange reference](https://github.com/Dash1971/open-brilly-finder/tree/59cab58a8b63387d9775252f03a6875fe451f697/studies/brilliant-exchange-2026-11-22)
is ported to Dart. A candidate leaves a knight, bishop, rook or queen legally
capturable for a static-exchange gain of at least two pawns. The model scores
91 features from that board and existing Stockfish evidence. Its cutoff is
`0.8193002847777424`; the score is not a calibrated probability.

The exact 480,186-byte asset has **222 exported trees**. Upstream describes a
400-tree training cap; no weights are regenerated to match that description.
Source/model hashes and licenses are in [model provenance](../MODEL_PROVENANCE.md)
and [third-party notices](../THIRD_PARTY_NOTICES.md).

- Inputs: previous position when present, before/after positions, played move,
  actual pre-move top two root lines and the post-move best line. A position
  with only one legal move does not require an invented second alternative.
- Centipawn inputs convert from White to mover perspective and clamp to ±9000.
  Mate uses sign × (10000 − 10 × min(distance, 99)); mate zero is −10000,
  matching the reference. Empty, illegal, duplicate, inconsistent or incomplete
  root evidence cannot produce a Brilliant award.
- Existing Blunder, Mistake and Dubious grades take precedence. A new Brilliant
  may replace Good, Interesting or an unmarked move. An old Brilliant rejected
  by the model falls back to Interesting when eligible under the existing rule,
  otherwise it is unmarked. Other grading rules and graph scores stay unchanged.
- Final Brilliant awards require agreement with the previous complete search
  iterations, or independent before/after confirmation in the same analysis
  mode at no shallower depth. A refuting confirmation withdraws the award.
  The existing six-search-unit confirmation budget is unchanged; each Brilliant
  confirmation costs two searches. Exhausting it does not authorize an
  unconfirmed award.

Production Review loads the verified model, then parses it and computes board
features/inference in its cancellable worker. No new runtime, engine, network
request, setting or permission is added. Model loading failure follows the
existing classification-error path; it does not silently use old Brilliant
rules. The legacy oracle remains for differential tests and explicitly injected
test evaluators. Cancellation, generation checks and engine lifecycle ownership
remain with Review.

PGN still uses `$3` for `!!`. Saved awards restore as before; reanalysis replaces
quality symbols on the analyzed line. Model features/scores are not saved. The
existing Include analysis option still governs save/share/copy exports.

## Validation snapshot — November 28, 2026

| Check | Result |
| --- | --- |
| Exact upstream parity | 360 cases; all 91 features within 1e-10, model score within 1e-9, award decisions identical |
| Constructed reference boundaries | 17 cases covering both colors, castling, en passant/history, pins, all promotions/underpromotions, first move and checkmate |
| Actual Review flow | Fast/Balanced/Thorough: confirmed award, refutation with unchanged graph, cancellation without stale publication |
| Integration | Missing evidence, bounded confirmation, worker cancellation/replacement, mate perspective, PGN round trip, replacement and stripped export |

The old/new comparison reuses existing Mobile Maia Stockfish 18 and Stockfish
Light fixtures: **821 move snapshots, 17 analysis runs, six distinct games**.
These are recorded engine outputs, not independent Brilliant ground truth.

| Recorded engine evidence | Previous classifier | New integration |
| --- | ---: | ---: |
| Brilliant awards | 23 | 27 |
| Changed awards | — | 10 added; 6 withdrawn |
| Changes unrelated to Brilliant | — | 0 |

The [visual gains/losses catalog](https://github.com/Dash1971/mobile-maia-research/blob/9bb772b7a0563389b8951bb379eb5646a7a7418d/studies/brilliant-classification-2026-11-28/REPORT.md)
shows every changed position before/after, all available engine/mode rows,
and all 29 changed labeled reference cases. It is proposed in
[research PR #23](https://github.com/Dash1971/mobile-maia-research/pull/23).

| Distinct move | Change | Changed engine/mode snapshots |
| --- | --- | --- |
| Byrne–Fischer 11...Na4 | Interesting → Brilliant | SF18 Balanced only; already Brilliant in the other five recorded modes |
| Byrne–Fischer 15...Nxc3 | Interesting → Brilliant | All six recorded modes |
| Byrne–Fischer 19...Ne2+ | Brilliant → Interesting | All six; the exchange offer gate fails |
| Opera game 13.Rxd7 | Unmarked → Brilliant | All three SF18 modes; no Light Opera runs were recorded |

The same moves can recur across analysis modes; these are not 821 unique games.
Complete recorded prior iterations supported all 27 new awards without fresh
confirmation searches. This does not measure future search cost across games.

The upstream parity subset also includes observed labels. It is a selected
regression subset, containing development examples, **not a held-out test**:

| 360-case labeled subset (57 positive labels) | Previous classifier | New integration |
| --- | ---: | ---: |
| Awards matching recorded Brilliant labels | 17 | 40 |
| Awards outside recorded Brilliant labels | 2 | 2 |
| All Brilliant awards | 19 | 42 |

There are 24 newly recovered labels and one lost label. The two previous
outside-label awards are withdrawn and two different outside-label awards are
added. This is not evidence of zero false positives or a population accuracy
claim. Error-grade precedence removes three raw reference-model awards.
Upstream results use different engine evidence; they are not imported as Mobile
Maia performance claims, and this does not reproduce a private classifier.

One Mac host comparison took 3.40 seconds for the previous classifier and
3.83 seconds for the new integration over all 821 snapshots, excluding engine
work. This is a single host sample, not an Android latency or memory measurement.
Before publication, measure worker memory/latency and additional confirmation
cost with the actual Android engine package; exercise background/resume,
engine-off, navigation, saved-game and installed PGN flows.

## Reproduce host checks

Use the workspace's shared Flutter SDK and existing package cache:

```sh
flutter test --no-pub test/brilliant_exchange_parity_test.dart test/open_brilly_integration_test.dart test/review_annotation_pipeline_test.dart
flutter test --no-pub test/open_brilly_comparison_test.dart --reporter expanded
python3 tool/open_brilly_assets_test.py
```

The exact upstream parity fixture is test-only, excluded from app assets. The
constructed edge generator is `tool/hardening/brilly/generate_edges.mjs`. To
regenerate it outside the checkout, fetch the pinned TypeScript (SHA-256 in the
notices), put the exact model beside it as `noSweatBrilliantExchangeModel.json`,
and use Node 24 with `chessops@0.15.1` / `@badrap/result@0.3.1`. Add only Node's
`with { type: 'json' }` attribute to the model import; do not modify the algorithm.
Pass absolute paths:

```sh
node tool/hardening/brilly/generate_edges.mjs /scratch/reference/exchange.ts /scratch/brilly-exchange-edges.json
```

Compare the generated file byte-for-byte with the checked-in edge fixture. The
Node packages and adapter are reference tools only, not production dependencies.
No Android builds, Actions or LFS downloads are part of this draft's host checks.
Shared build/release tooling is unchanged, so no Stable tooling companion applies;
this Preview feature can reach Stable through a separately approved promotion.
