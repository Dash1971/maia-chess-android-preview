from pathlib import Path
import unittest


REPO = Path(__file__).resolve().parents[1]


class PreviewBuildContractTest(unittest.TestCase):
    def test_release_is_universal_r8_minified_and_jni_safe(self):
        gradle = (REPO / 'android/app/build.gradle.kts').read_text()
        rules = (REPO / 'android/app/proguard-rules.pro').read_text()
        wrapper = (REPO / 'tool/build_android_release.sh').read_text()

        self.assertIn('isMinifyEnabled = true', gradle)
        self.assertIn('isShrinkResources = false', gradle)
        self.assertIn('-keep class ai.onnxruntime.**', rules)
        self.assertNotIn('--split-per-abi', wrapper)
        self.assertNotIn('--target-platform', wrapper)
        self.assertIn('prepare_reproducible_flutter_sdk.py', wrapper)
        self.assertIn('prepare_reproducible_stockfish.py', wrapper)
        self.assertIn('build apk --release --config-only', wrapper)
        self.assertIn('build apk --release --no-pub', wrapper)

    def test_ci_verifies_the_stable_universal_abi_set(self):
        workflow = (REPO / '.github/workflows/checks.yml').read_text()
        self.assertIn('app-release.apk', workflow)
        for abi in ('armeabi-v7a', 'arm64-v8a', 'x86_64'):
            self.assertIn('--allow-abi ' + abi, workflow)
        self.assertNotIn('app-arm64-v8a-release.apk', workflow)


if __name__ == '__main__':
    unittest.main()
