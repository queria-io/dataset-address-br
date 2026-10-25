{{ config(materialized='table') }}

-- lg_code で絞って読むときに Parquet の行グループを読み飛ばせるよう、キーの順に並べて書く
SELECT
    t.*,
    f.oaza_cho_uncmn_reg,
    f.oaza_cho_uncmn_mj,
    f.oaza_cho_uncmn_type,
    f.oaza_cho_uncmn_code,
    f.koaza_uncmn_reg,
    f.koaza_uncmn_mj,
    f.koaza_uncmn_type,
    f.koaza_uncmn_code,
    f.alias_oaza,
    f.alias_oaza_kana,
    f.alias_oaza_roma,
    f.alias_koaza,
    f.alias_koaza_kana,
    f.alias_koaza_roma,
    ST_Point(pos.rep_lon, pos.rep_lat) AS geometry
FROM {{ ref('stg_town') }} t
LEFT JOIN {{ ref('stg_town_fullset') }} f
    ON t.lg_code = f.lg_code AND t.machiaza_id = f.machiaza_id
-- 位置参照拡張の住居表示フラグは町字マスタと食い違うことがあるので、結合には使わない
LEFT JOIN {{ ref('stg_town_pos') }} pos
    ON t.lg_code = pos.lg_code AND t.machiaza_id = pos.machiaza_id
ORDER BY t.lg_code, t.machiaza_id
