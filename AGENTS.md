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

Read `docs/RELEASING.md` and `docs/BUILD_CHANNELS.md` before promoting or
publishing a build. Update the channel status and the release PR's evidence when publishing. Grand Kingdom
and DGT adapters remain Dev-only: preserve both Dart and native flavor gates
and the Preview restriction tests. Stable releases use the Stable repository's
authoritative release procedure, including its Zapstore and F-Droid follow-up.
Preview/Dev publication does not authorize a Stable or app-store release.

Before every Preview release, the release agent must review upstream advisories
and available updates without waiting for a user reminder. Record dated sources
plus upgrade/deferral decisions. A passing
Gradle-pin/lockfile check is not that review. Prepare release notes, then complete
a post-publication README/roadmap pass where appropriate; Preview requires no
screenshot maintenance. Preserve full exact-source Preview qualification.

Dev releases use the lightweight procedure in `docs/RELEASING.md#dev`: relevant
checks, one ARM64/5M development-signed build and a changed-feature smoke test,
then publication to the separate Dev repository by default. Dev requires no
second matching build, full official-release qualification or published-download
check. Build-only requests remain build-only. Clean after the successful upload
and retained compact evidence; preserve Stable/Preview download checks.

## Shared build process

Read `docs/SHARED_BUILD_PROCESS.md` when changing build, CI, verification or
cleanup tooling. Assess the counterpart in Stable or Preview in the same task.
Port applicable improvements with a linked companion PR; document a concrete
reason for any intentional difference. Preserve channel-specific behavior and
Stable's authoritative release gates. Shared tooling changes do not authorize
an app promotion or publication.

## Release and workspace cleanup

Read `docs/BUILD_WORKSPACE.md` before building or qualifying a release. Preserve
the existing canonical Linux build and independent Linux reproduction process.
Mac builds and ARM64 emulator checks remain supported without an additional
authorization gate. Choose the host appropriate to the check and preserve all
required qualification checks. The build wrappers enforce a minimum free-space
check on both platforms.

Keep bulk output in one task-owned scratch directory, outside the source
checkout, created with `tool/build_workspace.py init`. Keep compact evidence
separate. Reuse configured shared SDK/JDK/Flutter/Gradle/pub caches; do not
clone toolchains or caches per release. Record the host, checkout, scratch,
container and emulator ownership, disk budget and cleanup command before work.
Check free space before large downloads and emulator creation as well as builds;
reserve at least 10 GiB beyond expected growth and stop before that reserve is
consumed. Mac builds require at least 25 GiB free at build start.

Cleanup is part of release completion: immediately after verifying the actual
published download (Preview), or confirming successful publication without a
download check (Dev), and saving compact evidence, stop task-owned processes and
run the documented cleanup command on every build/signing/test host. Do not
defer bulk cleanup until a documentation PR merges. On failure or cancellation,
retain diagnostics and clean abandoned bulk output before handoff; active work
must have an explicit retention reason, owner and expiry. Never delete another
chat's current build. Include before/after disk space, removed paths and any
retained output with its reason/expiry in the release PR. Do not report a release
task complete until cleanup is recorded or a concrete blocker is reported.

Do not archive full model binaries per release. Remove model copies in generated
output, APKs and scratch with that output. Preserve pinned Git LFS references
and model checksums. Materialized models in a completed task-owned checkout can
go when that checkout is safely retired; an active checkout or useful shared
LFS cache is not disposable bulk output. The generic cleanup command protects
tracked source assets rather than deleting them individually.

After a verified publication, delete merged PR branches and temporary release-build
branches once their source is preserved by a release tag and they have no unique
unmerged commits. Do not delete active work, release tags or releases. Keep
automatic deletion of merged branches enabled.

Remove only task-owned build containers/checkouts, downloaded or reconstructed
APKs, test virtual environments and emulator test data after retaining compact
verification evidence and checking the published download for Preview; Dev needs
only successful publication as described above. Stop task-owned
emulators. Preserve shared SDK/Gradle caches, signing keys and other people's
work. Record cleanup in the release PR, including anything intentionally retained.
