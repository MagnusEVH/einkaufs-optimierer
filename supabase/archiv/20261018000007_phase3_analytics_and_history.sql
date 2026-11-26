-- ============================================================================
-- Migration: 20261018000007_phase3_analytics_and_history.sql
-- Description: Core tables for Developer Analytics, Event Logging, User Sessions,
--              Price History, Bug/Error Reports, and Push Logs with PostGIS/RLS.
-- ============================================================================

-- 1. Analytics Events Table (High-volume event log with JSONB metadata)
CREATE TABLE IF NOT EXISTS public.analytics_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    session_id UUID,
    event_name TEXT NOT NULL,
    category TEXT NOT NULL, -- 'shopping_list', 'routing', 'wallet', 'profile', 'app_lifecycle'
    properties JSONB DEFAULT '{}'::jsonb NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_analytics_events_name_cat ON public.analytics_events (event_name, category);
CREATE INDEX IF NOT EXISTS idx_analytics_events_created ON public.analytics_events (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_events_user ON public.analytics_events (user_id, created_at DESC);

-- 2. User Sessions Table (Tracks session length, frequency, entry/exit points)
CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    started_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    ended_at TIMESTAMPTZ,
    duration_seconds INT DEFAULT 0,
    entry_screen TEXT NOT NULL DEFAULT 'shopping_list',
    platform TEXT NOT NULL DEFAULT 'ios', -- 'ios', 'android', 'web'
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user_start ON public.user_sessions (user_id, started_at DESC);

-- 3. Historical Price Tracking (Records price oscillations from scrapers & receipts)
CREATE TABLE IF NOT EXISTS public.price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE,
    store_id UUID REFERENCES public.stores(id) ON DELETE CASCADE,
    chain supermarket_chain,
    price_cents INT NOT NULL CHECK (price_cents >= 0),
    source TEXT NOT NULL DEFAULT 'scraper', -- 'scraper', 'receipt_ocr', 'user_report'
    recorded_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_price_history_lookup ON public.price_history (product_id, recorded_at DESC);
CREATE INDEX IF NOT EXISTS idx_price_history_store ON public.price_history (store_id, recorded_at DESC);

-- 4. App Error & Community Reports Table (For Developer Dashboard resolution)
CREATE TABLE IF NOT EXISTS public.app_error_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    category TEXT NOT NULL, -- 'price_mismatch', 'ocr_failure', 'sync_issue', 'map_route_bug'
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb NOT NULL,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'ignored')),
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    resolved_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_error_reports_status ON public.app_error_reports (status, created_at DESC);

-- 5. Push Notifications Tracking & Log
CREATE TABLE IF NOT EXISTS public.push_notifications_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    trigger_type TEXT NOT NULL, -- 'sunday_list_reminder', 'expiring_coupon', 'price_drop'
    sent_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    opened_at TIMESTAMPTZ,
    action_taken BOOLEAN DEFAULT false NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_push_log_user ON public.push_notifications_log (user_id, sent_at DESC);

-- ============================================================================
-- 6. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.price_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_error_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.push_notifications_log ENABLE ROW LEVEL SECURITY;

-- Allow authenticated and anonymous users to insert analytics events & sessions
CREATE POLICY "Allow public insert of analytics events"
    ON public.analytics_events FOR INSERT
    WITH CHECK (true);

-- Users can only read their own events (Admin role can read all via service key or RPC)
CREATE POLICY "Users read own analytics events"
    ON public.analytics_events FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Allow public insert of user sessions"
    ON public.user_sessions FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users update own sessions"
    ON public.user_sessions FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users read own sessions"
    ON public.user_sessions FOR SELECT
    USING (auth.uid() = user_id);

-- Price history is publicly readable
CREATE POLICY "Public read price history"
    ON public.price_history FOR SELECT
    USING (true);

-- Error reports: user can submit and read own reports
CREATE POLICY "Users insert error reports"
    ON public.app_error_reports FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users read own error reports"
    ON public.app_error_reports FOR SELECT
    USING (auth.uid() = user_id);

-- Push notifications log: user reads own log
CREATE POLICY "Users read own push log"
    ON public.push_notifications_log FOR SELECT
    USING (auth.uid() = user_id);

-- ============================================================================
-- 7. RPC AGGREGATIONS FOR DEVELOPER DASHBOARD
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_developer_dashboard_kpis(p_days INT DEFAULT 7)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_users INT;
    v_active_users INT;
    v_lists_created INT;
    v_routes_completed INT;
    v_errors_open INT;
    v_coupons_synced INT;
    v_avg_session_seconds NUMERIC;
BEGIN
    -- Total registered users
    SELECT COUNT(*) INTO v_total_users FROM auth.users;

    -- Active users in timeframe
    SELECT COUNT(DISTINCT user_id) INTO v_active_users
    FROM public.analytics_events
    WHERE created_at >= (now() - (p_days || ' days')::interval);

    -- Lists created in timeframe
    SELECT COUNT(*) INTO v_lists_created
    FROM public.analytics_events
    WHERE event_name = 'shopping_list_created'
      AND created_at >= (now() - (p_days || ' days')::interval);

    -- Routes completed
    SELECT COUNT(*) INTO v_routes_completed
    FROM public.analytics_events
    WHERE event_name = 'shopping_route_completed'
      AND created_at >= (now() - (p_days || ' days')::interval);

    -- Open errors
    SELECT COUNT(*) INTO v_errors_open
    FROM public.app_error_reports
    WHERE status = 'open';

    -- Coupons synced
    SELECT COUNT(*) INTO v_coupons_synced
    FROM public.analytics_events
    WHERE event_name = 'coupon_sync_success'
      AND created_at >= (now() - (p_days || ' days')::interval);

    -- Average session duration
    SELECT COALESCE(AVG(duration_seconds), 0) INTO v_avg_session_seconds
    FROM public.user_sessions
    WHERE started_at >= (now() - (p_days || ' days')::interval)
      AND duration_seconds > 0;

    RETURN jsonb_build_object(
        'total_users', v_total_users,
        'active_users', v_active_users,
        'lists_created', v_lists_created,
        'routes_completed', v_routes_completed,
        'open_errors', v_errors_open,
        'coupons_synced', v_coupons_synced,
        'avg_session_seconds', ROUND(v_avg_session_seconds, 1)
    );
END;
$$;

