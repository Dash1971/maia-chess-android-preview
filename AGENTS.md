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

For platform settings without a suitable Lichess equivalent, consult official
localized Google/Android documentation. For AI sampling vocabulary such as
Temperature and Top-P, consult official localized AI documentation and primary
research. Check that the requested language actually loaded. Follow
`docs/TRANSLATION_QUALITY_REVIEW.md` for source precedence, documented platform
context exceptions, and Maia-specific behavior. Never reuse a language-setting
message for a theme setting just because their English labels match.

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

Read `docs/BUILD_WORKSPACE.md` before building or qualifying a release. Use
GitHub Linux for the canonical build and the configured Mac mini Linux machine
for independent builds and suitable native checks. Do not start a Mac build,
download another SDK/NDK or create a Mac emulator merely because the chat is
running on the Mac. If a required check needs macOS, explain why and obtain
explicit user authorization first. Never skip required qualification checks.
The build wrappers enforce the Mac opt-in and a minimum free-space check.

Keep bulk output in one task-owned scratch directory, outside the source
checkout, created with `tool/build_workspace.py init`. Keep compact evidence
separate. Reuse configured shared SDK/JDK/Flutter/Gradle/pub caches; do not
clone toolchains or caches per release. Record the host, checkout, scratch,
container and emulator ownership, disk budget and cleanup command before work.
Check free space before large downloads and emulator creation as well as builds;
reserve at least 10 GiB beyond expected growth and stop before that reserve is
consumed. A Mac exception requires at least 25 GiB free at build start.

Cleanup is part of release completion: immediately after verifying the actual
published download and saving compact evidence, stop task-owned processes and
run the documented cleanup command on every build/signing/test host. Do not
defer bulk cleanup until a documentation PR merges. On failure or cancellation,
retain diagnostics and clean abandoned bulk output before handoff; active work
must have an explicit retention reason, owner and expiry. Never delete another
chat's current build. Include before/after disk space, removed paths and any
retained output with its reason/expiry in the release PR. Do not report a release
task complete until cleanup is recorded or a concrete blocker is reported.

After a verified publication, delete merged PR branches and temporary release-build
branches once their source is preserved by a release tag and they have no unique
unmerged commits. Do not delete active work, release tags or releases. Keep
automatic deletion of merged branches enabled.

Remove only task-owned build containers/checkouts, downloaded or reconstructed
APKs, test virtual environments and emulator test data after retaining compact
verification evidence and checking the published download. Stop task-owned
emulators. Preserve shared SDK/Gradle caches, signing keys and other people's
work. Record cleanup in the release PR, including anything intentionally retained.
