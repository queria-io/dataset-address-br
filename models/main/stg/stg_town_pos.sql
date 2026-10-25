-- 代表点は経緯度のまま渡し、ST_Point は mart で呼ぶ。ビューに ST_Point が残ると、
-- 読む側が spatial をロードしていないと解決できない
-- 同じ町字の行が重なって配信されることがある（座標も同じ）
SELECT DISTINCT
    lg_code,
    machiaza_id,
    rep_lon,
    rep_lat
FROM {{ ref('raw_mt_town_pos') }}
WHERE rep_lon IS NOT NULL AND rep_lat IS NOT NULL
