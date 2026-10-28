# Grand Kingdom: experimental Preview 2.6 enablement

Status: experimental draft, updated 2026-10-29. Tracks [Preview #27](https://github.com/Dash1971/maia-chess-android-preview/issues/27).
The owner requested this draft after the first positive hardware report. This is
source preparation for 2.6; no version bump, APK publication or Stable promotion
is included. Published Preview 2.5 artifacts still exclude Grand Kingdom.

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
| Captures and castling | OK |
| Human promotion | OK |
| Screen and physical position agreement | OK |
| En passant | Not tested yet |
| Background/resume, connection loss, phone continuation without repeat movement | Not tested yet |
| Reset, multiple-board discovery, denied permission, Bluetooth/power interruption | Not established |

This is evidence for one tester's Grand Kingdom on the older 5M Dev build, not
other Square Off products, every firmware or the future 79M Preview candidate.
Protocol provenance remains in
[ELECTRONIC_BOARD_NATIVE_PROTOCOL.md](ELECTRONIC_BOARD_NATIVE_PROTOCOL.md).

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

The maintainer will contact the owner; this PR sends no outreach. Use a separately
qualified 2.6 candidate when it is prepared. This PR itself publishes no APK.
Published Dev alpha.2 does not contain this assisted-promotion flow.

1. Record the exact APK version/source, board model/firmware, phone and Android
   version. Confirm ordinary games, captures, castling and both playing colors
   still work; repeat en passant, which is not yet physically established.
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

1. Qualify assisted promotions and the existing en-passant/lifecycle paths with
   the owner, fixing observed firmware-specific behavior before readiness claims.
2. Improve bounded diagnostics/recovery instructions using those results; preserve
   the distinction between an idle live session and uncertain motor delivery.
3. Investigate full midgame reconnection and takebacks only after establishing a
   reliable reconciliation/firmware protocol. Never infer motor cancellation or
   reset completion from `RSTVAR` or automatically replay movement commands.

## Before removing draft status

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
