# Grand Kingdom: experimental Preview 2.6 enablement

Status: draft preparation, 2026-10-28. Tracks [Preview #27](https://github.com/Dash1971/maia-chess-android-preview/issues/27).
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
write or uncorrelated `OK` never proves physical completion. A legal subsequent
physical move or explicit full-position reconciliation can acknowledge completion.
Starting a new game still requires physical setup. Interrupted movement,
midgame motor-board restoration, takebacks and Maia promotions require phone
continuation. There is no verified stop/cancel opcode, automatic replay or
arbitrary-position motor restoration.

## Before removing draft status

- [ ] Record physical en passant acceptance.
- [ ] Record background/resume and idle disconnect → Play in the app, preserving
      the game without repeated motor movement.
- [ ] Verify interrupted/restarted sessions and unsupported takeback, Maia
      promotion and reconnection paths safely require phone continuation.
- [ ] Obtain firmware/phone details and clarify the reported build code if available.
- [ ] Pass channel-policy, setup/motor, saved-session and Chessnut regressions.

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
