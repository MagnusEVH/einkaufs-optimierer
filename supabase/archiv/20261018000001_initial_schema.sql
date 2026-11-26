-- ============================================================================
-- Migration: 20261018000001_initial_schema.sql
-- App: Einkaufs-Optimierer
-- Description: PostGIS extension, core global tables, private tables and functions
-- ============================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================================================
-- 2. GLOBAL TABLES (Multi-tenant read-only, Curated / Verified)
-- ============================================================================

-- Product Categories Hierarchy
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    parent_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    icon TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Supermarket Store Chains
CREATE TYPE supermarket_chain AS ENUM ('lidl', 'aldi_nord', 'aldi_sued', 'rewe');

-- Stores (Supermarkt-Filialen) with PostGIS geography
CREATE TABLE IF NOT EXISTS public.stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chain supermarket_chain NOT NULL,
    name TEXT NOT NULL,
    address TEXT,
    postal_code TEXT,
    city TEXT,
    location GEOGRAPHY(Point, 4326) NOT NULL,
    google_place_id TEXT UNIQUE,
    opening_hours JSONB DEFAULT '{}'::jsonb,
    cluster_id UUID,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_stores_location ON public.stores USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_stores_chain ON public.stores (chain);
CREATE INDEX IF NOT EXISTS idx_stores_cluster ON public.stores (cluster_id);

-- Product Catalog (~250 Core Everyday Items)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    gtin_barcode TEXT UNIQUE,
    name TEXT NOT NULL,
    brand TEXT,
    quantity_amount NUMERIC(10, 2) NOT NULL DEFAULT 1.0,
    quantity_unit TEXT NOT NULL CHECK (quantity_unit IN ('g', 'kg', 'ml', 'l', 'piece')),
    is_bio BOOLEAN DEFAULT false NOT NULL,
    is_private_label BOOLEAN DEFAULT false NOT NULL,
    private_label_chain supermarket_chain,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_products_name_trgm ON public.products USING gin (name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_products_barcode ON public.products (gtin_barcode);
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products (category_id);

-- Synonyms & Aliases for Free-Text Search Matching (e.g. "Skyr", "Vollmilch", "Bananen")
CREATE TABLE IF NOT EXISTS public.product_aliases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    alias TEXT NOT NULL,
    priority INT DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_product_aliases_alias ON public.product_aliases (lower(alias));
CREATE INDEX IF NOT EXISTS idx_product_aliases_product ON public.product_aliases (product_id);

-- Store & Chain Specific Prices
CREATE TYPE price_source AS ENUM ('manual_seed', 'scrape', 'receipt_ocr', 'official_api');
CREATE TYPE trust_status_type AS ENUM ('unverified', 'community_verified', 'official');

CREATE TABLE IF NOT EXISTS public.prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
    chain supermarket_chain,
    price_cents INT NOT NULL CHECK (price_cents >= 0),
    base_price_cents_per_unit INT, -- e.g. Cent per 1kg or 1L for fair comparison
    currency TEXT DEFAULT 'EUR' NOT NULL,
    source price_source NOT NULL DEFAULT 'manual_seed',
    trust_status trust_status_type NOT NULL DEFAULT 'unverified',
    confidence_score NUMERIC(3, 2) DEFAULT 1.00 NOT NULL,
    valid_from TIMESTAMPTZ DEFAULT now() NOT NULL,
    valid_to TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    CONSTRAINT check_store_or_chain CHECK (store_id IS NOT NULL OR chain IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_prices_lookup ON public.prices (product_id, chain, store_id, valid_from DESC);

-- Weekly Promotional Offers
CREATE TABLE IF NOT EXISTS public.offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
    chain supermarket_chain NOT NULL,
    discount_price_cents INT NOT NULL CHECK (discount_price_cents >= 0),
    regular_price_cents INT,
    conditions TEXT,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_offers_dates ON public.offers (starts_at, ends_at);
CREATE INDEX IF NOT EXISTS idx_offers_product ON public.offers (product_id);

-- ============================================================================
-- 3. PRIVATE TABLES (Tenant-isolated per user via RLS)
-- ============================================================================

-- User Profiles
CREATE TABLE IF NOT EXISTS public.profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    email TEXT,
    gdpr_consent_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Optimization Preferences
CREATE TYPE transport_mode_type AS ENUM ('car', 'bike', 'walk');

CREATE TABLE IF NOT EXISTS public.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    prefer_private_label BOOLEAN DEFAULT true NOT NULL,
    prefer_bio BOOLEAN DEFAULT false NOT NULL,
    preferred_chains TEXT[] DEFAULT ARRAY['lidl', 'aldi_nord', 'aldi_sued', 'rewe'],
    transport_mode transport_mode_type DEFAULT 'car' NOT NULL,
    cost_per_km_cents NUMERIC(6, 2) DEFAULT 30.00 NOT NULL, -- 0.30 EUR / km
    minute_value_cents NUMERIC(6, 2) DEFAULT 15.00 NOT NULL, -- 9.00 EUR / h
    max_stops INT DEFAULT 2 NOT NULL CHECK (max_stops BETWEEN 1 AND 5),
    search_radius_meters INT DEFAULT 5000 NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Shopping Lists
CREATE TABLE IF NOT EXISTS public.shopping_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT 'Meine Einkaufsliste',
    is_archived BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_shopping_lists_user ON public.shopping_lists (user_id);

-- Shopping List Items
CREATE TABLE IF NOT EXISTS public.list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id UUID NOT NULL REFERENCES public.shopping_lists(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    raw_text TEXT NOT NULL, -- "Skyr Natur 500g" or free text "Skyr"
    matched_product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    quantity NUMERIC(6, 2) DEFAULT 1.0 NOT NULL CHECK (quantity > 0),
    unit TEXT,
    is_checked BOOLEAN DEFAULT false NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_list_items_list ON public.list_items (list_id);
CREATE INDEX IF NOT EXISTS idx_list_items_user ON public.list_items (user_id);

-- Loyalty Wallet (Points & Active Coupons)
CREATE TABLE IF NOT EXISTS public.loyalty_wallet (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    chain supermarket_chain NOT NULL,
    points_balance INT DEFAULT 0 NOT NULL,
    active_coupons JSONB DEFAULT '[]'::jsonb,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    UNIQUE (user_id, chain)
);

CREATE INDEX IF NOT EXISTS idx_loyalty_wallet_user ON public.loyalty_wallet (user_id);

-- Community Price Reports (Phase 2 preparation)
CREATE TABLE IF NOT EXISTS public.price_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    reported_price_cents INT NOT NULL CHECK (reported_price_cents >= 0),
    photo_storage_path TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'rejected')),
    confirmations_count INT DEFAULT 1 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_price_reports_store_product ON public.price_reports (store_id, product_id);
