# Preview 2.5.0-beta.1 release qualification

Published 2026-10-19 through [PR #158](https://github.com/Dash1971/maia-chess-android-preview/pull/158), combining Appearance #156 and sampling defaults/help #157.

- Source: `ffe8032c7082170b310013a66af59b74a7f7a0ad` (tag `v2.5.0-beta.1`).
- Package/version: `com.dash1971.maia_chess.preview`, `2.5.0-beta.1`, code `2501`.
- Signed APK SHA-256: `b37b08bfea0ad3240b6976b10b49a202643b3ac638e33a2e08739448fe9d72af`.
- Unsigned APK SHA-256: `b7c23e475b24a47dfb8ccdeb4d5ea97f9759dee773e324ad2acf0818dd8fdbb0`.
- Preview signing certificate SHA-256: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
- [Exact-source Checks run](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/39218237053): passed, including Android packaging; full suite 1,115 passed, three explicit skips, plus channel restrictions/native/verification-tool checks.

## Binary and upgrade checks

Independent Ubuntu build on macmininew matched GitHub's unsigned APK byte for byte.
Signing preserved the verified payload; applying the APK's signature to the
unsigned build reproduced the signed bytes. Packaging verified the existing 79M
model, three ABIs, ELF/ZIP alignment, release identity and absence of Internet
permission. The public release receipt verifies actual downloaded asset hashes.

An actual signed beta.15 → beta.1 installation retained the app UID, saved games,
preferences and sampling files. Restored-game semantics and explicit old engine
choices remained intact. Real 79M checks covered opening override through move 5,
configured settings from move 6 for both colors, old frozen profiles and new-game
profiles. These are emulator tests using synthetic games, not user data.

## Appearance and lifecycle checks

- Android 11: unchanged dark default, unsupported system colors disabled, light and pure-black modes.
- Android 16: real blue/red wallpaper palettes, light/dark/system, pure-black retention, restart, background/resume, reset confirmation/cancellation, large text and both help explanations.
- Final navigation-strip/button contrast checked with software navigation enabled.
- Active game and Analysis Board state restored after system brightness/background changes and real wallpaper-triggered Activity recreation; Analysis Home returned Home.
- No fatal Android or unhandled Dart exception in the checked live-state path.

Changing wallpaper can recreate an Android Activity. Settings may reopen Home
while retaining choices; this is not a guarantee that every system configuration
change keeps the same screen. Physical phones, vendor palettes/navigation styles
and Chessnut radio/LED behavior remain tester acceptance. Grand Kingdom/DGT
remain blocked in Preview. Stable 2.4.0 and Dev alpha.2 are unchanged.

## Evidence and cleanup

The [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.1)
contains the signed APK, compact verification bundle, checksums and a public
download receipt. Verification includes scripts, logs, native screenshots and
machine-readable outcomes. No signing secrets or research datasets are bundled.
Task-owned build containers/checkouts, downloaded APKs, emulator data and temporary
caches are removed after public verification; the release PR records completion.
Shared SDK/Gradle caches and active work are preserved.
