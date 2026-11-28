# Privacy and Android permissions

Play, Maia/Stockfish analysis, opening names and saved games run on the device.
Release builds do not request Internet access. There are no accounts, ads,
analytics or automatic uploads. Choosing Share sends only the selected PGN,
sampling export or diagnostics through the app/service you choose; review it
before sharing. The browser edition has its own website privacy information.

## Permissions

| Android permission | Purpose |
| --- | --- |
| Bluetooth / Bluetooth admin, through Android 11 | Connect to an electronic chessboard. |
| Fine location, through Android 11 | Android's older BLE discovery requirement; the app does not use it to track location. |
| Nearby devices: Bluetooth scan/connect | Discover and connect on newer Android; scan is marked `neverForLocation`. |

Current source uses Android 7.0 / API 24 or newer: Gradle takes the minimum
from the reviewed Flutter SDK pinned in `.fvmrc`. Release qualification verifies
the actual APK manifest. Bluetooth hardware is optional for phone-only play.

## Local data and sharing

- Games and preferences stay in app-private storage. Android app backup is
  disabled. Export important games as PGN for transfer or safekeeping.
- [Sampling capture](docs/SAMPLING_DATA.md) is opt-in and local, with a bounded
  retention policy. Exports may contain your players, games and move choices.
- Copy/save diagnostics is an explicit user action. Review files before putting
  them in a public report. Automatic detailed tracing is a Dev-only feature.
- The [Preview 2.7 scanner draft](docs/BOARD_SCANNER_27.md) reads selected photos and camera images locally. It uses temporary private files and scoped URI grants, then deletes its copies after use. Images are not uploaded or added to diagnostics. Android supplies the camera and image picker; no camera or broad media/storage permission is added. This draft is not published; Preview beta.13 and Stable 2.6 do not include scanning.

The declared permissions are in
[`AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml); final APK
qualification also checks merged/transitive permissions.
