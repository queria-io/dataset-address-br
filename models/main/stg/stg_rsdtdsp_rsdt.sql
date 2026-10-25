SELECT
    lg_code,
    machiaza_id,
    blk_id,
    rsdt_id,
    rsdt2_id,
    blk_num,
    rsdt_num,
    rsdt_num2
FROM {{ ref('raw_mt_rsdtdsp_rsdt') }}
WHERE lg_code IS NOT NULL
