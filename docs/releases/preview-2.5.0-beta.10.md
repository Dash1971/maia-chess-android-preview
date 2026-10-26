# Preview 2.5.0-beta.10

Mobile Maia Preview **2.5.0-beta.10** (2510) combines reviewed PRs #198 and #199.

- Maia score circles align vertically, with an explicit 8 dp gap after the rating and 4 dp before a start-aligned percentage. Loading/equal/missing/terminal values retain fixed columns.
- **Continue from here** can connect to or reuse a Chessnut board. **Set up board** starts an untimed continuation that waits for physical pieces to match the selected position. The full FEN, side, castling/en-passant rights, rating and validated history are retained; phone play remains available.
- Connection ownership transfers between covered game, dialog and continuation. A release review regression fixed stale queued commands executing when a temporary borrower was cancelled.

**Physical Chessnut acceptance is pending.** The requester will test Bluetooth, LEDs, arbitrary positions and handoff/reconnect using this Preview. Successful controlled transport/emulator tests do not establish physical hardware acceptance.

Preview retains its package, 79M model and production signer. Grand Kingdom/DGT remain Dev-only and their arbitrary-position prototypes remain excluded from this continuation. Stable and Dev releases are unchanged.

Qualification includes exact-source GitHub Linux CI, byte-identical independent Linux reproduction, production signing/reconstruction, full ARM64/79M native suite, signed beta.9 upgrade/data checks and actual APK feature checks. Public-download verification and immediate all-host task cleanup are recorded in release evidence.

Exact-source qualification and publication evidence will be linked after verification.
