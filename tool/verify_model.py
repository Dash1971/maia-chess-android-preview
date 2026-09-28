#!/usr/bin/env python3
"""Verify the exact bundled model before packaging (Python standard library only)."""
import argparse
import hashlib
from pathlib import Path

MODEL_SIZE = 316_034_244
MODEL_SHA256 = '3454b03ae78baa64a87b345fdb1a457265d912caec531039b074f07eda0d8010'

MODELS = {
    'maia3-5m.onnx': (
        21_346_652,
        'ddae2aa893b5ca7ec94d24178871f1c337d09fd72ff38abe8d76b8ecf08cb942',
    ),
    'maia3-79m.onnx': (
        MODEL_SIZE,
        MODEL_SHA256,
    ),
}


def verify(path: Path) -> None:
    model_size, model_sha256 = MODELS.get(path.name, (MODEL_SIZE, MODEL_SHA256))
    if not path.is_file() or path.stat().st_size != model_size:
        raise ValueError(f'{path}: Maia model missing or wrong size. Run git lfs install && git lfs pull.')
    digest = hashlib.sha256()
    with path.open('rb') as model:
        for block in iter(lambda: model.read(1024 * 1024), b''):
            digest.update(block)
    if digest.hexdigest() != model_sha256:
        raise ValueError(f'{path}: Maia model SHA-256 mismatch. Restore the pinned Git LFS object.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('path', nargs='?', type=Path,
                        default=Path(__file__).resolve().parents[1] / 'assets/models/maia3-79m.onnx')
    path = parser.parse_args().path
    try:
        verify(path)
    except ValueError as error:
        parser.exit(1, f'{error}\n')
    size, sha256 = MODELS[path.name]
    print(f'Maia model verified: {size} bytes, SHA-256 {sha256}')
