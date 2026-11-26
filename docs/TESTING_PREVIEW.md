# Testing Preview

Preview is the gold-icon, 79M prerelease app. Preview beta.13 currently offers
the same features as Stable 2.6.0; it remains the testing channel for future
changes. It installs beside blue Stable
and red Dev with separate app data; installing one does not transfer the other's
games or preferences. Follow [Obtainium installation](../README.md#install-and-update-with-obtainium)
and enable prereleases for the Preview repository.

## Reports

Report Preview bugs in [Preview issues](https://github.com/Dash1971/maia-chess-android-preview/issues)
and Stable bugs in [Stable issues](https://github.com/Dash1971/maia-chess-android/issues).
Link an existing cross-channel/hardware thread rather than duplicate it; maintainers
will coordinate reports affecting both. New board reports go to the running channel’s tracker.
[Stable #15](https://github.com/Dash1971/maia-chess-android/issues/15) is the closed
Grand Kingdom hardware-feedback and delivery record.

Include the exact version/channel, device, Android version, steps, expected and
actual behavior. A small PGN/FEN, relevant screenshots or explicitly exported
user-reviewed diagnostics help. Remove private information before posting.
Security reports use [private vulnerability reporting](../SECURITY.md).

## Current and planned work

The 2.6 features below are also released in Stable 2.6.0. Use
[current channel status](BUILD_CHANNELS.md) for published versions and the
[roadmap](../README.md#roadmap) for plans. Preview 2.6 includes Grand Kingdom,
PGN transfer, recovery and analysis improvements. Pegasus and the former camera/
image prototype are withdrawn. Open Board Scanner and Open Brilly Finder are
candidates under investigation, not already delivered features. Hardware testing
coverage is recorded separately from supported-device status.

## From Preview to Stable

A tested Preview beta is followed by owner acceptance, a separate Stable
promotion PR, and Stable's own exact-source CI, independent canonical Linux/
F-Droid reproduction, signing, installed upgrade/native checks and download
verification. GitHub, F-Droid and Zapstore have separate delivery states.
[Stable 2.6.0](https://github.com/Dash1971/maia-chess-android/releases/tag/v2.6.0) completed that process and is published on GitHub and Zapstore. F-Droid delivery is tracked separately in [Stable distribution status](https://github.com/Dash1971/maia-chess-android/blob/main/docs/BUILD_CHANNELS.md). Follow
[Stable's release procedure](https://github.com/Dash1971/maia-chess-android/blob/main/docs/RELEASING.md).
