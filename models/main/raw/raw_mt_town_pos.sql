{# デジタル庁 アドレス・ベース・レジストリ 町字マスタ位置参照拡張
   都道府県ごとに配信される CSV を main.py が data/abr/mt_town_pos/ に展開する #}

{{ config(materialized='table') }}

select *
from read_csv(
    'data/abr/mt_town_pos/*.csv',
    header=true,
    columns={
        'lg_code': 'VARCHAR',
        'machiaza_id': 'VARCHAR',
        'rsdt_addr_flg': 'VARCHAR',
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
        'pos_oaza_cho_chome_code': 'VARCHAR',
        'pos_data_mnt_year': 'VARCHAR',
        'cns_bnd_s_area_kcode': 'VARCHAR',
        'cns_bnd_year': 'VARCHAR'
    }
)
