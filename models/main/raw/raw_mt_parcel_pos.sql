{# デジタル庁 アドレス・ベース・レジストリ 地番マスタ位置参照拡張
   市区町村ごとに配信される CSV を、main.py が使う列だけの Parquet にして data/abr/mt_parcel_pos/ に置く。
   座標の付く筆が 1 つも無い市区町村は配信されない #}

{{ config(materialized='ephemeral') }}

select
    lg_code,
    machiaza_id,
    prc_id,
    try_cast(rep_lon as double) as rep_lon,
    try_cast(rep_lat as double) as rep_lat
from read_parquet('data/abr/mt_parcel_pos/*.parquet')
