{# デジタル庁 アドレス・ベース・レジストリ 住居表示-街区マスタ位置参照拡張
   都道府県ごとに配信される CSV を main.py が data/abr/mt_rsdtdsp_blk_pos/ に展開する #}

{{ config(materialized='table') }}

select *
from read_csv(
    'data/abr/mt_rsdtdsp_blk_pos/*.csv',
    header=true,
    columns={
        'lg_code': 'VARCHAR',
        'machiaza_id': 'VARCHAR',
        'blk_id': 'VARCHAR',
        'rsdt_addr_flg': 'VARCHAR',
        'rsdt_addr_mtd_code': 'VARCHAR',
        'rep_lon': 'DOUBLE',
        'rep_lat': 'DOUBLE',
        'rep_srid': 'VARCHAR',
        'rep_scale': 'VARCHAR',
        'rep_src_code': 'VARCHAR',
        'plygn_fname': 'VARCHAR',
        'plygn_kcode': 'VARCHAR',
        'plygn_fmt': 'VARCHAR',
        'plygn_srid': 'VARCHAR',
        'plygn_scale': 'VARCHAR',
        'plygn_src_code': 'VARCHAR',
        'pos_pref': 'VARCHAR',
        'pos_city': 'VARCHAR',
        'pos_oaza_cho_chome': 'VARCHAR',
        'pos_koaza_aka': 'VARCHAR',
        'pos_blk_prc_num': 'VARCHAR',
        'pos_data_mnt_year': 'VARCHAR',
        'rsdt_addr_code_rdbl': 'VARCHAR',
        'rsdt_addr_data_mnt_date': 'VARCHAR'
    }
)
