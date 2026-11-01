{{ config(materialized='table') }}

-- lg_code で絞って読むときに Parquet の行グループを読み飛ばせるよう、キーの順に並べて書く
SELECT
    p.lg_code,
    p.machiaza_id,
    p.prc_id,
    p.prc_num1,
    p.prc_num2,
    p.prc_num3,
    p.rsdt_addr_flg,
    ST_Point(pos.rep_lon, pos.rep_lat) AS geometry
FROM {{ ref('raw_mt_parcel') }} p
LEFT JOIN {{ ref('stg_parcel_pos') }} pos
    ON p.lg_code = pos.lg_code
    AND p.machiaza_id = pos.machiaza_id
    AND p.prc_id = pos.prc_id
WHERE p.lg_code IS NOT NULL
ORDER BY p.lg_code, p.machiaza_id, p.prc_id
