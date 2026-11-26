# Build channels and promotion status

Updated November 26, 2026. This page owns current Preview/Dev status.
Stable's own [channel and distribution status](https://github.com/Dash1971/maia-chess-android/blob/main/docs/BUILD_CHANNELS.md)
and [release procedure](https://github.com/Dash1971/maia-chess-android/blob/main/docs/RELEASING.md)
are authoritative for Stable publication.

| Channel | Published release | Package / model | Scope |
| --- | --- | --- | --- |
| Preview | [2.6.0-beta.13 / code 2613](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.13) | `com.dash1971.maia_chess.preview`, gold icon, 79M | Saved PGN analysis and optional analysis export, explicit collection import, recovery and layout improvements; Grand Kingdom supported. |
| Dev | [2.6.0-alpha.2-dev](https://github.com/Dash1971/maia-chess-android-preview-dev/releases) | `com.dash1971.maia_chess.preview.dev`, red icon, 5M | Historical snapshot retaining the former scanner prototype. Future builds follow current source policy. Automatic detailed tracing is Dev-only. |

Both install beside blue-icon Stable with separate app data. PGN transfers games
and supported annotations, not app preferences or live clock/motor state.

## Current source policy

Chessnut and Grand Kingdom are supported. Grand Kingdom has passed user
acceptance; custom-position continuation remains Chessnut-only. See the
[hardware testing table](../README.md#electronic-board-support) and
[Grand Kingdom acceptance record](ELECTRONIC_BOARD_GRAND_KINGDOM_26.md).
Pegasus is withdrawn from current source and Preview 2.6 because initialization
licensing and downstream redistribution remain unresolved; the
[support decision](decisions/2026-11-22-electronic-board-support.md) explains the distinction
from GPL-licensed protocol references. Older APKs retain their original payloads.

The former camera/image prototype is withdrawn from source and published
Preview. Open Board Scanner is a 2.7 candidate pending F-Droid licensing
clarification; see the [roadmap](../README.md#roadmap).

## Release instructions

Follow [Preview/Dev releasing](RELEASING.md). Official Preview requires its full
exact-source qualification, independent Linux reproduction, signing, installed
Android/upgrade checks and published-download verification. Dev follows the
separate lightweight procedure and identity. Both require immediate owned-output
cleanup at the point specified in their procedures.

[Testing Preview](TESTING_PREVIEW.md#from-preview-to-stable) explains promotion.
[Stable 2.6.0](https://github.com/Dash1971/maia-chess-android/releases/tag/v2.6.0) is published on GitHub and Zapstore after separate exact-source qualification. For F-Droid and other distribution progress, see [Stable distribution status](https://github.com/Dash1971/maia-chess-android/blob/main/docs/BUILD_CHANNELS.md). Preview and Dev versions above are unchanged.
See [release records](releases/README.md) and [historical channel records](releases/HISTORY.md)
for dated evidence.

<details>
<summary>Earlier section links</summary>

- <a id="beta14-baseline-for-stable-24"></a>[Beta.14 baseline for Stable 2.4](releases/HISTORY.md#beta14-baseline-for-stable-24)
- <a id="dev-260-alpha2-publication"></a>[Dev 2.6.0-alpha.2 publication](releases/HISTORY.md#dev-260-alpha2-publication)
- <a id="dev-limitations"></a>[Dev limitations](releases/HISTORY.md#dev-limitations)
- <a id="grand-kingdom-owner-feedback--14-november-2026"></a>[Grand Kingdom owner feedback — 14 November 2026](releases/HISTORY.md#grand-kingdom-owner-feedback--14-november-2026)
- <a id="historical-channel-records"></a>[Historical channel records](releases/HISTORY.md#historical-channel-records)
- <a id="opening-variety-candidate-for-stable-24-historical"></a>[Opening-variety candidate for Stable 2.4 (historical)](releases/HISTORY.md#opening-variety-candidate-for-stable-24-historical)
- <a id="preview-240-beta1-publication-record"></a>[Preview 2.4.0-beta.1 publication record](releases/HISTORY.md#preview-240-beta1-publication-record)
- <a id="preview-240-beta10-publication-record"></a>[Preview 2.4.0-beta.10 publication record](releases/HISTORY.md#preview-240-beta10-publication-record)
- <a id="preview-240-beta11-publication-record"></a>[Preview 2.4.0-beta.11 publication record](releases/HISTORY.md#preview-240-beta11-publication-record)
- <a id="preview-240-beta12-publication-record"></a>[Preview 2.4.0-beta.12 publication record](releases/HISTORY.md#preview-240-beta12-publication-record)
- <a id="preview-240-beta13-publication-record"></a>[Preview 2.4.0-beta.13 publication record](releases/HISTORY.md#preview-240-beta13-publication-record)
- <a id="preview-240-beta14-publication-record"></a>[Preview 2.4.0-beta.14 publication record](releases/HISTORY.md#preview-240-beta14-publication-record)
- <a id="preview-240-beta15-publication-record"></a>[Preview 2.4.0-beta.15 publication record](releases/HISTORY.md#preview-240-beta15-publication-record)
- <a id="preview-240-beta2-publication-record"></a>[Preview 2.4.0-beta.2 publication record](releases/HISTORY.md#preview-240-beta2-publication-record)
- <a id="preview-240-beta3-publication-record"></a>[Preview 2.4.0-beta.3 publication record](releases/HISTORY.md#preview-240-beta3-publication-record)
- <a id="preview-240-beta4-publication-record"></a>[Preview 2.4.0-beta.4 publication record](releases/HISTORY.md#preview-240-beta4-publication-record)
- <a id="preview-240-beta5-publication-record"></a>[Preview 2.4.0-beta.5 publication record](releases/HISTORY.md#preview-240-beta5-publication-record)
- <a id="preview-240-beta6-publication-record"></a>[Preview 2.4.0-beta.6 publication record](releases/HISTORY.md#preview-240-beta6-publication-record)
- <a id="preview-240-beta7-publication-record"></a>[Preview 2.4.0-beta.7 publication record](releases/HISTORY.md#preview-240-beta7-publication-record)
- <a id="preview-240-beta8-publication-record"></a>[Preview 2.4.0-beta.8 publication record](releases/HISTORY.md#preview-240-beta8-publication-record)
- <a id="preview-240-beta9-publication-record"></a>[Preview 2.4.0-beta.9 publication record](releases/HISTORY.md#preview-240-beta9-publication-record)
- <a id="preview-250-beta1-publication"></a>[Preview 2.5.0-beta.1 publication](releases/HISTORY.md#preview-250-beta1-publication)
- <a id="preview-250-beta1-qualification"></a>[Preview 2.5.0-beta.1 qualification](releases/HISTORY.md#preview-250-beta1-qualification)
- <a id="preview-250-beta10-qualification"></a>[Preview 2.5.0-beta.10 qualification](releases/HISTORY.md#preview-250-beta10-qualification)
- <a id="preview-250-beta11-qualification"></a>[Preview 2.5.0-beta.11 qualification](releases/HISTORY.md#preview-250-beta11-qualification)
- <a id="preview-250-beta2-qualification"></a>[Preview 2.5.0-beta.2 qualification](releases/HISTORY.md#preview-250-beta2-qualification)
- <a id="preview-250-beta3-qualification"></a>[Preview 2.5.0-beta.3 qualification](releases/HISTORY.md#preview-250-beta3-qualification)
- <a id="preview-250-beta4-qualification"></a>[Preview 2.5.0-beta.4 qualification](releases/HISTORY.md#preview-250-beta4-qualification)
- <a id="preview-250-beta5-qualification"></a>[Preview 2.5.0-beta.5 qualification](releases/HISTORY.md#preview-250-beta5-qualification)
- <a id="preview-250-beta6-qualification"></a>[Preview 2.5.0-beta.6 qualification](releases/HISTORY.md#preview-250-beta6-qualification)
- <a id="preview-250-beta7-qualification"></a>[Preview 2.5.0-beta.7 qualification](releases/HISTORY.md#preview-250-beta7-qualification)
- <a id="preview-250-beta8-qualification"></a>[Preview 2.5.0-beta.8 qualification](releases/HISTORY.md#preview-250-beta8-qualification)
- <a id="preview-250-beta9-qualification"></a>[Preview 2.5.0-beta.9 qualification](releases/HISTORY.md#preview-250-beta9-qualification)
- <a id="preview-260-beta1-publication"></a>[Preview 2.6.0-beta.1 publication](releases/HISTORY.md#preview-260-beta1-publication)
- <a id="preview-260-beta10-publication"></a>[Preview 2.6.0-beta.10 publication](releases/HISTORY.md#preview-260-beta10-publication)
- <a id="preview-260-beta11-publication"></a>[Preview 2.6.0-beta.11 publication](releases/HISTORY.md#preview-260-beta11-publication)
- <a id="preview-260-beta12-publication"></a>[Preview 2.6.0-beta.12 publication](releases/HISTORY.md#preview-260-beta12-publication)
- <a id="preview-260-beta13-publication"></a>[Preview 2.6.0-beta.13 publication](releases/HISTORY.md#preview-260-beta13-publication)
- <a id="preview-260-beta2-publication"></a>[Preview 2.6.0-beta.2 publication](releases/HISTORY.md#preview-260-beta2-publication)
- <a id="preview-260-beta3-publication"></a>[Preview 2.6.0-beta.3 publication](releases/HISTORY.md#preview-260-beta3-publication)
- <a id="preview-260-beta4-publication"></a>[Preview 2.6.0-beta.4 publication](releases/HISTORY.md#preview-260-beta4-publication)
- <a id="preview-260-beta5-publication"></a>[Preview 2.6.0-beta.5 publication](releases/HISTORY.md#preview-260-beta5-publication)
- <a id="preview-260-beta6-publication"></a>[Preview 2.6.0-beta.6 publication](releases/HISTORY.md#preview-260-beta6-publication)
- <a id="preview-260-beta7-publication"></a>[Preview 2.6.0-beta.7 publication](releases/HISTORY.md#preview-260-beta7-publication)
- <a id="preview-260-beta8-publication"></a>[Preview 2.6.0-beta.8 publication](releases/HISTORY.md#preview-260-beta8-publication)
- <a id="preview-260-beta9-publication"></a>[Preview 2.6.0-beta.9 publication](releases/HISTORY.md#preview-260-beta9-publication)
- <a id="preview-acceptance"></a>[Preview acceptance](releases/HISTORY.md#preview-acceptance)
- <a id="release-instructions-1"></a>[Release instructions](releases/HISTORY.md#release-instructions-1)
- <a id="stable-24-promotion-boundary"></a>[Stable 2.4 promotion boundary](releases/HISTORY.md#stable-24-promotion-boundary)

</details>
