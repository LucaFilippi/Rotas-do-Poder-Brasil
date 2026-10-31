"""Ferramenta de desenvolvimento; jogo instalado funciona offline."""
import io
import json
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def download(url):
    print(f"Obtendo {url}", flush=True)
    with urllib.request.urlopen(url, timeout=180) as response:
        return response.read()


def main():
    engine = ROOT / '.tools/godot'
    engine.mkdir(parents=True, exist_ok=True)
    if not list(engine.glob('*.exe')):
        archive = download('https://github.com/godotengine/godot/releases/download/4.5.1-stable/Godot_v4.5.1-stable_win64.exe.zip')
        zipfile.ZipFile(io.BytesIO(archive)).extractall(engine)
    if not (ROOT / 'addons/godot-sqlite/gdsqlite.gdextension').exists():
        archive = download('https://github.com/2shady4u/godot-sqlite/releases/download/v4.6/demo.zip')
        bundle = zipfile.ZipFile(io.BytesIO(archive))
        for name in bundle.namelist():
            if 'addons/godot-sqlite/' in name and not name.endswith('/') and ('/bin/' not in name or '.windows.' in name or '.linux.' in name):
                target = ROOT / name[name.index('addons/godot-sqlite/'):]
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(bundle.read(name))
        config = ROOT / 'addons/godot-sqlite/gdsqlite.gdextension'
        lines = config.read_text().splitlines()
        config.write_text('\n'.join(line for line in lines if not line.startswith(('macos.', 'android.', 'ios.', 'web.', '    '))), encoding='utf-8')
    print('Dependências prontas.')


if __name__ == '__main__':
    main()
