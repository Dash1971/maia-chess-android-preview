# Preview 2.6.0-beta.1 qualification and cleanup

Published 2026-11-13: [release](https://github.com/Dash1971/maia-chess-android-preview/releases/tag/v2.6.0-beta.1), version code 2601.
Reviewed and merged #209, #210, #213 and #217 through release #218.
Qualified source: `52378bbc0d038def0678895e4e9e2b3a2d83a08a`. The release tag preserves that exact source;
subsequent documentation does not rebuild or replace the APK.

## Delivered and remaining acceptance

Offline screenshot/flat-diagram import and external-camera capture return to the
existing editable Board Editor. Human move timing defaults on, preserving saved
off choices across upgrade. Analysis engines off hides Maia score values.
Grand Kingdom is explicitly experimental in Preview at the requester's direction.
Wrong-piece removal at `19...Bxf8` and missed capture removal at `7...Nxb4` remain
unresolved. Assisted Maia promotion is not a capture fix. Real hardware capture,
promotion, en passant and interruption/recovery acceptance remain pending.
DGT stays Dev-only; Stable/unflavored builds exclude both experimental adapters.

Image recognition is editable assistance, with known arrow/font/style failures.
Broader accuracy, real-phone/OEM camera and lower-end performance acceptance are
pending. Emulator camera checks verify the pipeline using its synthetic scene,
not photo recognition accuracy or 3D-board support. Stable promotion remains
separate; Stable 2.5.1 and Dev 2.6.0-alpha.2-dev were not changed or republished.

## Verification

- [Exact-source CI](https://github.com/Dash1971/maia-chess-android-preview/actions/runs/43364050490): 1392 passed, four expected skips; Android build passed.
- Independent Linux rebuild byte-identical to GitHub's unsigned APK.
- Established Preview signer, payload/model/licence verification and byte-identical signature reconstruction passed.
- Full ARM64 API36 Preview native suite: 16 tests with the real 79M model, plus three native feature tests.
- 170 local Preview channel checks; Stable/unflavored exclusions passed separately. Focused timing/promotion: 54; Grand Kingdom promotion: 27.
- Chess oracle: 3,000 positions and 512 variation trees across four round trips.
- Actual production-signed beta.11 upgrade preserved UID, games, captures and preferences, including a saved timing-off choice. Timing default/reset/opt-out/restart and EN/JA score/continuation checks passed.
- Three additional temporary-test-key saved-game fixtures passed active/archive restoration, upgrade and restart with preserved PGN/clocks/positions.
- Fresh offline production-signed APK: system photo picker, crop/orientation, real pinned model, existing editor, camera capture/cancel/unavailable fallback and private JPEG cleanup passed.
- Public download independently checked against qualified hashes, signer, package, models and payloads. Attached `public-download-verification.json` records the receipt.

Two source test fixtures explicitly disabled human timing for deterministic motor
scripts after the new default. A task-local upgrade driver excluded the Home
screen from completed-game detection and awaited normal-background completion
before force-stop. No restore safeguard was removed; application source remained
frozen during signed checks. The failed driver's compact diagnostics are retained.

Unsigned SHA-256: `fc602df1805757dda96cffd1bfe6619ff50321a974b4578c28e822eb8983b8a6`.
Signed APK SHA-256: `d036bb4b338d8a08fae568db8416acde371b4c4e02431010e4b11d472c729da7`.
Signer SHA-256: `cd6c07c4efacf52bcccb83009b522c1dcad4a171197505a486f0a58edb6f172e`.
79M model SHA-256: `3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010`.
Diagram model SHA-256: `2408717e2e0e2ed438e2f9f89f85c2e544326cef34a0c91b95168bd17336df47`.
Signed APK: 456,772,948 bytes; change from beta.11: +1,302,828 bytes.

Fresh upstream review on 13 November included 63 exact OSV queries (no findings)
and 19 available Pub updates with recorded deferrals. Gradle upgraded to 9.9.1
for three 10 November advisories. Shared tooling/pins match the linked
[Stable companion #73](https://github.com/Dash1971/maia-chess-android/pull/73),
which remains open/unmerged with passing CI. No Stable release is authorized.

## Cleanup

After checking the published download and receipt, checked cleanup ran on the
Mac test host, independent Linux build host and signing host before this
documentation pass. It stopped the task emulator, idle task Gradle daemon and
exited build container; removed task bulk, APK/archive copies, virtual environment,
emulator data and task source/model materializations. Shared tools/caches, keys,
Git history/tags and unrelated active checkouts were preserved.
The separately authorized old stopped diagnostic container was removed after
retaining metadata/logs; Linux root free space increased from 13.4 to 24.2 GiB.
Compact hashes, reports, diagnostics and verification bundle remain as evidence.

Cleanup reports (bytes and paths as recorded by the checked command):

```json
{
  "mac": {
    "checkout": "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review",
    "source_commit": "52378bbc0d038def0678895e4e9e2b3a2d83a08a",
    "mode": "apply",
    "targets": [
      "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review/build",
      "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review/.dart_tool",
      "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review/.flutter-plugins-dependencies",
      "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review/android/.gradle",
      "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review-results/bulk"
    ],
    "reason": "published",
    "evidence": "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review-results/evidence/public-download-verification.json",
    "evidence_sha256": "539f4cd3e800381d91f23b8f1b851ce360196c01fa41342164a6451f0ea0828f",
    "free_bytes_before": 50894401536,
    "removed": [
      "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review/build",
      "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review/.dart_tool",
      "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review/.flutter-plugins-dependencies",
      "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review/android/.gradle",
      "/Users/da/Documents/ChatGPT/Mobile Maia/preview-26-review-results/bulk"
    ],
    "free_bytes_after": 61952352256
  },
  "linux": {
    "checkout": "/srv/container-ssd/tmp/codex-preview26-beta1/source",
    "source_commit": "52378bbc0d038def0678895e4e9e2b3a2d83a08a",
    "mode": "apply",
    "targets": [
      "/srv/container-ssd/tmp/codex-preview26-beta1/source/build",
      "/srv/container-ssd/tmp/codex-preview26-beta1/source/.dart_tool",
      "/srv/container-ssd/tmp/codex-preview26-beta1/source/.flutter-plugins-dependencies",
      "/srv/container-ssd/tmp/codex-preview26-beta1/source/android/.gradle",
      "/srv/container-ssd/tmp/codex-preview26-beta1/bulk"
    ],
    "reason": "published",
    "evidence": "/srv/container-ssd/tmp/codex-preview26-beta1/evidence/public-verification.json",
    "evidence_sha256": "539f4cd3e800381d91f23b8f1b851ce360196c01fa41342164a6451f0ea0828f",
    "free_bytes_before": 22603403264,
    "removed": [
      "/srv/container-ssd/tmp/codex-preview26-beta1/source/build",
      "/srv/container-ssd/tmp/codex-preview26-beta1/source/.dart_tool",
      "/srv/container-ssd/tmp/codex-preview26-beta1/source/.flutter-plugins-dependencies",
      "/srv/container-ssd/tmp/codex-preview26-beta1/source/android/.gradle",
      "/srv/container-ssd/tmp/codex-preview26-beta1/bulk"
    ],
    "free_bytes_after": 27332501504
  },
  "signing": {
    "checkout": "/Users/openclaw/.cache/codex-maia-preview26-beta1/source",
    "source_commit": "52378bbc0d038def0678895e4e9e2b3a2d83a08a",
    "mode": "apply",
    "targets": [
      "/Users/openclaw/.cache/codex-maia-preview26-beta1/bulk"
    ],
    "reason": "published",
    "evidence": "/Users/openclaw/.cache/codex-maia-preview26-beta1/evidence/public-verification.json",
    "evidence_sha256": "539f4cd3e800381d91f23b8f1b851ce360196c01fa41342164a6451f0ea0828f",
    "free_bytes_before": 38007873536,
    "removed": [
      "/Users/openclaw/.cache/codex-maia-preview26-beta1/bulk"
    ],
    "free_bytes_after": 38951452672
  }
}
```
