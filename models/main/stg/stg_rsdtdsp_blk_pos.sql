-- 代表点は経緯度のまま渡し、ST_Point は mart で呼ぶ。ビューに ST_Point が残ると、
-- 読む側が spatial をロードしていないと解決できない
-- 1つの街区に代表点が複数あることがある（道路で分かれた街区など）。平均を代表点にする
SELECT
    lg_code,
    machiaza_id,
    blk_id,
    AVG(rep_lon) AS rep_lon,
    AVG(rep_lat) AS rep_lat
FROM {{ ref('raw_mt_rsdtdsp_blk_pos') }}
WHERE rep_lon IS NOT NULL AND rep_lat IS NOT NULL
GROUP BY lg_code, machiaza_id, blk_id
