from pathlib import Path
import unittest

from generate_maia3_reference import CASES


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
        self.assertIn('--flavor preview', wrapper)
        self.assertIn('app-preview-release.apk', wrapper)
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
        runner = (REPO / 'tool/run_android_dev.sh').read_text()
        pubspec = (REPO / 'pubspec.yaml').read_text()

        self.assertIn('mobileMaiaDevelopment', gradle)
        self.assertIn('mobileMaiaArm64Only', gradle)
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
        self.assertIn('--flavor dev', snapshot)
        self.assertNotIn('--split-per-abi', snapshot)
        self.assertIn('--target-platform android-arm64', snapshot)
        self.assertIn('mobileMaiaArm64Only=true', snapshot)
        self.assertIn('app-dev-release.apk', snapshot)
        self.assertIn('--android-project-arg=mobileMaiaDevelopment=true', snapshot)
        self.assertNotIn('flutter clean', snapshot)
        self.assertNotIn('prepare_reproducible_flutter_sdk.py', snapshot)
        self.assertNotIn('prepare_reproducible_stockfish.py', snapshot)
        self.assertIn('assets/models/maia3-5m.onnx', pubspec)
        self.assertIn('assets/models/maia3-79m.onnx', pubspec)
        self.assertIn('default-flavor: dev', pubspec)
        self.assertIn('exec "$flutter_bin" run', runner)
        self.assertIn('--flavor dev', runner)
        self.assertIn('--target-platform android-arm64', runner)

    def test_sound_effect_compiles_against_its_dependency_api_level(self):
        gradle = (REPO / 'android/build.gradle.kts').read_text()

        self.assertIn('name == "sound_effect"', gradle)
        self.assertIn('compileSdk = 36', gradle)

    def test_maia3_reference_gate_is_test_only_and_pinned(self):
        fixture = (REPO / 'integration_test/fixtures/maia3_reference.dart').read_text()
        integration = (REPO / 'integration_test/review_android_test.dart').read_text()
        pubspec = (REPO / 'pubspec.yaml').read_text()

        self.assertIn('1e13597c42d4858b7cfd7cfdae01e297263364b2', fixture)
        self.assertIn('3fc6181d5db789b45a15305732148757ae74efa3e0028e81ba335b462dac45c2', fixture)
        self.assertIn('3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010', fixture)
        for case in ('initial-1500', 'after-e4-black-1600-vs-2100',
                     'ruy-lopez-middlegame-1800', 'black-promotion-1200'):
            self.assertIn(case, fixture)
        self.assertIn("import 'fixtures/maia3_reference.dart';", integration)
        self.assertIn('MaiaEncoding.historicalTokens([reference.fen])', integration)
        self.assertIn('MaiaInferenceQueue.predict', integration)
        self.assertIn('closeTo(expected.value, 0.002)', integration)
        self.assertNotIn('integration_test/fixtures', pubspec)
        self.assertIn("appFlavor == 'dev'", integration)
        self.assertIn("expect(appFlavor, anyOf('dev', 'preview'))", integration)
        self.assertIn('maia3ReferenceCases.take(1)', integration)
        self.assertIn('if (useDevModel) continue;', integration)

    def test_reference_cases_preserve_distinct_rating_inputs(self):
        fixture = (REPO / 'integration_test/fixtures/maia3_reference.dart').read_text()
        self.assertTrue(any(self_elo != opponent_elo
                            for _, _, self_elo, opponent_elo in CASES))
        for name, fen, self_elo, opponent_elo in CASES:
            with self.subTest(case=name):
                marker = f"name: '{name}',"
                self.assertIn(marker, fixture)
                fields = fixture.split(marker, 1)[1].split('legalMoveLogits:', 1)[0]
                self.assertIn(f"fen: '{fen}',", fields)
                self.assertIn(f'selfElo: {self_elo},', fields)
                self.assertIn(f'opponentElo: {opponent_elo},', fields)


if __name__ == '__main__':
    unittest.main()
