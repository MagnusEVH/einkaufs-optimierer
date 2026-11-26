-- ============================================================================
-- Migration: 20261018000004_seed_test_stores.sql
-- Description: Realistic test stores with verified < 500m cluster groupings
-- ============================================================================

-- Cluster A (Cologne Kalk - Arcaden / Rolshover Str.)
-- Lidl & Rewe are ~220m apart -> Forms Cluster A (< 500m)
INSERT INTO public.stores (id, chain, name, address, postal_code, city, location, google_place_id)
VALUES 
(
    '33333333-0000-0000-0000-000000000001',
    'lidl',
    'Lidl Filiale Köln Kalk',
    'Rolshover Str. 11',
    '51105',
    'Köln',
    ST_SetSRID(ST_MakePoint(6.9942, 50.9335), 4326)::geography,
    'ChIJ_lidl_kalk_001'
),
(
    '33333333-0000-0000-0000-000000000002',
    'rewe',
    'REWE Center Kalk',
    'Kalker Hauptstraße 55',
    '51103',
    'Köln',
    ST_SetSRID(ST_MakePoint(6.9965, 50.9348), 4326)::geography, -- ~220m from Lidl
    'ChIJ_rewe_kalk_002'
)
ON CONFLICT (id) DO NOTHING;

-- Cluster B (Cologne Deutz / Poll)
-- Aldi Süd & Lidl are ~310m apart -> Forms Cluster B (< 500m)
INSERT INTO public.stores (id, chain, name, address, postal_code, city, location, google_place_id)
VALUES 
(
    '33333333-0000-0000-0000-000000000003',
    'aldi_sued',
    'ALDI SÜD Köln Deutz',
    'Siegburger Str. 149',
    '50679',
    'Köln',
    ST_SetSRID(ST_MakePoint(6.9805, 50.9270), 4326)::geography,
    'ChIJ_aldi_deutz_003'
),
(
    '33333333-0000-0000-0000-000000000004',
    'lidl',
    'Lidl Filiale Köln Deutz',
    'Deutzer Freiheit 70',
    '50679',
    'Köln',
    ST_SetSRID(ST_MakePoint(6.9775, 50.9290), 4326)::geography, -- ~310m from Aldi
    'ChIJ_lidl_deutz_004'
)
ON CONFLICT (id) DO NOTHING;

-- Single Isolated Store (Cologne Mülheim, ~3.8km away, isolated)
INSERT INTO public.stores (id, chain, name, address, postal_code, city, location, google_place_id)
VALUES 
(
    '33333333-0000-0000-0000-000000000005',
    'rewe',
    'REWE City Köln Mülheim',
    'Frankfurter Str. 35',
    '51065',
    'Köln',
    ST_SetSRID(ST_MakePoint(7.0090, 50.9650), 4326)::geography,
    'ChIJ_rewe_muelheim_005'
)
ON CONFLICT (id) DO NOTHING;
