# Open Board Scanner direction — 23 November 2026

Open Board Scanner is the candidate for screenshot/printed-diagram recognition
in Mobile Maia 2.7. Its two INT8 models total about 3.5 MB. The code and weights
are published under AGPL-3.0-only, with training provenance disclosed.

The project's view is that the weights are not derivative works of the training
images. F-Droid acceptance of that licensing basis remains to be clarified;
training included noncommercial piece artwork and photos of copyrighted diagrams.
This decision does not restore the former scanner or publish a new app version.

See [the model report](https://github.com/Dash1971/open-board-scanner/blob/main/REPORT.md),
[licence/provenance](https://github.com/Dash1971/open-board-scanner/blob/main/MODEL-LICENSE.md),
[Preview roadmap](../../README.md#roadmap) and [#179](https://github.com/Dash1971/maia-chess-android-preview/issues/179).

## November 26: implementation draft authorized

The approved 2.7 design follows Lichess: an outlined camera beside Share in Board Editor, Take a photo / Choose a photo, local recognition directly into the existing editor. No Home shortcut, Analysis Board camera, extra review screen or confirmation checkbox. The [implementation draft](../BOARD_SCANNER_27.md) uses the pinned models above. F-Droid licensing acceptance and Android release qualification remain separate pending checks; this authorizes a draft PR, not publication.
