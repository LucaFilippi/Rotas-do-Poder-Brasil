"""Executa testes reais de Python/Godot e falha também em erros de script no log."""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def run(args, env):
    result = subprocess.run(args, cwd=ROOT, env=env, capture_output=True, text=True, encoding='utf-8', errors='replace', timeout=180)
    print(result.stdout, end='')
    print(result.stderr, end='', file=sys.stderr)
    if result.returncode or any(marker in result.stdout + result.stderr for marker in ['SCRIPT ERROR:', 'ERROR:', 'FALHOU:']):
        raise SystemExit(result.returncode or 1)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--godot', required=True)
    args = parser.parse_args()
    engine = str(Path(args.godot).resolve())
    with tempfile.TemporaryDirectory(prefix='rotas-tests-') as temp:
        env = os.environ.copy()
        env['APPDATA'] = temp
        env['XDG_DATA_HOME'] = temp
        env['XDG_CONFIG_HOME'] = temp
        run([sys.executable, '-m', 'unittest', 'discover', '-s', 'tests', '-p', 'test_*.py', '-v'], env)
        run([engine, '--headless', '--editor', '--path', str(ROOT), '--quit'], env)
        run([engine, '--headless', '--path', str(ROOT), '--script', 'tests/run_tests.gd'], env)


if __name__ == '__main__':
    main()
