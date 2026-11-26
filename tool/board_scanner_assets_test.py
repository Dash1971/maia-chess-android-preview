"""Pinned scanner payload and Android permission/scope contracts (no APK build)."""
import hashlib
from pathlib import Path
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
ANDROID = '{http://schemas.android.com/apk/res/android}'
PINS = {
    'boardfinder-v1-int8.onnx': (1428260, '92df98ca72bf8c9c67196a134188b3cc005681d35262724172ba61f705625f4f'),
    'boardnet-v4-int8.onnx': (2030978, 'bf07e26ed1f7cd27ee5b75049b5c8fd261b157de89b026e968e779355c16ef80'),
}


class BoardScannerAssetsTest(unittest.TestCase):
    def test_bundled_bytes_match_release_pins_and_runtime_checks(self):
        source = (ROOT / 'android/app/src/main/kotlin/com/dash1971/maia_chess/BoardScanImages.kt').read_text()
        for name, (size, digest) in PINS.items():
            data = (ROOT / 'assets/board_scanner' / name).read_bytes()
            self.assertEqual(len(data), size, name)
            self.assertEqual(hashlib.sha256(data).hexdigest(), digest, name)
            self.assertIn(digest, source)
            self.assertIn(str(size), source)
        self.assertIn('assets/board_scanner/', (ROOT / 'pubspec.yaml').read_text())
        self.assertIn('AGPL-3.0-only', (ROOT / 'assets/board_scanner/MODEL-LICENSE.md').read_text())
        self.assertIn('training', (ROOT / 'assets/board_scanner/MODEL-LICENSE.md').read_text())

    def test_scanner_adds_no_broad_camera_media_or_network_permission(self):
        manifest = ET.parse(ROOT / 'android/app/src/main/AndroidManifest.xml').getroot()
        permissions = {p.get(ANDROID + 'name') for p in manifest.findall('uses-permission')}
        for permission in ['CAMERA', 'READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE',
                           'READ_MEDIA_IMAGES', 'ACCESS_MEDIA_LOCATION', 'INTERNET']:
            self.assertNotIn('android.permission.' + permission, permissions)
        provider = manifest.find("./application/provider[@" + ANDROID + "name='androidx.core.content.FileProvider']")
        self.assertEqual(provider.get(ANDROID + 'exported'), 'false')
        self.assertEqual(provider.get(ANDROID + 'grantUriPermissions'), 'true')
        paths = ET.parse(ROOT / 'android/app/src/main/res/xml/file_paths.xml').getroot()
        scoped = [p for p in paths if p.get('name') == 'board-scan']
        self.assertEqual(len(scoped), 1)
        self.assertEqual(scoped[0].tag, 'cache-path')
        self.assertEqual(scoped[0].get('path'), 'board-scan/')


if __name__ == '__main__':
    unittest.main()
