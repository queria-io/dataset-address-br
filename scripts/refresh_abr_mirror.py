"""位置参照・住居表示のマスタの写しを作り、assets.queria.io に置く。日本から流す。

ABR の配信元は国外からの取得を 403 で拒むので、CI（米国のランナー）は main.py が
この写しから取る。配信元の zip（5 種 × 47 都道府県）をそのまま取り、sha256 を書いた
目録と一緒に R2 のバケット queria-assets の abr/address-br-<YYYYMMDD>/ に置く。
同じキーには上書きしない（CDN が古い中身を返し続けるため）。目録を最後に置くので、
途中で止まった版は目録が無く、CI は使わずに配信元へ取りに行く。

使い方:
  uv run python scripts/refresh_abr_mirror.py            # 取って目録を作るまで
  uv run python scripts/refresh_abr_mirror.py --upload   # R2 に置くまで
  uv run python scripts/refresh_abr_mirror.py --upload --date 2026-10-26   # 前の日に取った分を置く
置いたあと、main.py の ABR_MIRROR_DATE を表示された日付に書き換えて PR にする。
"""

import argparse
import json
import os
import subprocess
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from main import ABR_BASE_URL, PREF_CODES, PREF_DATASETS, USER_AGENT, _sha256, pref_zip_key  # noqa: E402
from shared.fetch import download  # noqa: E402

BUCKET = "queria-assets"
# FLOPS のアカウント。cf はアカウントを 2 つ持つ環境で非対話だと止まるので明示する
CLOUDFLARE_ACCOUNT_ID = "57c6a116efc637fc3f21d0affea15508"


def put(key: str, path: Path, content_type: str) -> None:
    subprocess.run(
        ["cf", "r2", "objects", "put", key, "--bucket-name", BUCKET, "--file", str(path), "--content-type", content_type],
        check=True,
        env={**os.environ, "CLOUDFLARE_ACCOUNT_ID": CLOUDFLARE_ACCOUNT_ID},
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upload", action="store_true", help="R2 に置く")
    parser.add_argument("--out", type=Path, default=ROOT / "data/abr-mirror")
    # 取った日と置く日が違うとき、取った日の作業場所を使い直す（既定は今日）
    parser.add_argument("--date", type=date.fromisoformat, default=date.today(), help="写しの日付 (YYYY-MM-DD)")
    args = parser.parse_args()

    name = f"address-br-{args.date:%Y%m%d}"
    out_dir = args.out / name
    keys = [pref_zip_key(dataset, pref) for dataset in PREF_DATASETS for pref in PREF_CODES]

    files = {}
    for key in keys:
        path = out_dir / key
        if not path.exists():
            path.parent.mkdir(parents=True, exist_ok=True)
            print(f"downloading {key}")
            download(f"{ABR_BASE_URL}/{key}", path, user_agent=USER_AGENT)
        files[key] = {"bytes": path.stat().st_size, "sha256": _sha256(path)}

    manifest_path = out_dir / "manifest.json"
    manifest = {"source": ABR_BASE_URL, "created": f"{args.date:%Y-%m-%d}", "files": files}
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    total = sum(f["bytes"] for f in files.values())
    print(f"{len(files)} files, {total / 1e6:.0f} MB -> {out_dir}")

    if args.upload:
        for key in keys:
            put(f"abr/{name}/{key}", out_dir / key, "application/zip")
        put(f"abr/{name}/manifest.json", manifest_path, "application/json")
        print(f"uploaded. set ABR_MIRROR_DATE = \"{name.removeprefix('address-br-')}\" in main.py")


if __name__ == "__main__":
    main()
