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

    def test_universal_build_remains_upgrade_compatible_with_split_beta20(self):
        version = next(line for line in (REPO / 'pubspec.yaml').read_text().splitlines()
                       if line.startswith('version: '))
        build_number = int(version.rsplit('+', 1)[1])
        self.assertGreaterEqual(build_number, 2075)

    def test_fast_iteration_uses_a_separate_development_identity(self):
        gradle = (REPO / 'android/app/build.gradle.kts').read_text()
        manifest = (REPO / 'android/app/src/main/AndroidManifest.xml').read_text()
        snapshot = (REPO / 'tool/build_android_snapshot.sh').read_text()

        self.assertIn('mobileMaiaDevelopment', gradle)
        self.assertIn('applicationIdSuffix = ".dev"', gradle)
        self.assertIn('Mobile Maia Preview Dev', gradle)
        self.assertIn('@mipmap/ic_launcher_dev', gradle)
        self.assertIn('signingConfigs.getByName("debug")', gradle)
        self.assertIn('android:label="${appLabel}"', manifest)
        self.assertIn('android:icon="${appIcon}"', manifest)
        self.assertIn('android:roundIcon="${appRoundIcon}"', manifest)
        dev_icon = (REPO / 'android/app/src/main/res/drawable/'
                    'ic_launcher_dev_foreground.xml').read_text()
        self.assertIn('#FF3B30', dev_icon)
        self.assertIn('#C62828', dev_icon)
        self.assertIn('build apk --release --config-only', snapshot)
        self.assertIn('--split-per-abi', snapshot)
        self.assertIn('--target-platform android-arm64', snapshot)
        self.assertIn('--android-project-arg=mobileMaiaDevelopment=true', snapshot)
        self.assertNotIn('flutter clean', snapshot)
        self.assertNotIn('prepare_reproducible_flutter_sdk.py', snapshot)
        self.assertNotIn('prepare_reproducible_stockfish.py', snapshot)


if __name__ == '__main__':
    unittest.main()
