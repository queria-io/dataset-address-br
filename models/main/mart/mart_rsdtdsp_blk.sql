{{ config(materialized='table') }}

-- lg_code で絞って読むときに Parquet の行グループを読み飛ばせるよう、キーの順に並べて書く
SELECT
    b.lg_code,
    b.machiaza_id,
    b.blk_id,
    b.blk_num,
    ST_Point(pos.rep_lon, pos.rep_lat) AS geometry
FROM {{ ref('stg_rsdtdsp_blk') }} b
LEFT JOIN {{ ref('stg_rsdtdsp_blk_pos') }} pos
    ON b.lg_code = pos.lg_code
    AND b.machiaza_id = pos.machiaza_id
    AND b.blk_id = pos.blk_id
ORDER BY b.lg_code, b.machiaza_id, b.blk_id
