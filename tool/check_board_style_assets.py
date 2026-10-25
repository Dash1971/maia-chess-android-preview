#!/usr/bin/env python3
"""Verify this Preview feature's exact offline artwork allowlist and optional APK."""
import argparse
import hashlib
import json
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def check(apk=None):
    manifest = json.loads((ROOT / 'docs/board-style-assets.json').read_text())
    package = ROOT / 'third_party/chessground'
    expected = {}
    for entry in manifest['files']:
        path = entry['path']
        data = (package / path).read_bytes()
        assert hashlib.sha256(data).hexdigest() == entry['sha256'], path
        assert hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest() == entry['upstream_git_blob'], path
        if path.startswith('assets/'):
            expected[path] = entry['sha256']
    actual = {p.relative_to(package).as_posix() for p in (package / 'assets').rglob('*') if p.is_file()}
    assert actual == set(expected), ('asset allowlist mismatch', actual ^ set(expected))
    included = {p.name for p in (package / 'assets/piece_sets').iterdir()}
    assert included == set(manifest['approved_piece_sets']), included
    pubspec = (package / 'pubspec.yaml').read_text()
    for name in included:
        assert '    - assets/piece_sets/' + name + '/' in pubspec, name
    for name in manifest['excluded_piece_sets']:
        assert 'assets/piece_sets/' + name + '/' not in pubspec, name
    for file, digest in manifest['notice_files'].items():
        assert hashlib.sha256((package / 'notices' / file).read_bytes()).hexdigest() == digest, file
    report = {'asset_files': len(expected), 'approved_piece_sets': len(included),
              'excluded_piece_sets': len(manifest['excluded_piece_sets']),
              'source_asset_bytes': sum((package / path).stat().st_size for path in expected)}
    if apk:
        prefix = 'assets/flutter_assets/packages/chessground/'
        with zipfile.ZipFile(apk) as archive:
            entries = {p.filename[len(prefix):]: p for p in archive.infolist() if p.filename.startswith(prefix) and not p.is_dir()}
            assert set(entries) == set(expected), ('APK assets differ from allowlist', set(entries) ^ set(expected))
            for path, entry in entries.items():
                assert hashlib.sha256(archive.read(entry)).hexdigest() == expected[path], path
            report.update(apk_bytes=Path(apk).stat().st_size,
                          apk_asset_bytes=sum(p.file_size for p in entries.values()),
                          apk_compressed_asset_bytes=sum(p.compress_size for p in entries.values()),
                          apk_sha256=hashlib.sha256(Path(apk).read_bytes()).hexdigest())
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apk', type=Path)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    result = check(args.apk)
    text = json.dumps(result, indent=2) + '\n'
    if args.output:
        args.output.write_text(text)
    print(text, end='')
