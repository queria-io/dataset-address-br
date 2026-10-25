"""アドレス・ベース・レジストリ マスタデータパイプライン。

1. data/ の zip ファイルを展開
2. 位置参照・住居表示のマスタを都道府県ごとにダウンロードして展開
3. dbt ビルド

データ更新手順:
  都道府県・市区町村・町字のマスタは、ABR サイト (https://dataset.address-br.digital.go.jp/)
  から最新の zip をダウンロードし、data/ に配置してコミットする。git 履歴でデータバージョンを追跡できる。
  位置参照・住居表示のマスタは件数が大きいので git に入れず、ビルドのたびに取る。
  配信元は国外からの取得を 403 で拒むので（GitHub Actions のランナーは米国）、日本で取った
  zip の写しを assets.queria.io に置いてそこから取る。写しが無いか合わないときは配信元から取る。
  写しの作り直しは scripts/refresh_abr_mirror.py を日本から流し、ABR_MIRROR_DATE を書き換える。
"""

import hashlib
import json
import logging
import shutil
import zipfile
from pathlib import Path

from dbt.cli.main import dbtRunner

from shared.fetch import download, fetch, replacing

logger = logging.getLogger("pipelines")

DATA_DIR = Path("data")
ABR_DIR = DATA_DIR / "abr"

ABR_BASE_URL = "https://data.address-br.digital.go.jp"
# 写しは日付ごとに別の場所に置き、同じ名前で上書きしない（CDN が古い中身を返し続けるため）
ABR_MIRROR_DATE = "20261026"
ABR_MIRROR_URL = f"https://assets.queria.io/abr/address-br-{ABR_MIRROR_DATE}"
USER_AGENT = "dataset-address-br (+https://github.com/queria-io/dataset-address-br)"

ZIPS = [
    "mt_pref_all",
    "mt_pref_pos_all",
    "mt_city_all",
    "mt_city_pos_all",
    "mt_town_all",
    "mt_town_fullset_all",
]

# 都道府県ごとに配信されるマスタ。data/abr/<名前>/<名前>_pref<NN>.csv に展開する
PREF_DATASETS = [
    "mt_town_pos",
    "mt_rsdtdsp_blk",
    "mt_rsdtdsp_blk_pos",
    "mt_rsdtdsp_rsdt",
    "mt_rsdtdsp_rsdt_pos",
]

PREF_CODES = [f"{code:02d}" for code in range(1, 48)]


def main():
    _extract_all()
    _download_pref_all()

    dbt = dbtRunner()

    result = dbt.invoke(["deps"])
    if not result.success:
        raise SystemExit("dbt deps failed")

    result = dbt.invoke(["run"])
    if not result.success:
        raise SystemExit("dbt run failed")

    result = dbt.invoke(["docs", "generate"])
    if not result.success:
        raise SystemExit("dbt docs generate failed")


def _extract_all() -> None:
    """data/ 内の zip ファイルを CSV に展開する。"""
    for filename in ZIPS:
        _extract(filename)


def _extract(filename: str) -> None:
    """zip を展開する。CSV が既に存在すればスキップ。"""
    csv_path = DATA_DIR / f"{filename}.csv"
    zip_path = DATA_DIR / f"{filename}.csv.zip"

    if csv_path.exists():
        logger.info(f"  skip (already exists: {csv_path})")
        return

    if not zip_path.exists():
        raise FileNotFoundError(f"{zip_path} not found. Download from ABR site.")

    logger.info(f"  extracting {zip_path.name}...")
    with zipfile.ZipFile(zip_path) as zf:
        zf.extract(f"{filename}.csv", DATA_DIR)


def pref_zip_key(dataset: str, pref_code: str) -> str:
    """配信元と写しで共通の、zip の置き場所（ABR_BASE_URL / ABR_MIRROR_URL からの相対）。"""
    return f"{dataset}/pref/{dataset}_pref{pref_code}.csv.zip"


def _load_mirror_manifest() -> dict[str, dict]:
    """写しの目録（キーごとの bytes と sha256）。取れなければ空で、すべて配信元から取る。"""
    try:
        body = fetch(f"{ABR_MIRROR_URL}/manifest.json", user_agent=USER_AGENT, not_found_ok=True)
    except Exception as error:
        logger.warning(f"  mirror manifest unavailable: {error}")
        return {}
    if body is None:
        logger.warning("  mirror manifest not found; downloading from the origin")
        return {}
    return json.loads(body)["files"]


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _download_pref_all() -> None:
    manifest = _load_mirror_manifest()
    for dataset in PREF_DATASETS:
        for pref_code in PREF_CODES:
            _download_pref(dataset, pref_code, manifest)


def _download_zip(key: str, zip_path: Path, manifest: dict[str, dict]) -> None:
    """写しから取り、目録の sha256 と合えば使う。目録に無い・取れない・合わないときは配信元から取る。"""
    entry = manifest.get(key)
    if entry:
        try:
            download(f"{ABR_MIRROR_URL}/{key}", zip_path, user_agent=USER_AGENT)
            if _sha256(zip_path) == entry["sha256"]:
                return
            logger.warning(f"  mirror checksum mismatch: {key}")
        except Exception as error:
            logger.warning(f"  mirror download failed: {key} ({error})")
    download(f"{ABR_BASE_URL}/{key}", zip_path, user_agent=USER_AGENT)


def _download_pref(dataset: str, pref_code: str, manifest: dict[str, dict]) -> None:
    """都道府県1つ分の zip を取って CSV を展開する。CSV が既に存在すればスキップ。"""
    filename = f"{dataset}_pref{pref_code}.csv"
    out_dir = ABR_DIR / dataset
    csv_path = out_dir / filename

    if csv_path.exists():
        logger.info(f"  skip (already exists: {csv_path})")
        return

    out_dir.mkdir(parents=True, exist_ok=True)
    zip_path = out_dir / f"{filename}.zip"
    logger.info(f"  downloading {zip_path.name}...")
    _download_zip(pref_zip_key(dataset, pref_code), zip_path, manifest)

    # 展開が途中で切れても、書きかけの CSV を取得済みとして残さない
    with zipfile.ZipFile(zip_path) as zf, zf.open(filename) as src, replacing(csv_path) as partial:
        with partial.open("wb") as dst:
            shutil.copyfileobj(src, dst)
    zip_path.unlink()


if __name__ == "__main__":
    main()
