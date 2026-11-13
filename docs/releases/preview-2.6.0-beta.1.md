# Preview 2.6.0-beta.1

First Preview prerelease in the 2.6 cycle, code 2601. Includes reviewed #209, #210, #213 and #217.

- Import a screenshot or a top-down photograph of a flat printed chess diagram from the Board Editor. Recognition runs offline using a bundled MIT model and the existing ONNX runtime. Crop/orient the image, then correct the result in the same Board Editor. Real 3D-board/perspective recognition and broad accuracy claims remain outside this prototype.
- Human move timing defaults on for fresh/unset/invalid preferences and explicit Settings reset. A saved off choice stays off, including upgrades. Move selection, strength and clock rules are unchanged.
- Switching analysis engines off hides Maia score values; switching them back on respects the separate score-display preference.
- Gradle 9.9.1 addresses the three 10 November build-tool advisories. [Stable tooling companion #73](https://github.com/Dash1971/maia-chess-android/pull/73) is tracked separately.

Grand Kingdom #209 is included experimentally in Preview at the requester’s explicit direction. The two reported physical capture failures remain unresolved: wrong-piece removal at 19...Bxf8 and a missed removal at 7...Nxb4. Assisted Maia promotion requires explicit physical replacement/confirmation; it does not fix those capture problems. Hardware acceptance remains pending. DGT remains Dev-only; Stable/unflavored builds exclude both experimental adapters. Stable and Dev app releases are unchanged. Image recognition is editable assistance; real-phone/OEM camera and broader recognition-quality testing remain pending.

Full exact-source Linux/reproduction, signing, ARM64/79M native, signed beta.11 upgrade, feature and public-download verification evidence will be recorded after qualification. Task-owned bulk is cleaned immediately after public-download verification.
