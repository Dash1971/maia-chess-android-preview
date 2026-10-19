# Preview 2.5.0-beta.2 release qualification

Published 2026-10-19 through [PR #160](https://github.com/Dash1971/maia-chess-android-preview/pull/160).

- Source: `21395d26e3cff50b44ad8465404158ba86481199` (tag `v2.5.0-beta.2`).
- Package/version: `com.dash1971.maia_chess.preview`, `2.5.0-beta.2`, code `2502`.
- Signed/public APK SHA-256: `bc6513fa59b878678ac2dec8db4e3b401df0b269b141e145b16971988bd49ce8`.
- Unsigned APK SHA-256: `99fe69c2ff5fdb9c54b63932dea89875d4bd97962059f6b0ffbf6559c4dda2ce`.
- Existing Preview signing certificate SHA-256: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/39236373454): 1,126 host tests passed with three explicit skips; native/channel/tool checks and Android packaging passed. Local focused suite: 93 passed.

## Changes

Darker neutral panels in pure-black dark mode match the approved mockups;
light mode, standard dark mode, system accents and chess colors are retained.
Short strength notices omit the move-six qualifier in every language. The
Simple explanation uses the approved experienced-player and angel analogies
in all ten languages. Detailed Help still explains the opening override.
No engine algorithm, dependency, setting default or storage migration changed.

## Qualification

Independent Ubuntu and GitHub builds produced byte-identical unsigned APKs.
The existing Preview key signed the verified payload; signature reconstruction
was byte-identical. Packaging checks include version/package, model, three ABIs,
alignment and offline permissions. Actual public downloads matched the qualified
APK and GitHub asset digests.

Android 16 emulator checks covered signed beta.1 → beta.2 upgrade with preserved
UID, preferences, saved games and sampling files; real 79M opening-boundary
sampling; light/dark/system/pure-black modes; real wallpaper palettes; restart,
backgrounding, active game and analysis restoration; large text; both help modes;
and actual Settings/Analysis panel RGB values. Both shorter warning variants were
checked with opening variety on/off, including the separate limited-opening
notice and no strength warning at the recommended defaults.

Physical phones, vendor-specific rendering and Chessnut remain tester acceptance.
Android 11 was qualified for beta.1 and was not rerun for this UI-only update.
Grand Kingdom/DGT remain disabled in Preview. Stable and Dev are unchanged.

## Evidence and cleanup

The [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.5.0-beta.2)
contains the APK, verification bundle, checksums and public-download receipt.
The PR records cleanup completion. Only task-owned build/signing workspaces,
containers, APKs, emulator data and temporary caches are removed; shared tools,
signing keys and unrelated work are retained.
