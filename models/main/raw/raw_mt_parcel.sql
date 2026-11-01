{# デジタル庁 アドレス・ベース・レジストリ 地番マスタ
   市区町村ごとに配信される CSV を、main.py が使う列だけの Parquet にして data/abr/mt_parcel/ に置く。
   全国で約 2 億行あるので、元の形の表は持たない #}

{{ config(materialized='ephemeral') }}

select
    lg_code,
    machiaza_id,
    prc_id,
    prc_num1,
    prc_num2,
    prc_num3,
    rsdt_addr_flg
from read_parquet('data/abr/mt_parcel/*.parquet')
