{{ config(materialized='ephemeral') }}

-- raw_mt_parcel を mart から読むための stg。列は raw のまま
SELECT * FROM {{ ref('raw_mt_parcel') }}
