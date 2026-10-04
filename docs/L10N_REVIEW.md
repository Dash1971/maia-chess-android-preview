# Dev language review

This is a **provisional** UI translation of the same 119-message first slice into Japanese, Simplified Chinese for mainland China, Korean, and Spanish. Native-speaker review has not yet happened. Screens outside this slice still show English.

Review `l10n_review.csv` alongside the Dev app. Each row has a stable message ID, English source, proposed translations, and source location. For a correction, fill in **Reviewer suggestion** and identify the language; a screenshot link and a short explanation are especially useful when wording depends on chess context or available space. Leave the English source and ID unchanged. Report missing English text, clipping, unclear chess terms, or wrong context even if the proposed translation itself is grammatical.

The app's source of truth is `lib/l10n/app_en.arb`, `app_ja.arb`, `app_zh.arb`, `app_ko.arb`, and `app_es.arb`. The CSV is a review aid, not a second translation source. Approved suggestions should be applied to the ARB files and checked in the Dev app before the language is described as complete.

Keep PGN, FEN, move notation, model names, and engine protocol data untranslated. Do not put reviewer identities or private phone screenshots into this public repository without permission.

## Editorial review of Dev beta.4 (2026-10-04)

Reviewed the 119 source messages and all four translation catalogs at source commit `0c8bc529ce117e993bcc186f6d5d0d29a68fdd62`. This pass improves phrasing; it is **not native-speaker approval or a physical-device visual review**. The translations remain provisional.

The editorial patch makes timing labels describe pauses rather than move strength, uses Spanish **Elo** for ratings, replaces Korean **증분** with the clearer clock label **추가 시간**, and makes Spanish/Chinese castling checkboxes explicitly describe short/long castling. It also improves error messages, physical-board sound descriptions, and premove cancellation wording. PGN/FEN, moves, engine names, and engine behavior remain unchanged. ARB descriptions now explain the ambiguous concepts for future translators.

### Terminology and context

- Human timing affects artificial waiting only. Avoid wording that promises better human-like move selection or a trained prediction of thinking time.
- Increment is time added after a move, not an abstract numeric increment.
- “Completed illegal moves” distinguishes a finished physical-board move from a piece in transit. A literal translation of “completed” often sounds unnatural; retain the behavioral distinction in translator context.
- Takeback can undo different numbers of plies depending on turn and board mode. Avoid labels that promise exactly one ply.
- Castling controls enable the right to castle; kingside means short castling, queenside means long castling.
- Keep timing/strength, analysis/review, and phone/electronic-board terminology consistent across screens. Let native chess players review these choices in context.

### Priorities before promoting localization

1. **Finish whole user flows.** Recent Games and its deletion confirmation, resignation/draw dialogs, Chessnut connection/recovery instructions, analysis results/classifications, and help still contain English. Translate destructive warnings and recovery instructions before less critical prose. Partial coverage is already declared in the Dev release; it must remain visible to reviewers.
2. **Use stable IDs at call sites.** The temporary `appText(context, english)` switch silently returns English for an unrecognized string. An English copy edit can therefore disable translation without a compile error. Move call sites to generated localization getters/methods as the slice expands.
3. **Localize complete messages.** Use ARB placeholders and ICU plurals for counts, ratings, increments, progress, and errors instead of concatenating translated fragments. Format displayed decimals by locale (Spanish uses a comma); leave engine protocol, FEN, PGN, and SAN unchanged. Store state independently of translated text and translate status messages when rendering.
4. **Define Chinese script fallback.** The current generic `zh` locale contains Simplified Chinese and also matches Traditional-Chinese device locales. Decide explicitly whether that fallback is intended; do not present it as a Traditional translation. Spanish regional locales currently share one neutral Spanish catalog.
5. **Broaden validation.** Keep language-selection/restart tests; add system-locale changes, unsupported/corrupt saved values, saved-game continuity, and compact/large-text navigation tests. Run layout checks with actual CJK fonts and test TalkBack on a device. Host widget tests use test fonts and cannot establish real glyph quality or every truncation condition.
6. **Keep catalogs synchronized.** Generate Dart from ARB, verify every supported catalog contains the same IDs, and keep this CSV synchronized. Translation review should also check placeholder preservation and flag unexpected English fallback. When source lines move, refresh the CSV's location hints.

The patch includes a reproduced and corrected malformed-language-preference exception, reusing the existing preference-validation helper rather than deleting unrelated settings or saved games. Additional async load/save failure and rapid-change ordering tests would be useful when extending the settings architecture; the present tests do not qualify those paths.
