SELECT
    lg_code,
    machiaza_id,
    machiaza_type,
    LEFT(lg_code, 2) AS pref_code,
    pref AS pref_name,
    pref_kana AS pref_name_kana,
    county AS county_name,
    city AS city_name,
    city_kana AS city_name_kana,
    ward AS ward_name,
    ward_kana AS ward_name_kana,
    oaza_cho,
    oaza_cho_kana,
    chome,
    chome_number,
    koaza,
    koaza_kana,
    post_code,
    efct_date,
    rsdt_addr_flg
FROM {{ ref('raw_mt_town') }}
WHERE lg_code IS NOT NULL
