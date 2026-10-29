# Grand Kingdom: experimental Preview 2.6 enablement

Status: experimental draft, updated 2026-10-29. Tracks [Preview #27](https://github.com/Dash1971/maia-chess-android-preview/issues/27).
The owner requested this draft after the first positive hardware report. This is
source preparation for 2.6. The later combined
[Dev 2.6.0-alpha.1 snapshot](https://github.com/Dash1971/maia-chess-android-preview-dev/releases/tag/v2.6.0-alpha.1-dev)
publishes the assisted-promotion prototype for testing; the original feature PR
remains draft. Preview/Stable publication and physical acceptance are not
included. Published Preview 2.5 artifacts still exclude Grand Kingdom.

## Physical evidence

[Tester report, 2026-10-28](https://github.com/Dash1971/maia-chess-android/issues/15#issuecomment-6468925765):
Square Off Grand Kingdom, Android 17 / SDK 37, app `2.4.0-alpha.2-dev`.
The supplied diagnostic says `build=240` (published alpha.2 records 2402); retain
this discrepancy rather than inferring the installed APK identity. Device field
was `ZZZ`; specific phone model and firmware were not supplied.

| Scenario | Reported result |
| --- | --- |
| Discovery, connection and standard setup confirmation | OK |
| Ordinary play as White and Black, Maia opening/motor replies | OK for the grouped instructions |
| Captures | Initially OK; later two physical capture failures reported (below) |
| Castling | Initially OK; no isolated castling failure reported |
| Human promotion | OK |
| Screen and physical position agreement | Initially OK; later contradicted by capture failures |
| En passant | Not tested yet |
| Background/resume, connection loss, phone continuation without repeat movement | Not tested yet |
| Reset, multiple-board discovery, denied permission, Bluetooth/power interruption | Not established |

This is evidence for one tester's Grand Kingdom on the older 5M Dev build, not
other Square Off products, every firmware or the future 79M Preview candidate.
Protocol provenance remains in
[ELECTRONIC_BOARD_NATIVE_PROTOCOL.md](ELECTRONIC_BOARD_NATIVE_PROTOCOL.md).

### Additional capture failures: priority blocker

[Follow-up, posted 2026-10-28 at 18:29 UTC](https://github.com/Dash1971/maia-chess-android/issues/15#issuecomment-6477270546):
after more than ten games, the same owner reported two failures while playing
White. The first game's final `19...Bxf8` should remove White's knight on f8;
instead the board removed the pawn on f6. In the second game `7...Nxb4`
left White's pawn on b4. The owner is trying to reproduce the first failure.
These reports supersede the blanket positive capture/synchronization summary;
capture reliability is unresolved and blocks readiness before promotion testing.

Reported game A (`Result "*"`):

```pgn
1. e4 e5 2. Nf3 d6 3. g3 Bg4 4. Bg2 Bxf3 5. Bxf3 Qe7 6. O-O Qd8 7. Nc3 Nc6 8. b3 Nd4 9. Bb2 Nxf3+ 10. Qxf3 f6 11. Rfe1 Ne7 12. a4 Nc6 13. Nd5 Nd4 14. Bxd4 exd4 15. Qd3 c6 16. Nf4 Be7 17. Qxd4 O-O 18. Ne6 Qe8 19. Nxf8 Bxf8 *
```

Reported game B (`Result "0-1"`, player resigned):

```pgn
1. e4 e6 2. d4 c5 3. dxc5 Bxc5 4. Nf3 Qb6 5. Qe2 Nc6 6. c3 d6 7. b4 Nxb4 0-1
```

Expected final engine coordinates are `e7f8` and `c6b4`, respectively. Neither
history contains a promotion; game B also contains no castling. Assisted
promotion therefore does not address these ordinary capture failures. Both PGN
headers label Black `Maia-3 79M (1300)`. The current PGN exporter in
`lib/src/play.dart` uses a fixed `Maia-3 79M` label, so this does not establish
the APK/model identity or contradict use of the smaller Dev model. Record the
actual version/source and model diagnostics for each reproduction.

Source review: the current adapter follows the pinned reference's standard-start
`RSTVAR` → `GAMEWHITE/GAMEBLACK`, legal-human-input `OK`, and four-coordinate
engine move flow. There is no established separate capture command. The PGNs do
not show actual BLE frames, motor timing or the first physical divergence, so
they cannot distinguish app ordering/state, firmware bookkeeping and mechanical
failure. Do not add a guessed capture opcode, delay, reset or command retry.
Local position confirmation does not resynchronize firmware piece bookkeeping.
A legal following move is also insufficient to prove the entire physical board
matches the game after a missed/wrong capture.

For the maintainer's next owner request:

- Replay each complete history from confirmed standard setup; do not jump to a
  manually arranged midgame position. Game B is the shorter first case. A normal
  Maia game need not select the same replies; exact replay may require a later
  controlled Dev scenario using the normal human/engine command path.
- Compare screen and physical board after every move, especially `7...Nxb4`
  and `19.Nxf8` / `19...Bxf8`. Record the first divergence, which piece moved,
  which piece was removed, and whether motors had stopped before the next input.
- Record firmware, phone/Android, actual APK version/source/model, fresh-start
  versus successive-game behavior, and any intervening background/disconnection.
  If practical, provide a short video and reviewed app diagnostics. The existing
  `tool/board_capture` recorder is Chessnut-only, not a Grand Kingdom trace tool.
- After a mismatch, wait for stopped motors and continue on the phone. Do not
  retry the move, send a midgame reset or assume physical rearrangement repairs
  firmware state. Start any later board test with explicit standard setup.

The capture-feedback follow-up changed documentation only. The later Dev
2.6.0-alpha.1 snapshot was built locally with checksum-verified existing models,
without Actions or LFS downloads. It does not change or certify the reported
physical captures. Actions/LFS downloads remain on hold while bandwidth is
constrained; the [release record](releases/dev-2.6.0-alpha.1.md) separates
automated/emulator evidence from pending board acceptance.

## Proposed channel behavior

| Board | Preview 2.6 source | Dev | Stable / unflavored / unknown |
| --- | --- | --- | --- |
| Chessnut | Allowed | Allowed | Allowed |
| Grand Kingdom | Experimental | Experimental | Blocked |
| DGT Pegasus | Blocked | Prototype, locked firmware unsupported | Blocked |

Dart event/candidate handling and native discovery, remembered-device connection,
configuration, writes and motor methods enforce this boundary. Native motor
methods require the current ready Grand Kingdom session. Legacy Chessnut saves
continue to select only Chessnut boards.

Enable Electronic board, connect and explicitly confirm the standard physical
position. Games use Unlimited time. Engine movement is sent once; a successful
write or uncorrelated `OK` never proves physical completion. For ordinary moves, a legal subsequent physical move or explicit full-position
reconciliation can acknowledge completion. Promotions always require explicit
piece-replacement confirmation.
Starting a new game still requires physical setup. Interrupted movement,
midgame motor-board restoration and takebacks require phone continuation.
Maia promotions now have the assisted flow below; physical acceptance is pending.
There is no verified stop/cancel opcode, automatic replay or arbitrary-position
motor restoration.

## Assisted Maia promotion (29 October)

The app keeps the full legal UCI move, including `q/r/b/n`, in the game, PGN and
pending physical-move checkpoint. Before any motor command the checkpoint is
saved. Only the four square coordinates are sent to the unchanged native motor
method, matching `make_move()` in the pinned square-off-remote reference. No
new promotion-piece opcode, motor-completion response or cancellation command
is assumed.

Once the write callback succeeds in the same foreground session, the banner
names the destination and Maia's selected piece. Its confirmation action opens
instructions to wait for stopped motors, replace the pawn and inspect the entire
position. The dialog includes a frozen full-board diagram of the actual promoted
position, independent of move-history selection; confirmation returns the main
board to the live position. Continue stays disabled until the user checks the explicit replacement
confirmation. Cancel leaves the promotion pending; Play in app preserves the
logical game and exits board control. An `OK`, a subsequent legal human move or
a synthetic position event cannot confirm a promotion. Human input stays blocked
until explicit confirmation; the stored promotion suffix never gets discarded.

A successful write is only a transport milestone. If delivery is interrupted or
fails, the pending move is retained and phone recovery is offered without retry.
If the same connection survives a background/resume after delivery, the user
must reopen and explicitly confirm the physical position; an old dialog or late
confirmation cannot advance the game. Confirmation calls are serialized. Restart
and disconnection keep the full pending move and never replay it; live motor-board
restoration remains unavailable. Even a game-ending promotion retains its
physical checkpoint across restart, and its automatic result dialog waits for
confirmation or explicit phone continuation.

Automated policies test the logical/transport state machine. They do not prove
that the firmware handles physical replacement or subsequent underpromotion
moves correctly. This remains experimental and in draft until that evidence is
recorded.

## Owner testing plan

The maintainer will contact the owner; this task sends no outreach. Use the
published red-icon Dev 2.6.0-alpha.1 snapshot for the current prototype and record
its exact version/source. Older Dev alpha.2 does not contain assisted promotion.
The original feature PR remains draft pending physical acceptance.

1. Resolve and physically retest the two capture failures above first, recording
   exact APK version/source/model, board firmware, phone and Android version.
   Then confirm ordinary games, captures, castling and both playing colors;
   repeat en passant, which is not yet physically established.
2. Try a Maia queen promotion first. Verify one pawn movement, the correct
   destination/piece instruction, disabled continuation before the checkbox,
   manual replacement, full-position confirmation and normal subsequent play.
3. Repeat non-capturing and capturing promotions for Maia as White and Black.
   Then test rook, bishop and knight underpromotion. Verify the firmware does not
   silently impose queen behavior or lose synchronization on subsequent moves.
4. Cancel/reopen the prompt; try background/resume while waiting for replacement,
   disconnect when motors are idle, restart with a pending promotion and choose
   phone continuation. Verify the same full promotion/game remains and there is
   no repeated motor movement. Report physical position versus screen separately.

Start from the standard setup. Arbitrary-FEN motor initialization is not verified;
do not use manual board rearrangement as a shortcut. A complete, repeatable
underpromotion matrix may need a separately labelled maintainer-controlled Dev
scenario build from the standard position. The deterministic automated test
scripts are not a claim that normal Maia play will quickly produce every case.

## Remaining development order

1. Reproduce the reported ordinary capture failures and establish their cause;
   review initialization, accepted-human-move acknowledgement, engine-command
   ordering and physical behavior before choosing a fix. Add a regression for
   any proven app defect, then physically validate both histories.
2. Qualify assisted promotions and the existing en-passant/lifecycle paths with
   the owner once ordinary captures are reliable. Improve bounded diagnostics
   and recovery instructions using those results; preserve
   the distinction between an idle live session and uncertain motor delivery.
3. Investigate full midgame reconnection and takebacks only after establishing a
   reliable reconciliation/firmware protocol. Never infer motor cancellation or
   reset completion from `RSTVAR` or automatically replay movement commands.

## Before removing draft status

- [ ] Resolve the wrong-piece removal at `19...Bxf8` and missing removal at
      `7...Nxb4`, with repeatable physical capture/synchronization acceptance.
- [ ] Record physical en passant acceptance.
- [ ] Record background/resume and idle disconnect → Play in the app, preserving
      the game without repeated motor movement.
- [ ] Physically validate assisted Maia promotions, including captures, both colors,
      underpromotions and subsequent play.
- [ ] Verify interrupted/restarted sessions and unsupported takeback/reconnection
      paths retain the logical game and offer phone continuation without replay.
- [ ] Obtain firmware/phone details and clarify the reported build code if available.
- [ ] Recheck channel-policy, promotion/motor, saved-session and Chessnut
      regressions on the eventual candidate source.

Keep #27 open until remaining acceptance is complete. Before publishing a 2.6
Preview candidate, follow the full [Preview release procedure](RELEASING.md),
including exact-source Linux reproduction, real 79M native checks and signed
upgrade/data retention. Automated/emulator checks do not certify physical BLE
or motors. Dev publication, if requested later, uses its separate procedure.

## Stable counterpart

Stable main was inspected at `0957d87` on 2026-10-28. Its Dart policy excludes
Grand Kingdom/DGT outside Dev and its native bridge retains the Dev-only motor
guard. No companion Stable feature PR applies: this request is for the Preview
2.6 development cycle. No shared build, CI or cleanup helpers change. Stable
promotion and publication require their own acceptance and release task.

## New message terminology

The four assisted-promotion messages are Mobile Maia motor/reconciliation
instructions, with no direct Lichess equivalent. They use the existing pinned
localized piece names and algebraic square identifiers. All ten catalogs have
native-language prose; catalog/terminology and 320px/200% dialog checks apply.
Native-speaker/hardware acceptance is still separate from automated layout checks.
