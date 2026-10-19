# Sampling defaults and help — 2.5 proposal

Draft only: no merge, Android APK build or publication. The existing green dark
appearance is shown in the screenshots; Appearance PR #156 is a separate change.

## Behavior

- New play/primary analysis rating: 1500; second analysis: 2600, still opt-in.
- New/reset engine defaults: Temperature 1.0, Top-P 0.95, opening variety on.
- Existing explicit preferences are retained. There is no bulk migration, key
  version bump or saved-game rewrite. The legacy MaiaPlaySettings constructor
  and restore fallback deliberately retain their old off behavior.
- Settings reset applies these new engine/analysis values. As before, Home's
  chosen play rating and saved games are outside that Settings reset.
- The first five **full moves for both colors** use 1.0/1.0 when variety is on;
  configured values take over at move 6. FEN numbering governs continuation.
- At Temperature 0, Top-P displays “Not used”, is disabled and has independent
  help. Its saved value is preserved, including across restart. It becomes
  usable again when Temperature rises. No silent 0/0 trap is introduced.
- At full 1/1: a neutral notice mentions unusual blunders. Below T1/P0.95 with
  variety off: a neutral repertoire notice. T0 or P0: a strength notice, explicitly
  “from move 6” when the opening override is enabled. If both restrictions apply,
  both relevant notices appear. New recommended defaults need no warning.
- Explanation selection affects text only, starts on Simple, and is not another
  stored setting. Both levels link to the same visual research guide.
- The sampler, inference calls, analysis percentages and capture format do not change.

## UI previews

Actual Flutter widget renders at 412 × 892 logical pixels, using the current
default dark theme. Desktop rendering fonts differ from Android. No APK build.

| Default settings | Temperature zero |
| --- | --- |
| ![New defaults](settings.png) | ![Top-P unused](top-p-unused.png) |

| Simple explanation | Technical explanation |
| --- | --- |
| ![Simple help](simple.png) | ![Technical help](technical.png) |

[Top-P information dialog](top-p-help.png) · [Japanese help](japanese.png)

Long dialogs scroll; their Close action stays available. The source copy below
includes the portions below the screenshot fold.

## Review copy

### Simple explanation

Temperature and Top-P combine to set the amount of variety in Maia’s play.

Think of Temperature as Maia’s willingness to consider unusual moves. At 0, it always chooses the move it thinks a human at the selected rating is most likely to play. At 1.0, it keeps the full mix of human moves—like a creative bullet player willing to try a crazy sacrifice. Popular moves are still more likely than wild ones.

Top-P is like the angel on Maia’s shoulder. At 1.0, it lets every candidate through. Lower it, and it cuts the least likely moves from the list. At 0, only a most likely move remains. It filters by popularity, not by whether a move is good or bad.

In our earlier research at the 1600 setting, always picking the most likely move (argmax) was strongest among the settings tested: about 300 Elo ahead of 1.0 / 1.0 in direct matches. But it also narrowed the opening choices.

Max variety in opening keeps Temperature and Top-P at 1.0 / 1.0 for the first five moves by each side, then uses your settings from move 6. You might see some crazy things in the opening!

Our recommended defaults are opening variety on, Temperature 1.0 and Top-P 0.95. This keeps a creative player with an angel on its shoulder: after the opening, moves from the least likely tail, together worth up to 5% of the chance, are left out. That can remove blunders, but also good surprises. Blunders are still possible. For a tougher opponent, try Temperature 0. With opening variety on, that takes effect from move 6. Good luck!

### Technical explanation

Temperature rescales the model’s legal-move logits before softmax. At T > 0, each weight is exp((logit − maximum logit) / T), then normalized. T = 1 preserves the model distribution; lower T concentrates it on higher-scoring moves. T = 0 selects an argmax directly and ignores Top-P.

Top-P sorts the temperature-adjusted probabilities from highest to lowest and keeps the smallest prefix reaching the threshold, including the move that crosses it. Retained probabilities are normalized again before sampling. P = 1 keeps all moves; P = 0 keeps one highest-probability move. P = 0.95 removes at most 5% of total probability, not all moves individually below 5%.

Defaults: Temperature 1.0, Top-P 0.95, Max variety in opening on. The override uses 1.0 / 1.0 at FEN full-move numbers 1–5 for either color, then the configured values from move 6. Resuming or continuing a position does not restart that count. Analysis-board percentages remain the model’s probabilities before these play settings.

With the 79M model and history off, the proposed defaults scored 60.7% against 1.0 / 1.0 in 600 games at rating input 1600 (95% interval 56.8–64.6%). Earlier argmax tests gave a roughly 300-Elo matchup advantage. These are direct-match results, not calibrated human ratings. Five moves is a design choice, not a proven optimum; probability filtering cannot guarantee good moves.

### Opening variety

On by default. Uses Temperature and Top-P 1.0 / 1.0 for the first five moves by each side, then your configured settings from move 6. This keeps broad opening choices while allowing you to trim low-probability moves later. It follows the position’s move number, including when resuming or continuing a game.

Not needed at 1.0 / 1.0: the switch is off and unavailable because those settings already give full variety throughout.

### Top-P at Temperature zero

At Temperature 0, Maia always chooses a most likely move, so Top-P has no effect. Your Top-P value is kept and becomes available again when you raise Temperature. If Max variety in opening is on, the first five moves by each side still use 1.0 / 1.0.

## Research companion and release order

[Research companion PR #3](https://github.com/Dash1971/mobile-maia-research/pull/3) adds the guide in the dedicated research repository at
`guides/choosing-maia-settings/README.md`. Merge that companion first and verify
its public main-branch URL before merging/releasing this app change. Existing
research links and archived study evidence are retained.

A merge dry run with PR #156 found conflicts in localization catalogs, generated
localizations and terminology/review documentation, but no Dart application-code
conflicts. Reconcile both sets of source strings, regenerate localizations, and
rerun localization, host regressions and Android qualification on the actual
combined source before publishing Preview. This PR does not merge
that appearance dependency or qualify it for Android/F-Droid.

## Verification

Host regression coverage includes new/reset defaults, explicit preference
preservation, malformed preference fallback, first-five-move boundaries for both
colors, restored profiles, capture probabilities, takebacks, board reset and
continued games. Thirteen explicit notice scenarios cover the recommendation
boundaries, deterministic settings and both opening states. All ten languages exercise Simple/Technical selection,
research navigation, dismissal and Top-P inactive help at 320px and 200% text.
Screenshots come from Flutter widget rendering, not an installed Android APK.
Android/device checks remain a later publication gate.

Local full-suite result: **1,084 passed, 3 skipped**. After refining the notice
regression into explicit boundary examples, all 12 tests in
`sampling_defaults_test.dart` passed again. Static analysis and localization
contract/reference checks also passed.
