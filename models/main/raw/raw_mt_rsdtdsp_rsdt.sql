{# デジタル庁 アドレス・ベース・レジストリ 住居表示-住居マスタ
   都道府県ごとに配信される CSV を main.py が data/abr/mt_rsdtdsp_rsdt/ に展開する #}

{{ config(materialized='table') }}

select *
from read_csv(
    'data/abr/mt_rsdtdsp_rsdt/*.csv',
    header=true,
    columns={
        'lg_code': 'VARCHAR',
        'machiaza_id': 'VARCHAR',
        'blk_id': 'VARCHAR',
        'rsdt_id': 'VARCHAR',
        'rsdt2_id': 'VARCHAR',
        'city': 'VARCHAR',
        'ward': 'VARCHAR',
        'oaza_cho': 'VARCHAR',
        'chome': 'VARCHAR',
        'koaza': 'VARCHAR',
        'machiaza_dist': 'VARCHAR',
        'blk_num': 'VARCHAR',
        'rsdt_num': 'VARCHAR',
        'rsdt_num2': 'VARCHAR',
        'basic_rsdt_div': 'VARCHAR',
        'rsdt_addr_flg': 'VARCHAR',
        'rsdt_addr_mtd_code': 'VARCHAR',
        'status_flg': 'VARCHAR',
        'efct_date': 'DATE',
        'ablt_date': 'DATE',
        'src_code': 'VARCHAR',
        'remarks': 'VARCHAR'
    }
)
