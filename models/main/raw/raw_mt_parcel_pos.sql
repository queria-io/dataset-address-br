{# デジタル庁 アドレス・ベース・レジストリ 地番マスタ位置参照拡張
   市区町村ごとに配信される CSV を main.py が data/abr/mt_parcel_pos/ に展開する。
   座標の付く筆が 1 つも無い市区町村は配信されない #}

{{ config(materialized='ephemeral') }}

select *
from read_csv(
    'data/abr/mt_parcel_pos/*.csv',
    header=true,
    columns={
        'lg_code': 'VARCHAR',
        'machiaza_id': 'VARCHAR',
        'prc_id': 'VARCHAR',
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
        'moj_map_city_code': 'VARCHAR',
        'moj_map_oaza_code': 'VARCHAR',
        'moj_map_chome_code': 'VARCHAR',
        'moj_map_koaza_code': 'VARCHAR',
        'moj_map_spare_code': 'VARCHAR',
        'moj_map_brushid': 'VARCHAR'
    }
)
