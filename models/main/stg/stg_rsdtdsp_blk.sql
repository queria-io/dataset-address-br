SELECT
    lg_code,
    machiaza_id,
    blk_id,
    blk_num
FROM {{ ref('raw_mt_rsdtdsp_blk') }}
WHERE lg_code IS NOT NULL
