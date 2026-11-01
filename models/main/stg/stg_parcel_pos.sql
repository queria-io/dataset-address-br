{{ config(materialized='ephemeral') }}

-- 同じ筆が同じ座標で 2 行入っていることがある（日野市で 18,385 行が 9,382 筆）。筆ごとに 1 行にする。
-- 代表点は経緯度のまま渡し、ST_Point は mart で呼ぶ
SELECT
    lg_code,
    machiaza_id,
    prc_id,
    AVG(rep_lon) AS rep_lon,
    AVG(rep_lat) AS rep_lat
FROM {{ ref('raw_mt_parcel_pos') }}
WHERE rep_lon IS NOT NULL AND rep_lat IS NOT NULL
GROUP BY lg_code, machiaza_id, prc_id
