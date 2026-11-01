{# デジタル庁 アドレス・ベース・レジストリ 地番マスタ
   市区町村ごとに配信される CSV を main.py が data/abr/mt_parcel/ に展開する。
   全国で約 2 億行あるので、元の形の表は持たずに mart で使う列だけを読む #}

{{ config(materialized='ephemeral') }}

select *
from read_csv(
    'data/abr/mt_parcel/*.csv',
    header=true,
    columns={
        'lg_code': 'VARCHAR',
        'machiaza_id': 'VARCHAR',
        'prc_id': 'VARCHAR',
        'city': 'VARCHAR',
        'ward': 'VARCHAR',
        'oaza_cho': 'VARCHAR',
        'chome': 'VARCHAR',
        'koaza': 'VARCHAR',
        'machiaza_dist': 'VARCHAR',
        'prc_num1': 'VARCHAR',
        'prc_num2': 'VARCHAR',
        'prc_num3': 'VARCHAR',
        'rsdt_addr_flg': 'VARCHAR',
        'prc_rec_flg': 'VARCHAR',
        'prc_area_code': 'VARCHAR',
        'efct_date': 'DATE',
        'ablt_date': 'DATE',
        'src_code': 'VARCHAR',
        'remarks': 'VARCHAR',
        'real_prop_num': 'VARCHAR'
    }
)
