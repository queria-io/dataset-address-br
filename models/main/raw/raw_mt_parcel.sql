{# デジタル庁 アドレス・ベース・レジストリ 地番マスタと位置参照拡張
   市区町村ごとに配信される CSV を、main.py が使う列だけの Parquet にし、市区町村ごとに地番へ代表点を付けて
   data/abr/parcel/parcel_city<lg_code>.parquet に置く。全国で約 2 億行あるので、元の形の表は持たない #}

{{ config(materialized='ephemeral') }}

select
    lg_code,
    machiaza_id,
    prc_id,
    prc_num1,
    prc_num2,
    prc_num3,
    rsdt_addr_flg,
    rep_lon,
    rep_lat
from read_parquet('data/abr/parcel/*.parquet')
