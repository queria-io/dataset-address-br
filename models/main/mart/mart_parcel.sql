{{ config(
    materialized='table',
    pre_hook="SET threads = 1",
    post_hook="RESET threads",
) }}

-- lg_code で絞って読むときに Parquet の行グループを読み飛ばせるよう、キーの順に書く。
-- main.py が市区町村ごとに代表点を結合し、町字・地番の順に並べたファイル (名前は lg_code の順) を置くので、
-- 読んだ順のまま書けば全体がキーの順になる。2 億行の ORDER BY はランナーのメモリに収まらないので使わない。
-- 並行に書くとスレッドごとに別の市区町村の行が 1 つの行グループに混ざるので、この表だけ 1 スレッドで書く
SELECT
    lg_code,
    machiaza_id,
    prc_id,
    prc_num1,
    prc_num2,
    prc_num3,
    rsdt_addr_flg,
    ST_Point(rep_lon, rep_lat) AS geometry
FROM {{ ref('raw_mt_parcel') }}
