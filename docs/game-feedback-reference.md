# Game sound and haptic reference

Reference implementation: Lichess Mobile commit
[`56eddc238fe485eb49beb6f3c4b483afd3624b93`](https://github.com/lichess-org/mobile/tree/56eddc238fe485eb49beb6f3c4b483afd3624b93).

The pinned Lichess implementation plays distinct move and capture sounds. Its
move-feedback service uses light haptics for ordinary moves and captures and
medium haptics when the move gives check. It uses the `dong` sound when a game
starts or ends. Mobile Maia adopts the accepted-move mapping and game-end tone,
then adds an explicit rejected-input event required by Preview issue #18.

| Accepted event | Sound | Haptic |
| --- | --- | --- |
| Normal move | `move.mp3` | Light impact |
| Capture | `capture.mp3` | Light impact |
| Normal move giving check | `move.mp3` | Medium impact |
| Capture giving check | `capture.mp3` | Medium impact |
| Rejected move input | `error.mp3` | Medium impact |
| Game completion | `dong.mp3` | Medium impact after the final move |

Mobile Maia intentionally does not reproduce Lichess replay sounds. Browsing
history, Game Review, Analysis Board moves, restored sessions, reconnects, and
takebacks are silent. Phone sounds and haptics are also suppressed throughout
Chessnut games so they do not duplicate the physical board's independent
**Board sounds** setting.

The **Game sounds** and **Haptic feedback** preferences are independent,
enabled by default, stored locally, and available under **Advanced**. Audio and
haptic failures are non-fatal on unsupported or muted devices.
