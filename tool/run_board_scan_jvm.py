#!/usr/bin/env python3
"""Run the production scanner core on the JVM, without Gradle/Android or downloads.

Reuse a cached Kotlin 2.4.21 compiler, a Java executable and the official desktop
ONNX Runtime 1.24.3 JAR. Optional fixtures are Open Board Scanner's three generated
docs/integration images at dee0475dfc2cda96c0f6aa50e003536d53592ab1.
All generated output belongs in an existing checked task-owned scratch directory.
"""
import argparse
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--java', required=True, type=Path)
    parser.add_argument('--runtime', type=Path)
    parser.add_argument('--work-only', action='store_true',
                        help='Test preparation/inference failure handling without ONNX Runtime')
    parser.add_argument('--scratch', required=True, type=Path)
    parser.add_argument('--fixtures', type=Path)
    parser.add_argument('--gradle-cache', type=Path,
                        default=Path.home() / '.gradle/caches/modules-2/files-2.1')
    args = parser.parse_args()
    scratch = args.scratch.resolve()
    marker = json.loads((scratch / '.maia-release-scratch.json').read_text())
    if Path(marker['repo']).resolve() != ROOT or Path(marker['scratch']) != scratch:
        raise SystemExit('Scratch is not owned by this checkout')
    jars = []
    for artifact in ['kotlin-compiler-embeddable', 'kotlin-stdlib',
                     'kotlin-script-runtime', 'kotlin-reflect']:
        matches = list((args.gradle_cache / 'org.jetbrains.kotlin' / artifact / '2.4.21').glob('*/*.jar'))
        if len(matches) != 1:
            raise SystemExit('Expected one cached Kotlin 2.4.21 ' + artifact)
        jars.extend(matches)
    jars.extend((args.gradle_cache / 'org.jetbrains.kotlinx/kotlinx-coroutines-core-jvm/1.9.0').glob('*/*.jar'))
    jars.extend((args.gradle_cache / 'org.jetbrains/annotations/13.0').glob('*/*.jar'))
    stdlib = next(p for p in jars if p.name.startswith('kotlin-stdlib-'))
    if not args.work_only and args.runtime is None:
        parser.error('--runtime is required unless --work-only is used')
    runtime = os.pathsep.join(map(str, [stdlib] if args.work_only else [args.runtime.resolve(), stdlib]))
    compiler = [
        str(args.java), '-cp', os.pathsep.join(map(str, jars)),
        'org.jetbrains.kotlin.cli.jvm.K2JVMCompiler', '-no-stdlib', '-no-reflect',
    ]
    target = scratch / 'scanner-work-tests.jar'
    subprocess.run(compiler + [
        '-classpath', str(stdlib), '-d', str(target),
        str(ROOT / 'android/app/src/main/kotlin/com/dash1971/maia_chess/BoardScanWork.kt'),
        str(ROOT / 'android/app/src/main/kotlin/com/dash1971/maia_chess/BoardScanImages.kt'),
        str(ROOT / 'android/native_test/BoardScanWorkTest.kt'),
        *map(str, sorted((ROOT / 'android/native_test/board_scan_images').glob('*.kt'))),
    ], check=True)
    subprocess.run([str(args.java), '-cp', os.pathsep.join([str(target), runtime]),
                    'com.dash1971.maia_chess.BoardScanWorkTestKt'], check=True)
    subprocess.run([str(args.java), '-cp', os.pathsep.join([str(target), str(stdlib)]),
                    'com.dash1971.maia_chess.BoardScanImagesTestKt', str(scratch), str(ROOT)], check=True)
    if args.work_only:
        return
    target = scratch / 'scanner-tests.jar'
    subprocess.run(compiler + [
        '-classpath', runtime, '-d', str(target),
        str(ROOT / 'android/app/src/main/kotlin/com/dash1971/maia_chess/BoardScanCore.kt'),
        str(ROOT / 'android/native_test/BoardScanCoreTest.kt'),
    ], check=True)
    command = [str(args.java), '-cp', os.pathsep.join([str(target), runtime]),
               'com.dash1971.maia_chess.BoardScanCoreTestKt']
    if args.fixtures:
        command += [str(ROOT / 'assets/board_scanner'), str(args.fixtures.resolve())]
    subprocess.run(command, check=True)


if __name__ == '__main__':
    main()
