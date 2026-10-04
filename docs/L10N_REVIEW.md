# Dev language review

This is a **provisional** UI translation of the same 119-message first slice into Japanese, Simplified Chinese for mainland China, Korean, and Spanish. Native-speaker review has not yet happened. Screens outside this slice still show English.

Review `l10n_review.csv` alongside the Dev app. Each row has a stable message ID, English source, proposed translations, and source location. For a correction, fill in **Reviewer suggestion** and identify the language; a screenshot link and a short explanation are especially useful when wording depends on chess context or available space. Leave the English source and ID unchanged. Report missing English text, clipping, unclear chess terms, or wrong context even if the proposed translation itself is grammatical.

The app's source of truth is `lib/l10n/app_en.arb`, `app_ja.arb`, `app_zh.arb`, `app_ko.arb`, and `app_es.arb`. The CSV is a review aid, not a second translation source. Approved suggestions should be applied to the ARB files and checked in the Dev app before the language is described as complete.

Keep PGN, FEN, move notation, model names, and engine protocol data untranslated. Do not put reviewer identities or private phone screenshots into this public repository without permission.
