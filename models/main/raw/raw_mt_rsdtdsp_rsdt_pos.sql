{# デジタル庁 アドレス・ベース・レジストリ 住居表示-住居マスタ位置参照拡張
   都道府県ごとに配信される CSV を main.py が data/abr/mt_rsdtdsp_rsdt_pos/ に展開する #}

{{ config(materialized='table') }}

select *
from read_csv(
    'data/abr/mt_rsdtdsp_rsdt_pos/*.csv',
    header=true,
    columns={
        'lg_code': 'VARCHAR',
        'machiaza_id': 'VARCHAR',
        'blk_id': 'VARCHAR',
        'rsdt_id': 'VARCHAR',
        'rsdt2_id': 'VARCHAR',
        'rsdt_addr_flg': 'VARCHAR',
        'rsdt_addr_mtd_code': 'VARCHAR',
        'rep_lon': 'DOUBLE',
        'rep_lat': 'DOUBLE',
        'rep_srid': 'VARCHAR',
        'rep_scale': 'VARCHAR',
        'rep_src_code': 'VARCHAR',
        'rsdt_addr_code_rdbl': 'VARCHAR',
        'rsdt_addr_data_mnt_date': 'VARCHAR',
        'basic_rsdt_div': 'VARCHAR'
    }
)
