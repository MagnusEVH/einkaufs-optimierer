-- ============================================================================
-- Migration: 20261018000006_phase3_offers_and_wallet.sql
-- Description: Weekly promotional offers catalog, loyalty wallet accounts,
--              user coupons with RLS, and optimization coupon functions.
-- ============================================================================

-- 1. Enhance Offers Table for Weekly Promotions
CREATE TABLE IF NOT EXISTS public.offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
    chain supermarket_chain NOT NULL,
    title TEXT NOT NULL,
    discount_price_cents INT NOT NULL CHECK (discount_price_cents >= 0),
    regular_price_cents INT,
    discount_percent INT,
    conditions TEXT, -- e.g. "Gültig ab 2 Stück"
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_offers_lookup ON public.offers (product_id, chain, starts_at, ends_at);
CREATE INDEX IF NOT EXISTS idx_offers_active ON public.offers (is_active, ends_at);

-- 2. Enhanced Loyalty Wallet Table
-- Stores user points balances across retail reward programs
CREATE TABLE IF NOT EXISTS public.loyalty_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    chain supermarket_chain NOT NULL,
    program_name TEXT NOT NULL, -- e.g. 'Payback', 'Lidl Plus', 'DeutschlandCard'
    points_balance INT NOT NULL DEFAULT 0 CHECK (points_balance >= 0),
    points_value_cents INT NOT NULL DEFAULT 0, -- 1 Payback Point = 1 Cent
    card_number_masked TEXT, -- e.g. '**** 1234'
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    UNIQUE(user_id, chain)
);

CREATE INDEX IF NOT EXISTS idx_loyalty_accounts_user ON public.loyalty_accounts (user_id);

-- 3. User Coupons Table
-- Active or manually added coupons that the optimizer applies
CREATE TYPE coupon_discount_type AS ENUM ('percent', 'fixed_amount', 'points_multiplier');

CREATE TABLE IF NOT EXISTS public.user_coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    chain supermarket_chain NOT NULL,
    title TEXT NOT NULL,
    discount_type coupon_discount_type NOT NULL DEFAULT 'percent',
    discount_value NUMERIC(6, 2) NOT NULL, -- e.g. 10.0 for 10% or 100 for 1.00 EUR
    category_slug TEXT, -- e.g. 'obst', 'gemuese', 'molkerei', or NULL for store-wide
    min_spend_cents INT DEFAULT 0 NOT NULL, -- Minimum basket value for coupon to trigger
    valid_until TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_user_coupons_user ON public.user_coupons (user_id, chain, is_active);

-- ============================================================================
-- 4. RLS POLICIES FOR OFFERS & WALLET
-- ============================================================================

-- Offers are global and publicly readable
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Offers are viewable by all" ON public.offers FOR SELECT USING (true);

-- Loyalty accounts are strictly private
ALTER TABLE public.loyalty_accounts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own loyalty accounts"
    ON public.loyalty_accounts FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Coupons are strictly private
ALTER TABLE public.user_coupons ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own coupons"
    ON public.user_coupons FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- 5. SEED DATA: CURRENT WEEKLY OFFERS
-- ============================================================================

-- Insert sample weekly promotional offers valid for the current week
INSERT INTO public.offers (id, chain, title, discount_price_cents, regular_price_cents, discount_percent, starts_at, ends_at)
VALUES
(
    '44444444-0000-0000-0000-000000000001',
    'rewe',
    'Barilla Spaghetti No. 5 Wochenknüller',
    149,
    199,
    25,
    now() - interval '1 day',
    now() + interval '6 days'
),
(
    '44444444-0000-0000-0000-000000000002',
    'rewe',
    'Dr. Oetker Ristorante Pizza Wochenangebot',
    249,
    349,
    28,
    now() - interval '1 day',
    now() + interval '6 days'
),
(
    '44444444-0000-0000-0000-000000000003',
    'lidl',
    'Somat Gold Spülmaschinentabs Knallerpreis',
    749,
    849,
    12,
    now() - interval '1 day',
    now() + interval '6 days'
),
(
    '44444444-0000-0000-0000-000000000004',
    'lidl',
    'Kerrygold Irische Butter im Angebot',
    219,
    279,
    21,
    now() - interval '1 day',
    now() + interval '6 days'
),
(
    '44444444-0000-0000-0000-000000000005',
    'netto',
    'Bio Bananen Frische-Aktion',
    159,
    199,
    20,
    now() - interval '1 day',
    now() + interval '6 days'
),
(
    '44444444-0000-0000-0000-000000000006',
    'aldi_sued',
    'Kaffee Crema Ganze Bohnen 1kg Aktionspreis',
    899,
    999,
    10,
    now() - interval '1 day',
    now() + interval '6 days'
)
ON CONFLICT (id) DO NOTHING;
