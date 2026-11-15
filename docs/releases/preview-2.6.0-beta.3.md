# Preview 2.6.0-beta.3

- Withdraws the unreliable camera/screenshot board-recognition prototype (#224), including Home Scan board, the editor image entry, native capture/classification bridge and bundled diagram model. Manual Board Editor, FEN import/share, Analysis and Continue from here remain available. Existing published beta.2/Dev APKs are unchanged.
- Recent Games selection mode can save or share selected games as one PGN file, including Select all (#226/#225). Games follow displayed newest-first order and retain supported metadata, comments, clocks and variations.
- Batch exports allow 5 MiB (5,242,880 UTF-8 bytes, including separators). Imports and the individual-game parser retain 2 MiB. An oversized/missing/invalid selection never dispatches a partial export; selection is retained for correction and retry.

Preview continues to use the 79M model. Grand Kingdom remains experimental with its previously documented capture failures and hardware acceptance pending. DGT stays Dev-only. Stable and Dev app releases are unchanged; lower-memory/real-phone export acceptance remains separate.
