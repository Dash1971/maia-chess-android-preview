# Board preferences

Preview #178 adds the approved inline Board card immediately after Appearance.
`boardPreferencesV1` stores named JSON fields and drag target identifiers, never
indices. Missing or invalid fields fall back independently to the existing defaults:
coordinates, destination dots, last-move highlighting, animation and magnification
on; circular target. Interactive animation remains 150 ms; the editor retains its
previous 200 ms animation when enabled. Magnification is 2× when enabled and 1×
when disabled; the lifted drag offset remains independent.

Play and Review (including imported-PGN analysis) derive settings from the same
inherited controller. The editor takes coordinates and animation only. Preference
updates retain board widget/controller identity, the game/session and engine state.
The last-move switch uses Chessground's `showLastMove`, preserving check, selected
square, premove and engine/drawn overlays. Destination visibility uses
`showValidMoves`, which also controls available premove destination dots in the
pinned library; already committed premove indicators remain independent.

Writes are serialized; a late initialization reply cannot replace a user choice.
A failed write keeps the visible choice and reports a localized retryable error.
The existing confirmed Settings reset includes this preference and preserves saved
games/captures. Cancelling either reset or the target chooser changes nothing.

Verification covers malformed/legacy storage, restart-style controller recreation,
serialized writes, failure recovery, independent mappings, target cancellation,
retained Review selection and all ten languages at 200% text in 320×640 and
640×320 layouts. Actual Android restart/input checks must also pass before the
draft is considered ready; full Preview release qualification remains separate.

This is Preview feature work. No shared build, CI, release or cleanup helper changes
are part of #178, so no Stable tooling port applies. Stable has not been promoted.
