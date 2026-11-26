-- ============================================================================
-- Migration: 20261018000005_phase2_preferences_and_reports.sql
-- Description: Category-specific store preferences, brand/private-label rules,
--              Netto chain addition, and photo report storage structure
-- ============================================================================

-- 1. Add 'netto' to supermarket_chain enum if not present
DO $$
BEGIN
    ALTER TYPE supermarket_chain ADD VALUE IF NOT EXISTS 'netto';
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Enhanced Preferences Table
-- Add brand preference, bio preference, and category-level chain mapping
ALTER TABLE public.user_preferences
    ADD COLUMN IF NOT EXISTS brand_preference TEXT NOT NULL DEFAULT 'prefer_private_label'
        CHECK (brand_preference IN ('prefer_private_label', 'reject_private_label', 'neutral')),
    ADD COLUMN IF NOT EXISTS bio_preference TEXT NOT NULL DEFAULT 'neutral'
        CHECK (bio_preference IN ('prefer_bio', 'neutral', 'reject_bio')),
    ADD COLUMN IF NOT EXISTS category_store_preferences JSONB NOT NULL DEFAULT '{}'::jsonb;
    -- Example format:
    -- {
    --   "obst": "netto",
    --   "gemuese": "lidl",
    --   "fleisch": "rewe",
    --   "molkerei": "aldi_sued"
    -- }

-- 3. Enhance Price Reports Table for Photo Uploads
ALTER TABLE public.price_reports
    ALTER COLUMN product_id DROP NOT NULL,
    ALTER COLUMN reported_price_cents DROP NOT NULL,
    ADD COLUMN IF NOT EXISTS report_type TEXT NOT NULL DEFAULT 'receipt'
        CHECK (report_type IN ('receipt', 'shelf_label', 'other')),
    ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS user_note TEXT,
    ADD COLUMN IF NOT EXISTS ocr_status TEXT NOT NULL DEFAULT 'pending_ocr'
        CHECK (ocr_status IN ('pending_ocr', 'processing', 'completed', 'failed')),
    ADD COLUMN IF NOT EXISTS ocr_extracted_data JSONB DEFAULT '{}'::jsonb,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now() NOT NULL;

-- 4. Supabase Storage Bucket for Price Reports (Receipts / Shelf Photos)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'price-reports',
    'price-reports',
    false, -- Private bucket
    10485760, -- 10 MB limit
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Storage RLS Policies
CREATE POLICY "Users can upload their own price report photos"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'price-reports' AND
        (auth.uid() = owner OR auth.uid()::text = (storage.foldername(name))[1])
    );

CREATE POLICY "Users can view their own price report photos"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'price-reports' AND
        (auth.uid() = owner OR auth.uid()::text = (storage.foldername(name))[1])
    );

-- 5. Helper Function: Plausibility Check for Community Price Reports
CREATE OR REPLACE FUNCTION public.check_price_plausibility(
    p_product_id UUID,
    p_reported_cents INT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_avg_price NUMERIC;
BEGIN
    SELECT AVG(price_cents) INTO v_avg_price
    FROM public.prices
    WHERE product_id = p_product_id;

    -- If no prices exist, report is accepted as plausible
    IF v_avg_price IS NULL THEN
        RETURN true;
    END IF;

    -- Plausibility: Price must not deviate more than 60% from existing average
    IF p_reported_cents < (v_avg_price * 0.4) OR p_reported_cents > (v_avg_price * 2.5) THEN
        RETURN false;
    END IF;

    RETURN true;
END;
$$ LANGUAGE plpgsql STABLE;
