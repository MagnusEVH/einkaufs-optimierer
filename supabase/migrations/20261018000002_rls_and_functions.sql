-- ============================================================================
-- Migration: 20261018000002_rls_and_functions.sql
-- App: Einkaufs-Optimierer
-- Description: RLS security policies, PostGIS clustering functions, triggers
-- ============================================================================

-- ============================================================================
-- 1. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Global Tables: Readable by authenticated & anonymous users, writable only by service role
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Categories readable by all" ON public.categories FOR SELECT USING (true);

ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Stores readable by all" ON public.stores FOR SELECT USING (true);

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Products readable by all" ON public.products FOR SELECT USING (true);

ALTER TABLE public.product_aliases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Product aliases readable by all" ON public.product_aliases FOR SELECT USING (true);

ALTER TABLE public.prices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Prices readable by all" ON public.prices FOR SELECT USING (true);

ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Offers readable by all" ON public.offers FOR SELECT USING (true);

-- Private Tables: Strictly isolated by auth.uid() = user_id
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own preferences" ON public.user_preferences FOR ALL 
    USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.shopping_lists ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own shopping lists" ON public.shopping_lists FOR ALL 
    USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.list_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own list items" ON public.list_items FOR ALL 
    USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.loyalty_wallet ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own loyalty wallet" ON public.loyalty_wallet FOR ALL 
    USING (auth.uid() = user_id) 
    WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.price_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Price reports readable by all" ON public.price_reports FOR SELECT USING (true);
CREATE POLICY "Users can create price reports" ON public.price_reports FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own price reports" ON public.price_reports FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================================
-- 2. STORE CLUSTERING & SPATIAL FUNCTIONS
-- ============================================================================

-- Finds all stores within search radius and groups stores within 500m into clusters
CREATE OR REPLACE FUNCTION public.get_nearby_store_clusters(
    p_lat DOUBLE PRECISION,
    p_lng DOUBLE PRECISION,
    p_radius_meters INT DEFAULT 5000
)
RETURNS TABLE (
    id UUID,
    chain supermarket_chain,
    name TEXT,
    address TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    distance_meters DOUBLE PRECISION,
    cluster_num INT
) AS $$
DECLARE
    user_geo GEOGRAPHY := ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography;
BEGIN
    RETURN QUERY
    WITH candidate_stores AS (
        SELECT 
            s.id,
            s.chain,
            s.name,
            s.address,
            ST_Y(s.location::geometry) AS lat,
            ST_X(s.location::geometry) AS lng,
            s.location::geometry AS geom,
            ST_Distance(s.location, user_geo) AS dist
        FROM public.stores s
        WHERE s.is_active = true
          AND ST_DWithin(s.location, user_geo, p_radius_meters)
    )
    SELECT 
        cs.id,
        cs.chain,
        cs.name,
        cs.address,
        cs.lat AS latitude,
        cs.lng AS longitude,
        cs.dist AS distance_meters,
        -- eps is 500 meters converted approximately to degrees (0.0045 deg ~ 500m)
        COALESCE(ST_ClusterDBSCAN(cs.geom, eps := 0.0045, minpoints := 1) OVER (), 0) AS cluster_num
    FROM candidate_stores cs
    ORDER BY cs.dist ASC;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- ============================================================================
-- 3. USER MANAGEMENT & GDPR RIGHT TO ERASURE
-- ============================================================================

-- Completely delete user account and cascade delete all personal data
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void AS $$
BEGIN
    DELETE FROM auth.users WHERE id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create initial profile and default preferences on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.profiles (user_id, display_name, email)
    VALUES (new.id, COALESCE(new.raw_user_meta_data->>'full_name', 'Nutzer'), new.email)
    ON CONFLICT (user_id) DO NOTHING;

    INSERT INTO public.user_preferences (user_id)
    VALUES (new.id)
    ON CONFLICT (user_id) DO NOTHING;

    INSERT INTO public.shopping_lists (user_id, title)
    VALUES (new.id, 'Mein Einkauf')
    ON CONFLICT DO NOTHING;

    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger AS $$
BEGIN
    new.updated_at = now();
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_stores_updated_at BEFORE UPDATE ON public.stores FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE OR REPLACE TRIGGER trg_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE OR REPLACE TRIGGER trg_shopping_lists_updated_at BEFORE UPDATE ON public.shopping_lists FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE OR REPLACE TRIGGER trg_list_items_updated_at BEFORE UPDATE ON public.list_items FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
