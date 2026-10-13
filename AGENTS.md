# Mobile Maia development

Mobile Maia follows Lichess as its baseline for clear, uncluttered chess UI/UX
and free/open-source design philosophy. Shared terminology is part of that
approach; Maia-specific capabilities retain their own meaning.


Lichess is authoritative in **every supported language** where the chess concept
or UI action has a direct equivalent. Read `docs/LICHESS_TERMINOLOGY.md` and use
the pinned reference in `docs/lichess-terminology.json`. Preserve app-specific
meaning and document context adaptations; do not blindly copy Lichess branding
or change Mobile Maia's classification algorithms to match a translated label.
Update related help/accessibility text as well as the visible label. Run
`python3 tool/check_lichess_terminology.py`, the existing localization checks,
and the localization widget tests after editing catalogs. New equivalent terms
need a reference entry; unsupported upstream translations need a reasoned
native-language fallback, not English.

## Research publication

Publish research reports, datasets and reproduction tools in the separate
[Mobile Maia research repository](https://github.com/Dash1971/mobile-maia-research).
Keep only brief decision summaries and links in app documentation. Do not add
research bundles or datasets to application source or release distributions.

## Distribution channels

Read `docs/BUILD_CHANNELS.md` before promoting or publishing a build. Update
its channel status and the release PR's evidence when publishing. Grand Kingdom
and DGT adapters remain Dev-only: preserve both Dart and native flavor gates
and the Preview restriction tests. Stable releases use the Stable repository's
authoritative release procedure, including its Zapstore and F-Droid follow-up.
Preview/Dev publication does not authorize a Stable or app-store release.

## Release and workspace cleanup

After a verified publication, delete merged PR branches and temporary release-build
branches once their source is preserved by a release tag and they have no unique
unmerged commits. Do not delete active work, release tags or releases. Keep
automatic deletion of merged branches enabled.

Remove only task-owned build containers/checkouts, downloaded or reconstructed
APKs, test virtual environments and emulator test data after retaining compact
verification evidence and checking the published download. Stop task-owned
emulators. Preserve shared SDK/Gradle caches, signing keys and other people's
work. Record cleanup in the release PR, including anything intentionally retained.
