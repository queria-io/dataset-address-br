{{ config(materialized='table') }}

-- lg_code で絞って読むときに Parquet の行グループを読み飛ばせるよう、キーの順に並べて書く
SELECT
    r.lg_code,
    r.machiaza_id,
    r.blk_id,
    r.rsdt_id,
    r.rsdt2_id,
    r.blk_num,
    r.rsdt_num,
    r.rsdt_num2,
    ST_Point(pos.rep_lon, pos.rep_lat) AS geometry
FROM {{ ref('stg_rsdtdsp_rsdt') }} r
LEFT JOIN {{ ref('stg_rsdtdsp_rsdt_pos') }} pos
    ON r.lg_code = pos.lg_code
    AND r.machiaza_id = pos.machiaza_id
    AND r.blk_id = pos.blk_id
    AND r.rsdt_id = pos.rsdt_id
    AND r.rsdt2_id IS NOT DISTINCT FROM pos.rsdt2_id
ORDER BY r.lg_code, r.machiaza_id, r.blk_id, r.rsdt_id, r.rsdt2_id
