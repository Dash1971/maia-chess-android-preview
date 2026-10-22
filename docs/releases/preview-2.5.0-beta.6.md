# Preview 2.5.0-beta.6 (2506)

Preview 2.5.0-beta.6 changes Hold Right inside an analysis variation to select the next move on the main line: the same destination as Hold Left followed by one normal Right tap. It uses the outermost main-line branch point, regardless of variation length, nesting or selected move, and clamps at the game’s end. Hold Left, ordinary taps and main-line endpoint holds are unchanged.

Updates existing Preview installations in place. Settings defaults, engines and models are unchanged. Stable and Dev remain unchanged; Grand Kingdom and DGT remain Dev-only.

Exact-source CI, independent Linux reproduction, established Preview signing, full ARM64/79M native qualification, actual signed beta.5-to-beta.6 upgrade and changed-feature checks are recorded in the verification bundle. Fresh upstream/security review is dated 2026-10-23, including the staged Dart certificate changes and their offline-app applicability; no dependency change was required. Physical phones and Chessnut remain tester acceptance.

Publication hashes and cleanup evidence will follow qualification.
