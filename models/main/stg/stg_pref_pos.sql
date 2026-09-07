-- ジオメトリを持つモデルはテーブルで実体化する。ビューのままだと ST_Point の呼び出しが
-- カタログに残り、読む側が spatial をロードしていないと解決できない
{{ config(materialized='table') }}

SELECT
    lg_code,
    ST_Point(rep_lon, rep_lat) AS geometry
FROM {{ ref('raw_mt_pref_pos') }}
WHERE rep_lon IS NOT NULL AND rep_lat IS NOT NULL
