# Preview 2.6.0-beta.13 — 23 November 2026

[Published prerelease](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.13) · [PR #267](https://github.com/Dash1971/maia-chess-android-preview/pull/267) · [release #269](https://github.com/Dash1971/maia-chess-android-preview/pull/269)

Computer analysis persists White-perspective evaluation/mate comments and standard quality NAGs in the existing PGN/game record. Reopen restores the graph and markings without another full-game run. Include analysis is checked by default in the existing Save/Share/Copy and collection-export menus. Uncheck to strip only exported evaluations and the six quality glyphs; prose, clocks, variations and other positional annotations remain. Reanalysis replaces scores/glyphs on that line. There is no new database, engine registry, dependency, permission or persistent export setting.

## Exact-source qualification

- Frozen source/tag: `f1b3c4fa94b2e8aef7aa75a0143ea43406f6495d` / `v2.6.0-beta.13`, code 2613, Preview 79M.
- [CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/45110359708): 1612 main Flutter tests, channel policies, localization/terminology, analyzer, native policies, verification-tool checks and Android packaging passed. 251 focused local behavior tests passed. Editorial translation review was not repeated.
- Canonical GitHub and independent Linux unsigned SHA-256: `5f7010010d633097b3e3cfe3c869e46134beec51983d206a9f541c343f146ac1`.
- Signed APK SHA-256: `6a62899a6829a0523ca93be4e2feac4ef24b3274bcb9dddd19dd90a9063c53ee`; 455584808 bytes. Existing Preview signer `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`. Signature reconstruction used the actual independent APK and matched byte for byte.
- Model SHA-256: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`. Identity, artwork/licence notices, ABIs/alignment, 79M-only payload and retired prototype/image exclusions passed.
- Full 16 core ARM64/native checks, two additional real 79M checks, 3000 independent oracle positions, 512 variation trees and 27 promotion regressions passed on this exact source.
- Actual production-signed beta.12→beta.13 upgrade preserved UID, explicit settings, game and capture data. Real 79M play with history off/on passed. Three temporary-key fixture upgrades preserved duplicate-takeback, incomplete and checkmate active/archive/restart semantics.
- Actual signed-APK tests generated annotations using Stockfish/classification and retained the original game identity; verified graph restoration through Recent and process restart; exercised included/stripped Save, real separate-UID Share grants and clipboard; restored missing-initial and custom Black-to-move imports without a full rerun; kept malformed input open without filling it; verified combined-limit rejection/retry, stripping before the limit, near 5 MiB collection save and stripped Copy from a source over 2 MiB. Independent python-chess reading checked PGN semantics. The separate Android probe verifies actual delivery/clipboard access, not universal OEM reader compatibility.
- Frozen app-source verification passed 107 Preview and 152 Stable-counterpart Python checks. The classification fixture follows the Preview-only callback API; no port to the unpromoted Stable API applies. Stable #83 merged into draft #82, not Stable main. Separate reusable operator improvements passed 130 Preview and 166 Stable-default Python checks, including 23 behavioral regressions; all eight shared files are byte-identical in [Stable tooling companion #85](https://github.com/Dash1971/maia-chess-android/pull/85), which remains a draft. They were used for the installed checks without changing the frozen APK source or release gates.

## Upstream review and driver diagnostics

The [fresh same-day review](../dependency-audit-2026-11-23-preview26-beta13.md) includes 63 exact-version OSV queries and 23 hash-verified update archives with scoped deferrals. ONNX GitHub release/advisory endpoints returned 404; fresh official servicing/Maven and exact-version OSV were reviewed. Unavailable feed coverage remains explicit.

The initial driver attempts failed on assumptions about absent fresh-install preferences, the optional VM-service flag, active checkpoint versus archive persistence, offscreen controls, share delivery without a chooser, probe layout/casing and Review page titles. The final large-source Copy attempt also expected Review controls for an incomplete game that correctly opens Game controls. Diagnostics from those failures remain separate from the passing observations. These were operator failures; no corresponding application defect was found.

[Release test setup](../RELEASE_TEST_SETUP.md) now documents the tested contracts. Shared helpers validate actual checkbox metadata and visible bounds, distinguish a delivered share from a chooser, select controls by operation, track active/archive phases, require unique output names and launch the optional audit with its VM-service flag. A reusable separate-UID receiver verifies real URI/clipboard transfer. The absent-preferences path requires no checkpoint and no app PID; recovery guards are preserved. The fixes have 23 regression tests and an identical Stable companion (#85). Affected checks completed on the same signed APK, retaining successful expensive work; no native suite or Linux release build was repeated for driver errors. Physical-device/OEM coverage remains a verification limit.

## Public verification and cleanup

The APK, checksum and verification bundle were downloaded publicly and matched their qualified hashes/GitHub digests. The public APK's established signer, model, identity, unsigned source payload and retirement checks passed. Public-verification and cleanup receipts are separate release assets and were read back. Checked all-host cleanup preceded documentation CI.

- mac: 79.61→90.14 GiB free; task scratch, intermediates and qualified source retired.
- linux: 22.61→27.38 GiB free; task scratch, intermediates and qualified source retired.
- signing: 15.53→16.48 GiB free; task scratch, intermediates and qualified source retired.

Task APK/model copies, test environment, emulator and Linux container were removed. Shared caches/toolchains, keys and other active work remain. Compact final evidence is verified in the Mac mini archive at completion. Stable 2.5.1/Dev alpha.2 releases remain unchanged. Grand Kingdom acceptance remains passed; Pegasus remains withdrawn.
