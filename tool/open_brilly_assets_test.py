"""Pinned Open Brilly Finder artifact and packaging contract; no downloads."""
import hashlib
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
MODEL = 'assets/classifiers/mute-exchange-model.json'
MODEL_SHA = '992a792a646b11e612486c4fe26796fc38ee47f395f2220b00d26db65ba1e27d'
PARITY = 'test/fixtures/brilly-exchange-parity.json'
PARITY_SHA = '4c049a91c96043de607e221149cbf2e4c7a7db293f6a6558e37a1a5719f3cbd6'


class OpenBrillyAssetsTest(unittest.TestCase):
    def test_pinned_model_and_feature_order(self):
        raw = (ROOT / MODEL).read_bytes()
        self.assertEqual(len(raw), 480186)
        self.assertEqual(hashlib.sha256(raw).hexdigest(), MODEL_SHA)
        model = json.loads(raw)
        self.assertEqual(len(model['trees']), 222)
        self.assertEqual(len(model['features']), 91)
        self.assertEqual(len(set(model['features'])), 91)
        self.assertEqual(model['cutoff'], 0.8193002847777424)
        fixtures = json.loads((ROOT / PARITY).read_bytes())
        self.assertEqual(model['features'], fixtures['model_features'])
        runtime = (ROOT / 'lib/src/review_widgets.dart').read_text()
        self.assertIn(MODEL_SHA, runtime)
        self.assertIn(MODEL, runtime)

    def test_exact_upstream_regressions_and_constructed_boundaries(self):
        raw = (ROOT / PARITY).read_bytes()
        self.assertEqual(len(raw), 957547)
        self.assertEqual(hashlib.sha256(raw).hexdigest(), PARITY_SHA)
        self.assertEqual(len(json.loads(raw)['cases']), 360)
        edges = json.loads((ROOT / 'test/fixtures/brilly-exchange-edges.json').read_bytes())
        self.assertEqual(len(edges['cases']), 17)
        self.assertIn('synthetic', edges['scope'])

    def test_only_required_model_is_registered_as_asset(self):
        pubspec = (ROOT / 'pubspec.yaml').read_text()
        self.assertEqual(pubspec.count(f'- {MODEL}'), 1)
        self.assertNotIn('test/fixtures/', pubspec)
        self.assertNotIn('brilly-exchange-parity', pubspec)
        self.assertNotIn('node_modules', pubspec)
        self.assertNotIn('- assets/classifiers/\n', pubspec)
        notices = (ROOT / 'THIRD_PARTY_NOTICES.md').read_text()
        provenance = (ROOT / 'MODEL_PROVENANCE.md').read_text()
        self.assertIn('AGPL-3.0-only', notices)
        self.assertIn(PARITY_SHA, notices)
        self.assertIn(MODEL_SHA, provenance)
        self.assertIn('59cab58a8b63387d9775252f03a6875fe451f697', notices)
        self.assertIn('Open Brilly Finder', (ROOT / 'lib/src/play.dart').read_text())


if __name__ == '__main__':
    unittest.main()
