-- ============================================================================
-- Seed File: 20261018000003_seed_catalog_250.sql
-- Description: Inserts categories, 250 staple everyday products, aliases, and prices
-- ============================================================================

-- 1. Insert Categories
INSERT INTO public.categories (id, name, icon) VALUES ('11111111-0000-0000-0000-000000000001', 'Obst & Gemüse', 'apple') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.categories (id, name, icon) VALUES ('11111111-0000-0000-0000-000000000002', 'Molkerei & Eier', 'egg') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.categories (id, name, icon) VALUES ('11111111-0000-0000-0000-000000000003', 'Brot & Backwaren', 'bread') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.categories (id, name, icon) VALUES ('11111111-0000-0000-0000-000000000004', 'Fleisch, Fisch & Veggie', 'food_bank') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.categories (id, name, icon) VALUES ('11111111-0000-0000-0000-000000000005', 'Vorrat & Teigwaren', 'rice_bowl') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.categories (id, name, icon) VALUES ('11111111-0000-0000-0000-000000000006', 'Süßes & Snacks', 'cookie') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.categories (id, name, icon) VALUES ('11111111-0000-0000-0000-000000000007', 'Getränke & Kaffee', 'local_cafe') ON CONFLICT (id) DO NOTHING;
INSERT INTO public.categories (id, name, icon) VALUES ('11111111-0000-0000-0000-000000000008', 'Drogerie & Haushalt', 'clean_hands') ON CONFLICT (id) DO NOTHING;

-- 2. Insert Products
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', '400000100000', 'Bananen', 'Fairtrade', 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000002', '11111111-0000-0000-0000-000000000001', '400000100001', 'Bio Bananen', NULL, 1, 'kg', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000003', '11111111-0000-0000-0000-000000000001', '400000100002', 'Äpfel Gala', NULL, 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000004', '11111111-0000-0000-0000-000000000001', '400000100003', 'Bio Äpfel Topaz', NULL, 1, 'kg', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000005', '11111111-0000-0000-0000-000000000001', '400000100004', 'Gurke', NULL, 1, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000006', '11111111-0000-0000-0000-000000000001', '400000100005', 'Bio Gurke', NULL, 1, 'piece', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000007', '11111111-0000-0000-0000-000000000001', '400000100006', 'Rispentomaten', NULL, 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000008', '11111111-0000-0000-0000-000000000001', '400000100007', 'Cherrytomaten 250g', NULL, 250, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000009', '11111111-0000-0000-0000-000000000001', '400000100008', 'Bio Cherrytomaten 250g', NULL, 250, 'g', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000000a', '11111111-0000-0000-0000-000000000001', '400000100009', 'Speisekartoffeln festkochend 2,5kg', NULL, 2.5, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000000b', '11111111-0000-0000-0000-000000000001', '400000100010', 'Bio Kartoffeln 1,5kg', NULL, 1.5, 'kg', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000000c', '11111111-0000-0000-0000-000000000001', '400000100011', 'Zwiebeln gelb 1kg', NULL, 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000000d', '11111111-0000-0000-0000-000000000001', '400000100012', 'Rote Zwiebeln 500g', NULL, 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000000e', '11111111-0000-0000-0000-000000000001', '400000100013', 'Möhren / Karotten 1kg', NULL, 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000000f', '11111111-0000-0000-0000-000000000001', '400000100014', 'Bio Möhren 1kg', NULL, 1, 'kg', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000010', '11111111-0000-0000-0000-000000000001', '400000100015', 'Paprika Dreierpack 500g', NULL, 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000011', '11111111-0000-0000-0000-000000000001', '400000100016', 'Spitzpaprika rot 500g', NULL, 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000012', '11111111-0000-0000-0000-000000000001', '400000100017', 'Eisbergsalat', NULL, 1, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000013', '11111111-0000-0000-0000-000000000001', '400000100018', 'Kopfsalat', NULL, 1, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000014', '11111111-0000-0000-0000-000000000001', '400000100019', 'Rucola 125g', NULL, 125, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000015', '11111111-0000-0000-0000-000000000001', '400000100020', 'Babyspinat 125g', NULL, 125, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000016', '11111111-0000-0000-0000-000000000001', '400000100021', 'Zucchini 1kg', NULL, 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000017', '11111111-0000-0000-0000-000000000001', '400000100022', 'Auberginen 1kg', NULL, 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000018', '11111111-0000-0000-0000-000000000001', '400000100023', 'Brokkoli 500g', NULL, 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000019', '11111111-0000-0000-0000-000000000001', '400000100024', 'Blumenkohl', NULL, 1, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000001a', '11111111-0000-0000-0000-000000000001', '400000100025', 'Champignons braun 400g', NULL, 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000001b', '11111111-0000-0000-0000-000000000001', '400000100026', 'Champignons weiß 400g', NULL, 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000001c', '11111111-0000-0000-0000-000000000001', '400000100027', 'Avocado Hass genussreif', NULL, 1, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000001d', '11111111-0000-0000-0000-000000000001', '400000100028', 'Bio Avocado 2er Pack', NULL, 2, 'piece', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000001e', '11111111-0000-0000-0000-000000000001', '400000100029', 'Heidelbeeren 300g', NULL, 300, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000001f', '11111111-0000-0000-0000-000000000001', '400000100030', 'Erdbeeren 500g', NULL, 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000020', '11111111-0000-0000-0000-000000000001', '400000100031', 'Zitronen Netz 500g', NULL, 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000021', '11111111-0000-0000-0000-000000000001', '400000100032', 'Bio Zitronen 500g', NULL, 500, 'g', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000022', '11111111-0000-0000-0000-000000000001', '400000100033', 'Knoblauch 200g', NULL, 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000023', '11111111-0000-0000-0000-000000000001', '400000100034', 'Ingwer 250g', NULL, 250, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000024', '11111111-0000-0000-0000-000000000002', '400000100035', 'Skyr Natur 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000025', '11111111-0000-0000-0000-000000000002', '400000100036', 'Skyr Vanille 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000026', '11111111-0000-0000-0000-000000000002', '400000100037', 'Ísey Skyr Erdbeere 170g', 'Ísey', 170, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000027', '11111111-0000-0000-0000-000000000002', '400000100038', 'Frische Vollmilch 3,5% 1L', 'Eigenmarke', 1, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000028', '11111111-0000-0000-0000-000000000002', '400000100039', 'H-Vollmilch 3,5% 1L', 'Eigenmarke', 1, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000029', '11111111-0000-0000-0000-000000000002', '400000100040', 'Frische fettarme Milch 1,5% 1L', 'Eigenmarke', 1, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000002a', '11111111-0000-0000-0000-000000000002', '400000100041', 'H-Milch fettarm 1,5% 1L', 'Eigenmarke', 1, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000002b', '11111111-0000-0000-0000-000000000002', '400000100042', 'Bio Frische Milch 3,8% 1L', 'Eigenmarke', 1, 'l', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000002c', '11111111-0000-0000-0000-000000000002', '400000100043', 'Bärenmarke Frische Alpenmilch 3,8% 1L', 'Bärenmarke', 1, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000002d', '11111111-0000-0000-0000-000000000002', '400000100044', 'Deutsche Markenbutter 250g', 'Eigenmarke', 250, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000002e', '11111111-0000-0000-0000-000000000002', '400000100045', 'Bio Süßrahmbutter 250g', 'Eigenmarke', 250, 'g', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000002f', '11111111-0000-0000-0000-000000000002', '400000100046', 'Kerrygold Irische Butter 250g', 'Kerrygold', 250, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000030', '11111111-0000-0000-0000-000000000002', '400000100047', 'Magerquark 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000031', '11111111-0000-0000-0000-000000000002', '400000100048', 'Speisequark 20% 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000032', '11111111-0000-0000-0000-000000000002', '400000100049', 'Bio Magerquark 500g', 'Eigenmarke', 500, 'g', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000033', '11111111-0000-0000-0000-000000000002', '400000100050', 'Naturjoghurt 3,5% 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000034', '11111111-0000-0000-0000-000000000002', '400000100051', 'Griechischer Joghurt 10% 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000035', '11111111-0000-0000-0000-000000000002', '400000100052', 'Ehrmann Grand Dessert Schoko 190g', 'Ehrmann', 190, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000036', '11111111-0000-0000-0000-000000000002', '400000100053', 'Schmand 24% 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000037', '11111111-0000-0000-0000-000000000002', '400000100054', 'Saure Sahne 10% 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000038', '11111111-0000-0000-0000-000000000002', '400000100055', 'Schlagsahne 30% 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000039', '11111111-0000-0000-0000-000000000002', '400000100056', 'Crème Fraîche 150g', 'Eigenmarke', 150, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000003a', '11111111-0000-0000-0000-000000000002', '400000100057', 'Gouda jung in Scheiben 400g', 'Eigenmarke', 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000003b', '11111111-0000-0000-0000-000000000002', '400000100058', 'Gouda mittelalt 300g', 'Eigenmarke', 300, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000003c', '11111111-0000-0000-0000-000000000002', '400000100059', 'Butterkäse Scheiben 400g', 'Eigenmarke', 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000003d', '11111111-0000-0000-0000-000000000002', '400000100060', 'Emmentaler gerieben 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000003e', '11111111-0000-0000-0000-000000000002', '400000100061', 'Gouda gerieben 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000003f', '11111111-0000-0000-0000-000000000002', '400000100062', 'Mozzarella Kugel 125g', 'Eigenmarke', 125, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000040', '11111111-0000-0000-0000-000000000002', '400000100063', 'Bio Mozzarella 125g', 'Eigenmarke', 125, 'g', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000041', '11111111-0000-0000-0000-000000000002', '400000100064', 'Galbani Mozzarella 125g', 'Galbani', 125, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000042', '11111111-0000-0000-0000-000000000002', '400000100065', 'Hirtenkäse / Weichkäse 250g', 'Eigenmarke', 250, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000043', '11111111-0000-0000-0000-000000000002', '400000100066', 'Original Griechischer Feta 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000044', '11111111-0000-0000-0000-000000000002', '400000100067', 'Frischkäse Doppelrahm 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000045', '11111111-0000-0000-0000-000000000002', '400000100068', 'Philadelphia Original 175g', 'Philadelphia', 175, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000046', '11111111-0000-0000-0000-000000000002', '400000100069', 'Camembert 250g', 'Eigenmarke', 250, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000047', '11111111-0000-0000-0000-000000000002', '400000100070', 'Parmigiano Reggiano 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000048', '11111111-0000-0000-0000-000000000002', '400000100071', 'Frische Eier Bodenhaltung Gr. M/L 10er', 'Eigenmarke', 10, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000049', '11111111-0000-0000-0000-000000000002', '400000100072', 'Freilandeier Gr. M/L 10er', 'Eigenmarke', 10, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000004a', '11111111-0000-0000-0000-000000000002', '400000100073', 'Bio Eier 10er', 'Eigenmarke', 10, 'piece', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000004b', '11111111-0000-0000-0000-000000000002', '400000100074', 'Oatly Hafermilch Barista 1L', 'Oatly', 1, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000004c', '11111111-0000-0000-0000-000000000002', '400000100075', 'Bio Haferdrink Natur 1L', 'Eigenmarke', 1, 'l', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000004d', '11111111-0000-0000-0000-000000000002', '400000100076', 'Bio Sojadrink Natur 1L', 'Eigenmarke', 1, 'l', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000004e', '11111111-0000-0000-0000-000000000002', '400000100077', 'Müller Milchreis Zimt 200g', 'Müller', 200, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000004f', '11111111-0000-0000-0000-000000000002', '400000100078', 'Zott Sahnejoghurt Erdbeer 150g', 'Zott', 150, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000050', '11111111-0000-0000-0000-000000000002', '400000100079', 'Activia Natur 4x115g', 'Danone', 460, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000051', '11111111-0000-0000-0000-000000000003', '400000100080', 'Butter Toastbrot 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000052', '11111111-0000-0000-0000-000000000003', '400000100081', 'Vollkorn Toastbrot 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000053', '11111111-0000-0000-0000-000000000003', '400000100082', 'Golden Toast Butter 500g', 'Golden Toast', 500, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000054', '11111111-0000-0000-0000-000000000003', '400000100083', 'Weizenmischbrot geschnitten 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000055', '11111111-0000-0000-0000-000000000003', '400000100084', 'Vollkornbrot geschnitten 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000056', '11111111-0000-0000-0000-000000000003', '400000100085', 'Paderborner Landbrot 1kg', 'Eigenmarke', 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000057', '11111111-0000-0000-0000-000000000003', '400000100086', 'Sonnenblumenkernbrot 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000058', '11111111-0000-0000-0000-000000000003', '400000100087', 'Baguette zum Aufbacken 2x150g', 'Eigenmarke', 300, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000059', '11111111-0000-0000-0000-000000000003', '400000100088', 'Kräuterbutter Baguette 175g', 'Eigenmarke', 175, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000005a', '11111111-0000-0000-0000-000000000003', '400000100089', 'Weizenbrötchen zum Fertigbacken 6er', 'Eigenmarke', 300, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000005b', '11111111-0000-0000-0000-000000000003', '400000100090', 'Mehrkornbrötchen 4er', 'Eigenmarke', 260, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000005c', '11111111-0000-0000-0000-000000000003', '400000100091', 'Knäckebrot Roggen 250g', 'Eigenmarke', 250, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000005d', '11111111-0000-0000-0000-000000000003', '400000100092', 'Wasa Knäckebrot Sesam 200g', 'Wasa', 200, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000005e', '11111111-0000-0000-0000-000000000003', '400000100093', 'Tortilla Wraps Weizen 6er 370g', 'Eigenmarke', 370, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000005f', '11111111-0000-0000-0000-000000000003', '400000100094', 'Pizzaboden mit Tomatensauce 600g', 'Eigenmarke', 600, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000060', '11111111-0000-0000-0000-000000000003', '400000100095', 'Haferflocken zart 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000061', '11111111-0000-0000-0000-000000000003', '400000100096', 'Haferflocken kernig 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000062', '11111111-0000-0000-0000-000000000003', '400000100097', 'Bio Haferflocken 500g', 'Eigenmarke', 500, 'g', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000063', '11111111-0000-0000-0000-000000000003', '400000100098', 'Kölln Flocken Blütenzart 500g', 'Kölln', 500, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000064', '11111111-0000-0000-0000-000000000003', '400000100099', 'Weizenmehl Type 405 1kg', 'Eigenmarke', 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000065', '11111111-0000-0000-0000-000000000003', '400000100100', 'Bio Dinkelmehl Type 630 1kg', 'Eigenmarke', 1, 'kg', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000066', '11111111-0000-0000-0000-000000000003', '400000100101', 'Weißer Haushaltszucker 1kg', 'Eigenmarke', 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000067', '11111111-0000-0000-0000-000000000003', '400000100102', 'Puderzucker 250g', 'Eigenmarke', 250, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000068', '11111111-0000-0000-0000-000000000003', '400000100103', 'Backpulver 10er Pack', 'Eigenmarke', 150, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000069', '11111111-0000-0000-0000-000000000003', '400000100104', 'Frische Backhefe 42g', 'Eigenmarke', 42, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000006a', '11111111-0000-0000-0000-000000000004', '400000100105', 'Hackfleisch gemischt (Rind & Schwein) 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000006b', '11111111-0000-0000-0000-000000000004', '400000100106', 'Rinderhackfleisch 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000006c', '11111111-0000-0000-0000-000000000004', '400000100107', 'Bio Rinderhackfleisch 400g', 'Eigenmarke', 400, 'g', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000006d', '11111111-0000-0000-0000-000000000004', '400000100108', 'Hähnchenbrustfilet 600g', 'Eigenmarke', 600, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000006e', '11111111-0000-0000-0000-000000000004', '400000100109', 'Hähnchen-Innenfilet 400g', 'Eigenmarke', 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000006f', '11111111-0000-0000-0000-000000000004', '400000100110', 'Bio Hähnchenbrust 300g', 'Eigenmarke', 300, 'g', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000070', '11111111-0000-0000-0000-000000000004', '400000100111', 'Putenschnitzel 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000071', '11111111-0000-0000-0000-000000000004', '400000100112', 'Rostbratwurst 5er 450g', 'Eigenmarke', 450, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000072', '11111111-0000-0000-0000-000000000004', '400000100113', 'Wiener Würstchen 400g', 'Eigenmarke', 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000073', '11111111-0000-0000-0000-000000000004', '400000100114', 'Kochschinken geschnitten 150g', 'Eigenmarke', 150, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000074', '11111111-0000-0000-0000-000000000004', '400000100115', 'Geflügel-Mortadella 150g', 'Eigenmarke', 150, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000075', '11111111-0000-0000-0000-000000000004', '400000100116', 'Salami 1A 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000076', '11111111-0000-0000-0000-000000000004', '400000100117', 'Lachsschinken 100g', 'Eigenmarke', 100, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000077', '11111111-0000-0000-0000-000000000004', '400000100118', 'Bacon / Frühstücksspeck 100g', 'Eigenmarke', 100, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000078', '11111111-0000-0000-0000-000000000004', '400000100119', 'Schinkenwürfel 2x125g', 'Eigenmarke', 250, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000079', '11111111-0000-0000-0000-000000000004', '400000100120', 'Lachsfilet frisch mit Haut 300g', 'Eigenmarke', 300, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000007a', '11111111-0000-0000-0000-000000000004', '400000100121', 'Räucherlachs 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000007b', '11111111-0000-0000-0000-000000000004', '400000100122', 'Thunfisch in eigenem Saft 185g', 'Eigenmarke', 185, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000007c', '11111111-0000-0000-0000-000000000004', '400000100123', 'Thunfisch in Sonnenblumenöl 185g', 'Eigenmarke', 185, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000007d', '11111111-0000-0000-0000-000000000004', '400000100124', 'Iglo Fischstäbchen 15er 450g', 'Iglo', 450, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000007e', '11111111-0000-0000-0000-000000000004', '400000100125', 'Fischstäbchen 15er 450g', 'Eigenmarke', 450, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000007f', '11111111-0000-0000-0000-000000000004', '400000100126', 'Tofu Natur Bio 400g', 'Eigenmarke', 400, 'g', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000080', '11111111-0000-0000-0000-000000000004', '400000100127', 'Räuchertofu Bio 350g', 'Eigenmarke', 350, 'g', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000081', '11111111-0000-0000-0000-000000000004', '400000100128', 'Vegane Mühlen Salami 80g', 'Rügenwalder Mühle', 80, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000082', '11111111-0000-0000-0000-000000000004', '400000100129', 'Vegane Mühlen Bratwurst 180g', 'Rügenwalder Mühle', 180, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000083', '11111111-0000-0000-0000-000000000004', '400000100130', 'Veganes Hack 250g', 'Eigenmarke', 250, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000084', '11111111-0000-0000-0000-000000000004', '400000100131', 'Vegane Burger Patties 227g', 'Eigenmarke', 227, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000085', '11111111-0000-0000-0000-000000000004', '400000100132', 'Vegane Nuggets 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000086', '11111111-0000-0000-0000-000000000004', '400000100133', 'Falafel Bällchen 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000087', '11111111-0000-0000-0000-000000000004', '400000100134', 'Hummus Natur 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000088', '11111111-0000-0000-0000-000000000005', '400000100135', 'Spaghetti No. 5 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000089', '11111111-0000-0000-0000-000000000005', '400000100136', 'Penne Rigate 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000008a', '11111111-0000-0000-0000-000000000005', '400000100137', 'Fusilli 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000008b', '11111111-0000-0000-0000-000000000005', '400000100138', 'Bio Vollkorn Spaghetti 500g', 'Eigenmarke', 500, 'g', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000008c', '11111111-0000-0000-0000-000000000005', '400000100139', 'Barilla Spaghetti No. 5 500g', 'Barilla', 500, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000008d', '11111111-0000-0000-0000-000000000005', '400000100140', 'Barilla Penne Rigate 500g', 'Barilla', 500, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000008e', '11111111-0000-0000-0000-000000000005', '400000100141', 'Basmati Reis 1kg', 'Eigenmarke', 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000008f', '11111111-0000-0000-0000-000000000005', '400000100142', 'Jasmin Duftreis 1kg', 'Eigenmarke', 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000090', '11111111-0000-0000-0000-000000000005', '400000100143', 'Parboiled Spitzenlangkornreis 1kg', 'Eigenmarke', 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000091', '11111111-0000-0000-0000-000000000005', '400000100144', 'Passierte Tomaten 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000092', '11111111-0000-0000-0000-000000000005', '400000100145', 'Gehackte Tomaten Dose 400g', 'Eigenmarke', 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000093', '11111111-0000-0000-0000-000000000005', '400000100146', 'Mutti Polpa stückige Tomaten 400g', 'Mutti', 400, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000094', '11111111-0000-0000-0000-000000000005', '400000100147', 'Tomatenmark dreifach konzentriert 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000095', '11111111-0000-0000-0000-000000000005', '400000100148', 'Pesto Genovese grün 190g', 'Eigenmarke', 190, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000096', '11111111-0000-0000-0000-000000000005', '400000100149', 'Pesto Rosso rot 190g', 'Eigenmarke', 190, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000097', '11111111-0000-0000-0000-000000000005', '400000100150', 'Barilla Pesto Alla Genovese 190g', 'Barilla', 190, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000098', '11111111-0000-0000-0000-000000000005', '400000100151', 'Kidneybohnen Dose 400g', 'Eigenmarke', 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000099', '11111111-0000-0000-0000-000000000005', '400000100152', 'Kichererbsen Dose 400g', 'Eigenmarke', 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000009a', '11111111-0000-0000-0000-000000000005', '400000100153', 'Mais süß Dose 330g', 'Eigenmarke', 330, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000009b', '11111111-0000-0000-0000-000000000005', '400000100154', 'Grüne Erbsen mit Möhren 400g', 'Eigenmarke', 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000009c', '11111111-0000-0000-0000-000000000005', '400000100155', 'Natives Olivenöl Extra 750ml', 'Eigenmarke', 750, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000009d', '11111111-0000-0000-0000-000000000005', '400000100156', 'Bio Olivenöl Extra 500ml', 'Eigenmarke', 500, 'ml', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000009e', '11111111-0000-0000-0000-000000000005', '400000100157', 'Rapsöl raffiniert 1L', 'Eigenmarke', 1, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000009f', '11111111-0000-0000-0000-000000000005', '400000100158', 'Sonnenblumenöl 1L', 'Eigenmarke', 1, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000a0', '11111111-0000-0000-0000-000000000005', '400000100159', 'Balsamico Essig di Modena 500ml', 'Eigenmarke', 500, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000a1', '11111111-0000-0000-0000-000000000005', '400000100160', 'Apfelessig 750ml', 'Eigenmarke', 750, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000a2', '11111111-0000-0000-0000-000000000005', '400000100161', 'Jodsalz mit Fluorid 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000a3', '11111111-0000-0000-0000-000000000005', '400000100162', 'Schwarzer Pfeffer gemahlen 50g', 'Eigenmarke', 50, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000a4', '11111111-0000-0000-0000-000000000005', '400000100163', 'Paprikapulver edelsüß 50g', 'Eigenmarke', 50, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000a5', '11111111-0000-0000-0000-000000000005', '400000100164', 'Gemüsebrühe Glas 140g', 'Eigenmarke', 140, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000a6', '11111111-0000-0000-0000-000000000005', '400000100165', 'Mittelscharfer Senf 200ml', 'Eigenmarke', 200, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000a7', '11111111-0000-0000-0000-000000000005', '400000100166', 'Bautz’ner Senf mittelscharf 200ml', 'Bautzner', 200, 'ml', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000a8', '11111111-0000-0000-0000-000000000005', '400000100167', 'Tomaten Ketchup 500ml', 'Eigenmarke', 500, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000a9', '11111111-0000-0000-0000-000000000005', '400000100168', 'Heinz Tomato Ketchup 500ml', 'Heinz', 500, 'ml', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000aa', '11111111-0000-0000-0000-000000000005', '400000100169', 'Delikatess Mayonnaise 500ml', 'Eigenmarke', 500, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ab', '11111111-0000-0000-0000-000000000005', '400000100170', 'Miracel Whip Original 500ml', 'Miracel Whip', 500, 'ml', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ac', '11111111-0000-0000-0000-000000000005', '400000100171', 'Blütenhonig flüssig 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ad', '11111111-0000-0000-0000-000000000005', '400000100172', 'Erdbeerkonfitüre Extra 450g', 'Eigenmarke', 450, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ae', '11111111-0000-0000-0000-000000000005', '400000100173', 'Nutella Nuss-Nougat-Creme 450g', 'Ferrero', 450, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000af', '11111111-0000-0000-0000-000000000005', '400000100174', 'Nuss-Nougat-Creme 400g', 'Eigenmarke', 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000b0', '11111111-0000-0000-0000-000000000005', '400000100175', 'Erdnussbutter Creamy 350g', 'Eigenmarke', 350, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000b1', '11111111-0000-0000-0000-000000000005', '400000100176', 'Cornflakes 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000b2', '11111111-0000-0000-0000-000000000005', '400000100177', 'Früchtemüsli 1kg', 'Eigenmarke', 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000b3', '11111111-0000-0000-0000-000000000005', '400000100178', 'Schokomüsli 750g', 'Eigenmarke', 750, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000b4', '11111111-0000-0000-0000-000000000005', '400000100179', 'Dr. Oetker Ristorante Pizza Salame 320g', 'Dr. Oetker', 320, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000b5', '11111111-0000-0000-0000-000000000006', '400000100180', 'Vollmilchschokolade 100g', 'Eigenmarke', 100, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000b6', '11111111-0000-0000-0000-000000000006', '400000100181', 'Zartbitterschokolade 70% 100g', 'Eigenmarke', 100, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000b7', '11111111-0000-0000-0000-000000000006', '400000100182', 'Milka Alpenmilch Schokolade 100g', 'Milka', 100, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000b8', '11111111-0000-0000-0000-000000000006', '400000100183', 'Ritter Sport Alpenmilch 100g', 'Ritter Sport', 100, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000b9', '11111111-0000-0000-0000-000000000006', '400000100184', 'Haribo Goldbären 175g', 'Haribo', 175, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ba', '11111111-0000-0000-0000-000000000006', '400000100185', 'Fruchtgummi Bären 300g', 'Eigenmarke', 300, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000bb', '11111111-0000-0000-0000-000000000006', '400000100186', 'Kartoffelchips Paprika 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000bc', '11111111-0000-0000-0000-000000000006', '400000100187', 'Kartoffelchips Gesalzen 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000bd', '11111111-0000-0000-0000-000000000006', '400000100188', 'Funny-Frisch Chipsfrisch ungarisch 150g', 'Funny-Frisch', 150, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000be', '11111111-0000-0000-0000-000000000006', '400000100189', 'Pringles Original 185g', 'Pringles', 185, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000bf', '11111111-0000-0000-0000-000000000006', '400000100190', 'Salzstangen 250g', 'Eigenmarke', 250, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000c0', '11111111-0000-0000-0000-000000000006', '400000100191', 'Erdnussflips 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000c1', '11111111-0000-0000-0000-000000000006', '400000100192', 'Erdnüsse geröstet & gesalzen 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000c2', '11111111-0000-0000-0000-000000000006', '400000100193', 'Studentenfutter 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000c3', '11111111-0000-0000-0000-000000000006', '400000100194', 'Mandeln naturbelassen 200g', 'Eigenmarke', 200, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000c4', '11111111-0000-0000-0000-000000000006', '400000100195', 'Cashewkerne geröstet & gesalzen 150g', 'Eigenmarke', 150, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000c5', '11111111-0000-0000-0000-000000000006', '400000100196', 'Butterkeks 400g', 'Eigenmarke', 400, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000c6', '11111111-0000-0000-0000-000000000006', '400000100197', 'Leibniz Butterkeks 200g', 'Leibniz', 200, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000c7', '11111111-0000-0000-0000-000000000006', '400000100198', 'Doppelkeks mit Kakaocreme 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000c8', '11111111-0000-0000-0000-000000000006', '400000100199', 'Prinzen Rolle Schoko 400g', 'DeBeukelaer', 400, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000c9', '11111111-0000-0000-0000-000000000006', '400000100200', 'Knoppers 8er 200g', 'Storck', 200, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ca', '11111111-0000-0000-0000-000000000006', '400000100201', 'Hanuta 10er 220g', 'Ferrero', 220, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000cb', '11111111-0000-0000-0000-000000000006', '400000100202', 'Duplo 10er 182g', 'Ferrero', 182, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000cc', '11111111-0000-0000-0000-000000000006', '400000100203', 'Kinder Riegel 10er 210g', 'Ferrero', 210, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000cd', '11111111-0000-0000-0000-000000000006', '400000100204', 'M&Ms Peanut 220g', 'Mars', 220, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ce', '11111111-0000-0000-0000-000000000007', '400000100205', 'Mineralwasser Medium 1,5L', 'Eigenmarke', 1.5, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000cf', '11111111-0000-0000-0000-000000000007', '400000100206', 'Mineralwasser Still 1,5L', 'Eigenmarke', 1.5, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000d0', '11111111-0000-0000-0000-000000000007', '400000100207', 'Mineralwasser Classic mit Sprudel 1,5L', 'Eigenmarke', 1.5, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000d1', '11111111-0000-0000-0000-000000000007', '400000100208', 'Gerolsteiner Medium 1L', 'Gerolsteiner', 1, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000d2', '11111111-0000-0000-0000-000000000007', '400000100209', 'Volvic Natürliches Mineralwasser 1,5L', 'Volvic', 1.5, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000d3', '11111111-0000-0000-0000-000000000007', '400000100210', 'Apfelsaft naturtrüb 100% 1L', 'Eigenmarke', 1, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000d4', '11111111-0000-0000-0000-000000000007', '400000100211', 'Apfelschorle 1,5L', 'Eigenmarke', 1.5, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000d5', '11111111-0000-0000-0000-000000000007', '400000100212', 'Orangensaft 100% Direktsaft 1L', 'Eigenmarke', 1, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000d6', '11111111-0000-0000-0000-000000000007', '400000100213', 'Hohes C Orange 1L', 'Hohes C', 1, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000d7', '11111111-0000-0000-0000-000000000007', '400000100214', 'Multivitaminsaft 1,5L', 'Eigenmarke', 1.5, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000d8', '11111111-0000-0000-0000-000000000007', '400000100215', 'Cola 1,5L', 'Eigenmarke', 1.5, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000d9', '11111111-0000-0000-0000-000000000007', '400000100216', 'Cola Zero 1,5L', 'Eigenmarke', 1.5, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000da', '11111111-0000-0000-0000-000000000007', '400000100217', 'Coca-Cola Original 1,5L', 'Coca-Cola', 1.5, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000db', '11111111-0000-0000-0000-000000000007', '400000100218', 'Coca-Cola Zero Sugar 1,5L', 'Coca-Cola', 1.5, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000dc', '11111111-0000-0000-0000-000000000007', '400000100219', 'Fanta Orange 1,5L', 'Fanta', 1.5, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000dd', '11111111-0000-0000-0000-000000000007', '400000100220', 'Sprite 1,5L', 'Sprite', 1.5, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000de', '11111111-0000-0000-0000-000000000007', '400000100221', 'Eistee Pfirsich 1,5L', 'Eigenmarke', 1.5, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000df', '11111111-0000-0000-0000-000000000007', '400000100222', 'Eistee Zitrone 1,5L', 'Eigenmarke', 1.5, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000e0', '11111111-0000-0000-0000-000000000007', '400000100223', 'Energy Drink Original 250ml', 'Eigenmarke', 250, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000e1', '11111111-0000-0000-0000-000000000007', '400000100224', 'Red Bull Energy Drink 250ml', 'Red Bull', 250, 'ml', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000e2', '11111111-0000-0000-0000-000000000007', '400000100225', 'Kaffee Ganze Bohnen Crema 1kg', 'Eigenmarke', 1, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000e3', '11111111-0000-0000-0000-000000000007', '400000100226', 'Bio Espresso Ganze Bohnen 1kg', 'Eigenmarke', 1, 'kg', true, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000e4', '11111111-0000-0000-0000-000000000007', '400000100227', 'Lavazza Caffè Crema Bohnen 1kg', 'Lavazza', 1, 'kg', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000e5', '11111111-0000-0000-0000-000000000007', '400000100228', 'Filterkaffee gemahlen Röstfein 500g', 'Eigenmarke', 500, 'g', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000e6', '11111111-0000-0000-0000-000000000007', '400000100229', 'Jacobs Krönung gemahlen 500g', 'Jacobs', 500, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000e7', '11111111-0000-0000-0000-000000000007', '400000100230', 'Tchibo Feine Milde gemahlen 500g', 'Tchibo', 500, 'g', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000e8', '11111111-0000-0000-0000-000000000007', '400000100231', 'Kaffeepads Crema 20er', 'Eigenmarke', 20, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000e9', '11111111-0000-0000-0000-000000000007', '400000100232', 'Schwarzer Tee Ceylon-Assam 50 Beutel', 'Eigenmarke', 50, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ea', '11111111-0000-0000-0000-000000000007', '400000100233', 'Kamillentee 25 Beutel', 'Eigenmarke', 25, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000eb', '11111111-0000-0000-0000-000000000007', '400000100234', 'Pfefferminztee 25 Beutel', 'Eigenmarke', 25, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ec', '11111111-0000-0000-0000-000000000007', '400000100235', 'Früchtetee Waldbeere 25 Beutel', 'Eigenmarke', 25, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ed', '11111111-0000-0000-0000-000000000007', '400000100236', 'Teekanne Kamille 20 Beutel', 'Teekanne', 20, 'piece', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ee', '11111111-0000-0000-0000-000000000007', '400000100237', 'Pilsener Bier 0,5L Dose', 'Eigenmarke', 0.5, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ef', '11111111-0000-0000-0000-000000000007', '400000100238', 'Krombacher Pils 0,5L Flasche', 'Krombacher', 0.5, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000f0', '11111111-0000-0000-0000-000000000007', '400000100239', 'Bitburger Premium Pils 0,5L Flasche', 'Bitburger', 0.5, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000f1', '11111111-0000-0000-0000-000000000008', '400000100240', 'Toilettenpapier 3-lagig 8x200 Blatt', 'Eigenmarke', 8, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000f2', '11111111-0000-0000-0000-000000000008', '400000100241', 'Toilettenpapier 4-lagig 8x150 Blatt', 'Eigenmarke', 8, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000f3', '11111111-0000-0000-0000-000000000008', '400000100242', 'Küchenrolle 3-lagig 4x51 Blatt', 'Eigenmarke', 4, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000f4', '11111111-0000-0000-0000-000000000008', '400000100243', 'Papiertaschentücher Box 100er', 'Eigenmarke', 100, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000f5', '11111111-0000-0000-0000-000000000008', '400000100244', 'Papiertaschentücher 30x10 Stück', 'Eigenmarke', 30, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000f6', '11111111-0000-0000-0000-000000000008', '400000100245', 'Tempo Taschentücher 30x10er', 'Tempo', 30, 'piece', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000f7', '11111111-0000-0000-0000-000000000008', '400000100246', 'Geschirrspülmittel Ultra 500ml', 'Eigenmarke', 500, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000f8', '11111111-0000-0000-0000-000000000008', '400000100247', 'Pril Original Spülmittel 675ml', 'Pril', 675, 'ml', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000f9', '11111111-0000-0000-0000-000000000008', '400000100248', 'Spülmaschinentabs All-in-1 40 Stück', 'Eigenmarke', 40, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000fa', '11111111-0000-0000-0000-000000000008', '400000100249', 'Somat Gold Spülmaschinentabs 40 Stück', 'Somat', 40, 'piece', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000fb', '11111111-0000-0000-0000-000000000008', '400000100250', 'Spezialsalz Spülmaschine 2kg', 'Eigenmarke', 2, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000fc', '11111111-0000-0000-0000-000000000008', '400000100251', 'Klarspüler Spülmaschine 1L', 'Eigenmarke', 1, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000fd', '11111111-0000-0000-0000-000000000008', '400000100252', 'Allzweckreiniger Frischeduft 1L', 'Eigenmarke', 1, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000fe', '11111111-0000-0000-0000-000000000008', '400000100253', 'Meister Proper Allzweckreiniger 1L', 'Meister Proper', 1, 'l', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-0000000000ff', '11111111-0000-0000-0000-000000000008', '400000100254', 'Badreiniger Spray 750ml', 'Eigenmarke', 750, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000100', '11111111-0000-0000-0000-000000000008', '400000100255', 'WC-Reinigungsgel 750ml', 'Eigenmarke', 750, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000101', '11111111-0000-0000-0000-000000000008', '400000100256', 'Colorwaschmittel flüssig 20 WL', 'Eigenmarke', 1.5, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000102', '11111111-0000-0000-0000-000000000008', '400000100257', 'Vollwaschmittel Pulver 20 WL', 'Eigenmarke', 1.35, 'kg', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000103', '11111111-0000-0000-0000-000000000008', '400000100258', 'Ariel Vollwaschmittel Pulver 80 WL', 'Ariel', 5.2, 'kg', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000104', '11111111-0000-0000-0000-000000000008', '400000100259', 'Zahnpasta Kräuter 125ml', 'Eigenmarke', 125, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000105', '11111111-0000-0000-0000-000000000008', '400000100260', 'Colgate Total Original 75ml', 'Colgate', 75, 'ml', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000106', '11111111-0000-0000-0000-000000000008', '400000100261', 'Zahnbürsten Mittel 2er', 'Eigenmarke', 2, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000107', '11111111-0000-0000-0000-000000000008', '400000100262', 'Duschgel Men Fresh 300ml', 'Eigenmarke', 300, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000108', '11111111-0000-0000-0000-000000000008', '400000100263', 'Duschgel Mandelmilch 300ml', 'Eigenmarke', 300, 'ml', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-000000000109', '11111111-0000-0000-0000-000000000008', '400000100264', 'Nivea Pflegedusche Creme Soft 250ml', 'Nivea', 250, 'ml', false, false)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000010a', '11111111-0000-0000-0000-000000000008', '400000100265', 'Flüssigseife Nachfüllbeutel 1L', 'Eigenmarke', 1, 'l', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000010b', '11111111-0000-0000-0000-000000000008', '400000100266', 'Müllbeutel mit Zugband 35L 30er', 'Eigenmarke', 30, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000010c', '11111111-0000-0000-0000-000000000008', '400000100267', 'Müllbeutel mit Zugband 60L 20er', 'Eigenmarke', 20, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000010d', '11111111-0000-0000-0000-000000000008', '400000100268', 'Alufolie 30m', 'Eigenmarke', 1, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO public.products (id, category_id, gtin_barcode, name, brand, quantity_amount, quantity_unit, is_bio, is_private_label)
VALUES ('22222222-0000-0000-0000-00000000010e', '11111111-0000-0000-0000-000000000008', '400000100269', 'Backpapier Zuschnitte 30 Bögen', 'Eigenmarke', 30, 'piece', false, true)
ON CONFLICT (id) DO NOTHING;

-- 3. Insert Product Aliases
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000001', 'banane', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000001', 'bananen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000002', 'bio banane', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000002', 'bananen bio', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000003', 'apfel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000003', 'äpfel', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000003', 'gala', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000004', 'bio äpfel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000004', 'bio apfel', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000005', 'salatgurke', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000005', 'gurke', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000006', 'bio gurke', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000007', 'tomate', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000007', 'tomaten', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000007', 'rispentomate', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000008', 'cherrytomaten', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000008', 'kirschtomaten', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000009', 'bio tomaten', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000009', 'bio cherrytomaten', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000000a', 'kartoffeln', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000000a', 'erdäpfel', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000000b', 'bio kartoffeln', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000000c', 'zwiebel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000000c', 'zwiebeln', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000000d', 'rote zwiebeln', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000000e', 'möhren', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000000e', 'karotten', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000000e', 'rübli', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000000f', 'bio möhren', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000000f', 'bio karotten', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000010', 'paprika', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000010', 'paprika rot gelb grün', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000011', 'spitzpaprika', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000012', 'salat', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000012', 'eisbergsalat', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000013', 'kopfsalat', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000014', 'rucola', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000014', 'rauhe rauke', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000015', 'spinat', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000015', 'babyspinat', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000016', 'zucchini', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000017', 'aubergine', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000018', 'brokkoli', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000018', 'broccoli', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000019', 'blumenkohl', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000001a', 'pilze', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000001a', 'champignons', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000001a', 'braune champignons', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000001b', 'weiße champignons', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000001c', 'avocado', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000001d', 'bio avocado', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000001e', 'blaubeeren', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000001e', 'heidelbeeren', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000001f', 'erdbeeren', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000020', 'zitrone', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000020', 'zitronen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000021', 'bio zitrone', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000021', 'bio zitronen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000022', 'knoblauch', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000023', 'ingwer', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000024', 'skyr', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000024', 'skyr natur', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000025', 'skyr vanille', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000026', 'isey skyr', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000027', 'vollmilch', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000027', 'milch 3.5', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000027', 'milch', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000028', 'h milch 3.5', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000028', 'h-milch', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000029', 'milch 1.5', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000029', 'fettarme milch', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000002a', 'h milch 1.5', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000002b', 'bio milch', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000002b', 'bio vollmilch', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000002c', 'bärenmarke milch', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000002d', 'butter', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000002d', 'markenbutter', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000002e', 'bio butter', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000002f', 'kerrygold', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000002f', 'irische butter', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000030', 'magerquark', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000030', 'quark', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000031', 'speisequark', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000031', 'quark 20%', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000032', 'bio magerquark', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000032', 'bio quark', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000033', 'joghurt natur', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000033', 'naturjoghurt', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000034', 'griechischer joghurt', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000034', 'joghurt 10%', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000035', 'grand dessert', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000035', 'schokopudding', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000036', 'schmand', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000037', 'saure sahne', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000038', 'sahne', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000038', 'schlagsahne', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000039', 'creme fraiche', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000003a', 'gouda', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000003a', 'käse scheiben', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000003b', 'gouda mittelalt', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000003c', 'butterkäse', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000003d', 'reibekäse', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000003d', 'emmentaler', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000003e', 'gouda gerieben', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000003e', 'streukäse', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000003f', 'mozzarella', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000040', 'bio mozzarella', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000041', 'galbani mozzarella', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000042', 'hirtenkäse', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000042', 'weichkäse', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000043', 'feta', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000043', 'schafskäse', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000044', 'frischkäse', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000045', 'philadelphia', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000046', 'camembert', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000047', 'parmesan', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000047', 'parmigiano', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000048', 'eier', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000048', '10 eier', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000048', 'hühnereier', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000049', 'freilandeier', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000004a', 'bio eier', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000004b', 'oatly', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000004b', 'hafermilch barista', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000004c', 'hafermilch', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000004c', 'haferdrink', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000004d', 'sojamilch', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000004d', 'sojadrink', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000004e', 'milchreis', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000004e', 'müller milchreis', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000004f', 'zott joghurt', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000004f', 'sahnejoghurt', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000050', 'activia', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000051', 'toast', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000051', 'toastbrot', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000051', 'buttertoast', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000052', 'vollkorntoast', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000053', 'golden toast', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000054', 'brot', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000054', 'mischbrot', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000054', 'weizenbrot', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000055', 'vollkornbrot', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000056', 'landbrot', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000056', 'graubrot', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000057', 'sonnenblumenbrot', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000058', 'baguette', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000058', 'aufbackbaguette', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000059', 'kräuterbaguette', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000059', 'knoblauchbaguette', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000005a', 'brötchen', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000005a', 'aufbackbrötchen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000005a', 'semmeln', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000005b', 'körnerbrötchen', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000005b', 'mehrkornbrötchen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000005c', 'knäckebrot', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000005d', 'wasa', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000005e', 'wraps', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000005e', 'tortillas', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000005f', 'pizzateig', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000005f', 'frischer pizzateig', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000060', 'haferflocken', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000060', 'haferflocken zart', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000061', 'haferflocken kernig', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000062', 'bio haferflocken', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000063', 'kölln flocken', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000064', 'mehl', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000064', 'weizenmehl', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000064', 'mehl 405', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000065', 'dinkelmehl', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000065', 'bio mehl', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000066', 'zucker', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000066', 'kristallzucker', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000067', 'puderzucker', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000068', 'backpulver', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000069', 'hefe', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000069', 'frische hefe', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000006a', 'hackfleisch', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000006a', 'hack', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000006a', 'gemischtes hack', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000006b', 'rinderhack', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000006c', 'bio hackfleisch', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000006c', 'bio rinderhack', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000006d', 'hähnchenbrust', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000006d', 'hähnchen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000006d', 'hühnchen', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000006e', 'hähnchenfilet', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000006f', 'bio hähnchen', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000070', 'putenschnitzel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000070', 'pute', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000071', 'bratwurst', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000072', 'wiener', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000072', 'würstchen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000073', 'kochschinken', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000073', 'schinken', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000074', 'mortadella', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000074', 'geflügelwurst', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000075', 'salami', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000076', 'lachsschinken', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000077', 'bacon', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000077', 'speck', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000078', 'schinkenwürfel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000079', 'lachs', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000079', 'lachsfilet', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000007a', 'räucherlachs', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000007b', 'thunfisch', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000007b', 'dose thunfisch', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000007c', 'thunfisch öl', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000007d', 'fischstäbchen', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000007d', 'iglo fischstäbchen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000007e', 'fischstäbchen günstig', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000007f', 'tofu', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000007f', 'bio tofu', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000080', 'räuchertofu', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000081', 'vegane salami', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000081', 'mühlen salami', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000082', 'vegane bratwurst', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000083', 'veganes hack', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000083', 'veggie hack', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000084', 'veggie burger', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000084', 'veganer burger', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000085', 'vegane nuggets', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000086', 'falafel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000087', 'hummus', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000088', 'spaghetti', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000088', 'nudeln', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000089', 'penne', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000089', 'röhrennudeln', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000008a', 'fusilli', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000008a', 'spirelli', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000008b', 'vollkornnudeln', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000008b', 'bio spaghetti', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000008c', 'barilla spaghetti', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000008c', 'barilla', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000008d', 'barilla penne', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000008e', 'reis', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000008e', 'basmati', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000008e', 'basmatireis', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000008f', 'jasminreis', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000090', 'langkornreis', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000090', 'parboiled reis', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000091', 'passierte tomaten', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000091', 'passata', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000092', 'gehackte tomaten', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000092', 'dosentomaten', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000092', 'stückige tomaten', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000093', 'mutti tomaten', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000093', 'mutti polpa', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000094', 'tomatenmark', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000095', 'pesto', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000095', 'grünes pesto', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000095', 'pesto genovese', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000096', 'rotes pesto', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000096', 'pesto rosso', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000097', 'barilla pesto', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000098', 'kidneybohnen', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000098', 'bohnen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000099', 'kichererbsen', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000009a', 'mais', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000009a', 'dosenmais', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000009b', 'erbsen möhren', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000009c', 'olivenöl', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000009c', 'natives olivenöl', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000009d', 'bio olivenöl', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000009e', 'rapsöl', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000009e', 'speiseöl', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000009f', 'sonnenblumenöl', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a0', 'essig', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a0', 'balsamico', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a1', 'apfelessig', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a2', 'salz', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a2', 'speisesalz', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a2', 'jodsalz', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a3', 'pfeffer', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a3', 'schwarzer pfeffer', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a4', 'paprikapulver', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a5', 'brühe', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a5', 'gemüsebrühe', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a6', 'senf', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a7', 'bautzner senf', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a8', 'ketchup', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000a9', 'heinz ketchup', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000aa', 'mayo', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000aa', 'mayonnaise', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ab', 'miracel whip', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ac', 'honig', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ac', 'blütenhonig', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ad', 'marmelade', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ad', 'erdbeermarmelade', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ad', 'konfitüre', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ae', 'nutella', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ae', 'nuss nougat creme', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000af', 'schokocreme', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b0', 'erdnussbutter', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b0', 'peanut butter', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b1', 'cornflakes', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b2', 'müsli', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b2', 'früchtemüsli', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b3', 'schokomüsli', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b4', 'tiefkühlpizza', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b4', 'ristorante', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b4', 'pizza salami', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b5', 'schokolade', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b5', 'vollmilch schokolade', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b6', 'zartbitterschokolade', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b6', 'dunkle schokolade', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b7', 'milka', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b7', 'milka alpenmilch', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b8', 'ritter sport', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b9', 'gummibärchen', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b9', 'haribo', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000b9', 'goldbären', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ba', 'fruchtgummi', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000bb', 'chips', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000bb', 'paprika chips', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000bc', 'salzchips', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000bd', 'funny frisch', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000bd', 'chipsfrisch', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000be', 'pringles', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000bf', 'salzstangen', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c0', 'flips', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c0', 'erdnussflips', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c1', 'erdnüsse', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c2', 'studentenfutter', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c2', 'nüsse rosinen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c3', 'mandeln', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c4', 'cashews', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c4', 'cashewkerne', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c5', 'kekse', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c5', 'butterkeks', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c6', 'leibniz', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c7', 'doppelkeks', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c7', 'prinzenrolle eigenmarke', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c8', 'prinzen rolle', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000c9', 'knoppers', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ca', 'hanuta', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000cb', 'duplo', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000cc', 'kinder riegel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000cc', 'schokoriegel', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000cd', 'm&ms', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000cd', 'schokolinsen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ce', 'wasser medium', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ce', 'sprudelwasser', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ce', 'mineralwasser', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000cf', 'stilles wasser', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000cf', 'wasser still', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d0', 'sprudel classic', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d1', 'gerolsteiner', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d2', 'volvic', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d3', 'apfelsaft naturtrüb', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d3', 'apfelsaft', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d4', 'apfelschorle', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d5', 'orangensaft', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d5', 'o saft', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d5', 'direktsaft', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d6', 'hohes c', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d7', 'multivitaminsaft', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d7', 'multisaft', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d8', 'cola', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d8', 'cola eigenmarke', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000d9', 'cola zero eigenmarke', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000da', 'coca cola', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000da', 'coke', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000db', 'coca cola zero', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000db', 'coke zero', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000dc', 'fanta', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000dd', 'sprite', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000de', 'eistee', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000de', 'eistee pfirsich', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000df', 'eistee zitrone', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e0', 'energy drink', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e1', 'red bull', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e2', 'kaffeebohnen', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e2', 'kaffee bohnen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e2', 'caffe crema', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e3', 'espresso bohnen', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e3', 'bio kaffee', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e4', 'lavazza', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e4', 'lavazza bohnen', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e5', 'filterkaffee', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e5', 'kaffee pulver', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e6', 'jacobs krönung', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e6', 'jacobs kaffee', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e7', 'tchibo', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e7', 'feine milde', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e8', 'kaffeepads', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e8', 'pads', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e9', 'schwarzer tee', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000e9', 'tee', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ea', 'kamillentee', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000eb', 'pfefferminztee', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000eb', 'minztee', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ec', 'früchtetee', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ed', 'teekanne', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ee', 'bier dose', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ee', 'pils dose', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ef', 'krombacher', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ef', 'pils', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f0', 'bitburger', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f0', 'bier', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f1', 'klopapier', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f1', 'toilettenpapier', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f2', 'klopapier 4 lagig', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f3', 'küchenrolle', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f3', 'küchenpapier', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f3', 'zewa', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f4', 'taschentücher box', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f4', 'kosmetiktücher', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f5', 'taschentücher', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f5', 'tempo eigenmarke', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f6', 'tempo', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f7', 'spüli', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f7', 'spülmittel', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f8', 'pril', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f9', 'spülmaschinentabs', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000f9', 'tabs spülmaschine', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000fa', 'somat tabs', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000fb', 'spülmaschinensalz', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000fc', 'klarspüler', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000fd', 'allzweckreiniger', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000fd', 'putzmittel', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000fe', 'meister proper', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-0000000000ff', 'badreiniger', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000100', 'wc reiniger', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000100', 'kloreiniger', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000101', 'waschmittel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000101', 'colorwaschmittel', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000102', 'vollwaschmittel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000102', 'waschpulver', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000103', 'ariel waschmittel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000104', 'zahnpasta', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000104', 'zahncreme', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000105', 'colgate', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000106', 'zahnbürste', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000106', 'zahnbürsten', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000107', 'duschgel men', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000107', 'duschgel', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000108', 'duschgel pflege', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000109', 'nivea duschgel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-000000000109', 'nivea', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000010a', 'seife', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000010a', 'flüssigseife', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000010a', 'handseife', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000010b', 'müllbeutel', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000010b', 'mülltüten', 9);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000010b', 'müllbeutel 35l', 8);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000010c', 'müllbeutel 60l', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000010d', 'alufolie', 10);
INSERT INTO public.product_aliases (product_id, alias, priority) VALUES ('22222222-0000-0000-0000-00000000010e', 'backpapier', 10);

-- 4. Insert Default Chain Prices
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000001', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000001', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000001', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000001', 'rewe', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000001', 'netto', 134, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000002', 'lidl', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000002', 'aldi_sued', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000002', 'aldi_nord', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000002', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000002', 'netto', 161, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000003', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000003', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000003', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000003', 'rewe', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000003', 'netto', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000004', 'lidl', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000004', 'aldi_sued', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000004', 'aldi_nord', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000004', 'rewe', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000004', 'netto', 224, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000005', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000005', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000005', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000005', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000005', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000006', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000006', 'aldi_sued', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000006', 'aldi_nord', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000006', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000006', 'netto', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000007', 'lidl', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000007', 'aldi_sued', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000007', 'aldi_nord', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000007', 'rewe', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000007', 'netto', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000008', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000008', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000008', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000008', 'rewe', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000008', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000009', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000009', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000009', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000009', 'rewe', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000009', 'netto', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000a', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000a', 'aldi_sued', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000a', 'aldi_nord', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000a', 'rewe', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000a', 'netto', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000b', 'lidl', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000b', 'aldi_sued', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000b', 'aldi_nord', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000b', 'rewe', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000b', 'netto', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000c', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000c', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000c', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000c', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000c', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000d', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000d', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000d', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000d', 'rewe', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000d', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000e', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000e', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000e', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000e', 'rewe', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000e', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000f', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000f', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000f', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000f', 'rewe', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000000f', 'netto', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000010', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000010', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000010', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000010', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000010', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000011', 'lidl', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000011', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000011', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000011', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000011', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000012', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000012', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000012', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000012', 'rewe', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000012', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000013', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000013', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000013', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000013', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000013', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000014', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000014', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000014', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000014', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000014', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000015', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000015', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000015', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000015', 'rewe', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000015', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000016', 'lidl', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000016', 'aldi_sued', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000016', 'aldi_nord', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000016', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000016', 'netto', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000017', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000017', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000017', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000017', 'rewe', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000017', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000018', 'lidl', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000018', 'aldi_sued', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000018', 'aldi_nord', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000018', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000018', 'netto', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000019', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000019', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000019', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000019', 'rewe', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000019', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001a', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001a', 'aldi_sued', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001a', 'aldi_nord', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001a', 'rewe', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001a', 'netto', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001b', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001b', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001b', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001b', 'rewe', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001b', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001c', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001c', 'aldi_sued', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001c', 'aldi_nord', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001c', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001c', 'netto', 98, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001d', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001d', 'aldi_sued', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001d', 'aldi_nord', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001d', 'rewe', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001d', 'netto', 206, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001e', 'lidl', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001e', 'aldi_sued', 289, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001e', 'aldi_nord', 289, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001e', 'rewe', 349, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001e', 'netto', 260, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001f', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001f', 'aldi_sued', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001f', 'aldi_nord', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001f', 'rewe', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000001f', 'netto', 224, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000020', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000020', 'aldi_sued', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000020', 'aldi_nord', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000020', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000020', 'netto', 98, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000021', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000021', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000021', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000021', 'rewe', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000021', 'netto', 125, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000022', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000022', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000022', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000022', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000022', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000023', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000023', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000023', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000023', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000023', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000024', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000024', 'aldi_sued', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000024', 'aldi_nord', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000024', 'rewe', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000024', 'netto', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000025', 'lidl', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000025', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000025', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000025', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000025', 'netto', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000026', 'lidl', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000026', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000026', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000026', 'rewe', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000026', 'netto', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000027', 'lidl', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000027', 'aldi_sued', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000027', 'aldi_nord', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000027', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000027', 'netto', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000028', 'lidl', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000028', 'aldi_sued', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000028', 'aldi_nord', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000028', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000028', 'netto', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000029', 'lidl', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000029', 'aldi_sued', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000029', 'aldi_nord', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000029', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000029', 'netto', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002a', 'lidl', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002a', 'aldi_sued', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002a', 'aldi_nord', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002a', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002a', 'netto', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002b', 'lidl', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002b', 'aldi_sued', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002b', 'aldi_nord', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002b', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002b', 'netto', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002c', 'lidl', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002c', 'aldi_sued', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002c', 'aldi_nord', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002c', 'rewe', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002c', 'netto', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002d', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002d', 'aldi_sued', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002d', 'aldi_nord', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002d', 'rewe', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002d', 'netto', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002e', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002e', 'aldi_sued', 239, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002e', 'aldi_nord', 239, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002e', 'rewe', 259, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002e', 'netto', 239, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002f', 'lidl', 239, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002f', 'aldi_sued', 259, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002f', 'aldi_nord', 259, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002f', 'rewe', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000002f', 'netto', 259, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000030', 'lidl', 135, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000030', 'aldi_sued', 135, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000030', 'aldi_nord', 135, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000030', 'rewe', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000030', 'netto', 135, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000031', 'lidl', 145, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000031', 'aldi_sued', 145, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000031', 'aldi_nord', 145, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000031', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000031', 'netto', 145, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000032', 'lidl', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000032', 'aldi_sued', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000032', 'aldi_nord', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000032', 'rewe', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000032', 'netto', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000033', 'lidl', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000033', 'aldi_sued', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000033', 'aldi_nord', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000033', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000033', 'netto', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000034', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000034', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000034', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000034', 'rewe', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000034', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000035', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000035', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000035', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000035', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000035', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000036', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000036', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000036', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000036', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000036', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000037', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000037', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000037', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000037', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000037', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000038', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000038', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000038', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000038', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000038', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000039', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000039', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000039', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000039', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000039', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003a', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003a', 'aldi_sued', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003a', 'aldi_nord', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003a', 'rewe', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003a', 'netto', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003b', 'lidl', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003b', 'aldi_sued', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003b', 'aldi_nord', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003b', 'rewe', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003b', 'netto', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003c', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003c', 'aldi_sued', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003c', 'aldi_nord', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003c', 'rewe', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003c', 'netto', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003d', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003d', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003d', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003d', 'rewe', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003d', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003e', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003e', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003e', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003e', 'rewe', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003e', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003f', 'lidl', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003f', 'aldi_sued', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003f', 'aldi_nord', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003f', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000003f', 'netto', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000040', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000040', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000040', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000040', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000040', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000041', 'lidl', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000041', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000041', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000041', 'rewe', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000041', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000042', 'lidl', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000042', 'aldi_sued', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000042', 'aldi_nord', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000042', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000042', 'netto', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000043', 'lidl', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000043', 'aldi_sued', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000043', 'aldi_nord', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000043', 'rewe', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000043', 'netto', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000044', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000044', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000044', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000044', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000044', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000045', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000045', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000045', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000045', 'rewe', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000045', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000046', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000046', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000046', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000046', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000046', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000047', 'lidl', 349, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000047', 'aldi_sued', 349, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000047', 'aldi_nord', 349, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000047', 'rewe', 379, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000047', 'netto', 349, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000048', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000048', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000048', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000048', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000048', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000049', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000049', 'aldi_sued', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000049', 'aldi_nord', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000049', 'rewe', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000049', 'netto', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004a', 'lidl', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004a', 'aldi_sued', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004a', 'aldi_nord', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004a', 'rewe', 349, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004a', 'netto', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004b', 'lidl', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004b', 'aldi_sued', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004b', 'aldi_nord', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004b', 'rewe', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004b', 'netto', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004c', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004c', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004c', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004c', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004c', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004d', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004d', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004d', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004d', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004d', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004e', 'lidl', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004e', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004e', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004e', 'rewe', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004e', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004f', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004f', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004f', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004f', 'rewe', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000004f', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000050', 'lidl', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000050', 'aldi_sued', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000050', 'aldi_nord', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000050', 'rewe', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000050', 'netto', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000051', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000051', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000051', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000051', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000051', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000052', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000052', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000052', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000052', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000052', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000053', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000053', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000053', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000053', 'rewe', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000053', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000054', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000054', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000054', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000054', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000054', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000055', 'lidl', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000055', 'aldi_sued', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000055', 'aldi_nord', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000055', 'rewe', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000055', 'netto', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000056', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000056', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000056', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000056', 'rewe', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000056', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000057', 'lidl', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000057', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000057', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000057', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000057', 'netto', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000058', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000058', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000058', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000058', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000058', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000059', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000059', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000059', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000059', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000059', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005a', 'lidl', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005a', 'aldi_sued', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005a', 'aldi_nord', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005a', 'rewe', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005a', 'netto', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005b', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005b', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005b', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005b', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005b', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005c', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005c', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005c', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005c', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005c', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005d', 'lidl', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005d', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005d', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005d', 'rewe', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005d', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005e', 'lidl', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005e', 'aldi_sued', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005e', 'aldi_nord', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005e', 'rewe', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005e', 'netto', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005f', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005f', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005f', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005f', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000005f', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000060', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000060', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000060', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000060', 'rewe', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000060', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000061', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000061', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000061', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000061', 'rewe', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000061', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000062', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000062', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000062', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000062', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000062', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000063', 'lidl', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000063', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000063', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000063', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000063', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000064', 'lidl', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000064', 'aldi_sued', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000064', 'aldi_nord', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000064', 'rewe', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000064', 'netto', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000065', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000065', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000065', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000065', 'rewe', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000065', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000066', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000066', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000066', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000066', 'rewe', 125, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000066', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000067', 'lidl', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000067', 'aldi_sued', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000067', 'aldi_nord', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000067', 'rewe', 55, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000067', 'netto', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000068', 'lidl', 45, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000068', 'aldi_sued', 45, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000068', 'aldi_nord', 45, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000068', 'rewe', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000068', 'netto', 45, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000069', 'lidl', 19, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000069', 'aldi_sued', 19, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000069', 'aldi_nord', 19, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000069', 'rewe', 25, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000069', 'netto', 19, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006a', 'lidl', 399, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006a', 'aldi_sued', 399, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006a', 'aldi_nord', 399, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006a', 'rewe', 429, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006a', 'netto', 399, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006b', 'lidl', 449, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006b', 'aldi_sued', 449, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006b', 'aldi_nord', 449, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006b', 'rewe', 479, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006b', 'netto', 449, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006c', 'lidl', 549, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006c', 'aldi_sued', 549, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006c', 'aldi_nord', 549, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006c', 'rewe', 599, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006c', 'netto', 549, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006d', 'lidl', 599, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006d', 'aldi_sued', 599, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006d', 'aldi_nord', 599, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006d', 'rewe', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006d', 'netto', 599, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006e', 'lidl', 429, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006e', 'aldi_sued', 429, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006e', 'aldi_nord', 429, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006e', 'rewe', 469, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006e', 'netto', 429, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006f', 'lidl', 699, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006f', 'aldi_sued', 699, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006f', 'aldi_nord', 699, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006f', 'rewe', 749, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000006f', 'netto', 699, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000070', 'lidl', 499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000070', 'aldi_sued', 499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000070', 'aldi_nord', 499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000070', 'rewe', 549, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000070', 'netto', 499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000071', 'lidl', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000071', 'aldi_sued', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000071', 'aldi_nord', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000071', 'rewe', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000071', 'netto', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000072', 'lidl', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000072', 'aldi_sued', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000072', 'aldi_nord', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000072', 'rewe', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000072', 'netto', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000073', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000073', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000073', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000073', 'rewe', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000073', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000074', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000074', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000074', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000074', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000074', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000075', 'lidl', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000075', 'aldi_sued', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000075', 'aldi_nord', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000075', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000075', 'netto', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000076', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000076', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000076', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000076', 'rewe', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000076', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000077', 'lidl', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000077', 'aldi_sued', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000077', 'aldi_nord', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000077', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000077', 'netto', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000078', 'lidl', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000078', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000078', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000078', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000078', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000079', 'lidl', 599, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000079', 'aldi_sued', 599, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000079', 'aldi_nord', 599, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000079', 'rewe', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000079', 'netto', 599, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007a', 'lidl', 399, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007a', 'aldi_sued', 399, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007a', 'aldi_nord', 399, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007a', 'rewe', 429, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007a', 'netto', 399, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007b', 'lidl', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007b', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007b', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007b', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007b', 'netto', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007c', 'lidl', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007c', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007c', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007c', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007c', 'netto', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007d', 'lidl', 389, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007d', 'aldi_sued', 399, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007d', 'aldi_nord', 399, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007d', 'rewe', 389, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007d', 'netto', 399, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007e', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007e', 'aldi_sued', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007e', 'aldi_nord', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007e', 'rewe', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007e', 'netto', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007f', 'lidl', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007f', 'aldi_sued', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007f', 'aldi_nord', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007f', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000007f', 'netto', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000080', 'lidl', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000080', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000080', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000080', 'rewe', 209, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000080', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000081', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000081', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000081', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000081', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000081', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000082', 'lidl', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000082', 'aldi_sued', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000082', 'aldi_nord', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000082', 'rewe', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000082', 'netto', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000083', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000083', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000083', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000083', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000083', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000084', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000084', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000084', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000084', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000084', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000085', 'lidl', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000085', 'aldi_sued', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000085', 'aldi_nord', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000085', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000085', 'netto', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000086', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000086', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000086', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000086', 'rewe', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000086', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000087', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000087', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000087', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000087', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000087', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000088', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000088', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000088', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000088', 'rewe', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000088', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000089', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000089', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000089', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000089', 'rewe', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000089', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008a', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008a', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008a', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008a', 'rewe', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008a', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008b', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008b', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008b', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008b', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008b', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008c', 'lidl', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008c', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008c', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008c', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008c', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008d', 'lidl', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008d', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008d', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008d', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008d', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008e', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008e', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008e', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008e', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008e', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008f', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008f', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008f', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008f', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000008f', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000090', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000090', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000090', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000090', 'rewe', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000090', 'netto', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000091', 'lidl', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000091', 'aldi_sued', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000091', 'aldi_nord', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000091', 'rewe', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000091', 'netto', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000092', 'lidl', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000092', 'aldi_sued', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000092', 'aldi_nord', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000092', 'rewe', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000092', 'netto', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000093', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000093', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000093', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000093', 'rewe', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000093', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000094', 'lidl', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000094', 'aldi_sued', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000094', 'aldi_nord', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000094', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000094', 'netto', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000095', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000095', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000095', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000095', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000095', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000096', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000096', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000096', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000096', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000096', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000097', 'lidl', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000097', 'aldi_sued', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000097', 'aldi_nord', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000097', 'rewe', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000097', 'netto', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000098', 'lidl', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000098', 'aldi_sued', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000098', 'aldi_nord', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000098', 'rewe', 75, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000098', 'netto', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000099', 'lidl', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000099', 'aldi_sued', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000099', 'aldi_nord', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000099', 'rewe', 75, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000099', 'netto', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009a', 'lidl', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009a', 'aldi_sued', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009a', 'aldi_nord', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009a', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009a', 'netto', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009b', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009b', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009b', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009b', 'rewe', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009b', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009c', 'lidl', 799, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009c', 'aldi_sued', 799, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009c', 'aldi_nord', 799, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009c', 'rewe', 849, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009c', 'netto', 799, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009d', 'lidl', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009d', 'aldi_sued', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009d', 'aldi_nord', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009d', 'rewe', 699, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009d', 'netto', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009e', 'lidl', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009e', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009e', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009e', 'rewe', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009e', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009f', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009f', 'aldi_sued', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009f', 'aldi_nord', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009f', 'rewe', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000009f', 'netto', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a0', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a0', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a0', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a0', 'rewe', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a0', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a1', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a1', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a1', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a1', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a1', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a2', 'lidl', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a2', 'aldi_sued', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a2', 'aldi_nord', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a2', 'rewe', 35, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a2', 'netto', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a3', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a3', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a3', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a3', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a3', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a4', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a4', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a4', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a4', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a4', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a5', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a5', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a5', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a5', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a5', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a6', 'lidl', 55, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a6', 'aldi_sued', 55, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a6', 'aldi_nord', 55, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a6', 'rewe', 59, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a6', 'netto', 55, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a7', 'lidl', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a7', 'aldi_sued', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a7', 'aldi_nord', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a7', 'rewe', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a7', 'netto', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a8', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a8', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a8', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a8', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a8', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a9', 'lidl', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a9', 'aldi_sued', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a9', 'aldi_nord', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a9', 'rewe', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000a9', 'netto', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000aa', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000aa', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000aa', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000aa', 'rewe', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000aa', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ab', 'lidl', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ab', 'aldi_sued', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ab', 'aldi_nord', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ab', 'rewe', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ab', 'netto', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ac', 'lidl', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ac', 'aldi_sued', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ac', 'aldi_nord', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ac', 'rewe', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ac', 'netto', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ad', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ad', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ad', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ad', 'rewe', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ad', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ae', 'lidl', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ae', 'aldi_sued', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ae', 'aldi_nord', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ae', 'rewe', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ae', 'netto', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000af', 'lidl', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000af', 'aldi_sued', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000af', 'aldi_nord', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000af', 'rewe', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000af', 'netto', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b0', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b0', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b0', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b0', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b0', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b1', 'lidl', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b1', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b1', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b1', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b1', 'netto', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b2', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b2', 'aldi_sued', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b2', 'aldi_nord', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b2', 'rewe', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b2', 'netto', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b3', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b3', 'aldi_sued', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b3', 'aldi_nord', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b3', 'rewe', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b3', 'netto', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b4', 'lidl', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b4', 'aldi_sued', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b4', 'aldi_nord', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b4', 'rewe', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b4', 'netto', 329, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b5', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b5', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b5', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b5', 'rewe', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b5', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b6', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b6', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b6', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b6', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b6', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b7', 'lidl', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b7', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b7', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b7', 'rewe', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b7', 'netto', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b8', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b8', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b8', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b8', 'rewe', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b8', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b9', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b9', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b9', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b9', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000b9', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ba', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ba', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ba', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ba', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ba', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bb', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bb', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bb', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bb', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bb', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bc', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bc', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bc', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bc', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bc', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bd', 'lidl', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bd', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bd', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bd', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bd', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000be', 'lidl', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000be', 'aldi_sued', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000be', 'aldi_nord', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000be', 'rewe', 299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000be', 'netto', 279, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bf', 'lidl', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bf', 'aldi_sued', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bf', 'aldi_nord', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bf', 'rewe', 69, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000bf', 'netto', 65, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c0', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c0', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c0', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c0', 'rewe', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c0', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c1', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c1', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c1', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c1', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c1', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c2', 'lidl', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c2', 'aldi_sued', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c2', 'aldi_nord', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c2', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c2', 'netto', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c3', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c3', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c3', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c3', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c3', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c4', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c4', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c4', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c4', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c4', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c5', 'lidl', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c5', 'aldi_sued', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c5', 'aldi_nord', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c5', 'rewe', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c5', 'netto', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c6', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c6', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c6', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c6', 'rewe', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c6', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c7', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c7', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c7', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c7', 'rewe', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c7', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c8', 'lidl', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c8', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c8', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c8', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c8', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c9', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c9', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c9', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c9', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000c9', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ca', 'lidl', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ca', 'aldi_sued', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ca', 'aldi_nord', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ca', 'rewe', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ca', 'netto', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cb', 'lidl', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cb', 'aldi_sued', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cb', 'aldi_nord', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cb', 'rewe', 239, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cb', 'netto', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cc', 'lidl', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cc', 'aldi_sued', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cc', 'aldi_nord', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cc', 'rewe', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cc', 'netto', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cd', 'lidl', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cd', 'aldi_sued', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cd', 'aldi_nord', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cd', 'rewe', 289, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cd', 'netto', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ce', 'lidl', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ce', 'aldi_sued', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ce', 'aldi_nord', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ce', 'rewe', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ce', 'netto', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cf', 'lidl', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cf', 'aldi_sued', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cf', 'aldi_nord', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cf', 'rewe', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000cf', 'netto', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d0', 'lidl', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d0', 'aldi_sued', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d0', 'aldi_nord', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d0', 'rewe', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d0', 'netto', 29, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d1', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d1', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d1', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d1', 'rewe', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d1', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d2', 'lidl', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d2', 'aldi_sued', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d2', 'aldi_nord', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d2', 'rewe', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d2', 'netto', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d3', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d3', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d3', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d3', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d3', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d4', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d4', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d4', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d4', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d4', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d5', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d5', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d5', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d5', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d5', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d6', 'lidl', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d6', 'aldi_sued', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d6', 'aldi_nord', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d6', 'rewe', 229, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d6', 'netto', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d7', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d7', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d7', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d7', 'rewe', 169, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d7', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d8', 'lidl', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d8', 'aldi_sued', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d8', 'aldi_nord', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d8', 'rewe', 55, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d8', 'netto', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d9', 'lidl', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d9', 'aldi_sued', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d9', 'aldi_nord', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d9', 'rewe', 55, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000d9', 'netto', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000da', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000da', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000da', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000da', 'rewe', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000da', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000db', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000db', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000db', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000db', 'rewe', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000db', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000dc', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000dc', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000dc', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000dc', 'rewe', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000dc', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000dd', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000dd', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000dd', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000dd', 'rewe', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000dd', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000de', 'lidl', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000de', 'aldi_sued', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000de', 'aldi_nord', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000de', 'rewe', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000de', 'netto', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000df', 'lidl', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000df', 'aldi_sued', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000df', 'aldi_nord', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000df', 'rewe', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000df', 'netto', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e0', 'lidl', 45, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e0', 'aldi_sued', 45, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e0', 'aldi_nord', 45, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e0', 'rewe', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e0', 'netto', 45, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e1', 'lidl', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e1', 'aldi_sued', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e1', 'aldi_nord', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e1', 'rewe', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e1', 'netto', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e2', 'lidl', 999, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e2', 'aldi_sued', 999, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e2', 'aldi_nord', 999, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e2', 'rewe', 1049, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e2', 'netto', 999, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e3', 'lidl', 1199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e3', 'aldi_sued', 1199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e3', 'aldi_nord', 1199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e3', 'rewe', 1299, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e3', 'netto', 1199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e4', 'lidl', 1499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e4', 'aldi_sued', 1499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e4', 'aldi_nord', 1499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e4', 'rewe', 1599, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e4', 'netto', 1499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e5', 'lidl', 499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e5', 'aldi_sued', 499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e5', 'aldi_nord', 499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e5', 'rewe', 529, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e5', 'netto', 499, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e6', 'lidl', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e6', 'aldi_sued', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e6', 'aldi_nord', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e6', 'rewe', 699, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e6', 'netto', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e7', 'lidl', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e7', 'aldi_sued', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e7', 'aldi_nord', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e7', 'rewe', 699, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e7', 'netto', 649, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e8', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e8', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e8', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e8', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e8', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e9', 'lidl', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e9', 'aldi_sued', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e9', 'aldi_nord', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e9', 'rewe', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000e9', 'netto', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ea', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ea', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ea', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ea', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ea', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000eb', 'lidl', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000eb', 'aldi_sued', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000eb', 'aldi_nord', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000eb', 'rewe', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000eb', 'netto', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ec', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ec', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ec', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ec', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ec', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ed', 'lidl', 179, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ed', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ed', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ed', 'rewe', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ed', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ee', 'lidl', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ee', 'aldi_sued', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ee', 'aldi_nord', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ee', 'rewe', 55, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ee', 'netto', 49, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ef', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ef', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ef', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ef', 'rewe', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ef', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f0', 'lidl', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f0', 'aldi_sued', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f0', 'aldi_nord', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f0', 'rewe', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f0', 'netto', 89, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f1', 'lidl', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f1', 'aldi_sued', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f1', 'aldi_nord', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f1', 'rewe', 365, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f1', 'netto', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f2', 'lidl', 375, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f2', 'aldi_sued', 375, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f2', 'aldi_nord', 375, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f2', 'rewe', 395, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f2', 'netto', 375, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f3', 'lidl', 225, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f3', 'aldi_sued', 225, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f3', 'aldi_nord', 225, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f3', 'rewe', 245, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f3', 'netto', 225, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f4', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f4', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f4', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f4', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f4', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f5', 'lidl', 245, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f5', 'aldi_sued', 245, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f5', 'aldi_nord', 245, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f5', 'rewe', 265, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f5', 'netto', 245, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f6', 'lidl', 369, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f6', 'aldi_sued', 379, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f6', 'aldi_nord', 379, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f6', 'rewe', 379, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f6', 'netto', 379, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f7', 'lidl', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f7', 'aldi_sued', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f7', 'aldi_nord', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f7', 'rewe', 105, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f7', 'netto', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f8', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f8', 'aldi_sued', 209, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f8', 'aldi_nord', 209, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f8', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f8', 'netto', 209, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f9', 'lidl', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f9', 'aldi_sued', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f9', 'aldi_nord', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f9', 'rewe', 375, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000f9', 'netto', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fa', 'lidl', 799, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fa', 'aldi_sued', 829, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fa', 'aldi_nord', 829, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fa', 'rewe', 849, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fa', 'netto', 829, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fb', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fb', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fb', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fb', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fb', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fc', 'lidl', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fc', 'aldi_sued', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fc', 'aldi_nord', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fc', 'rewe', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fc', 'netto', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fd', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fd', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fd', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fd', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fd', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fe', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fe', 'aldi_sued', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fe', 'aldi_nord', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fe', 'rewe', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000fe', 'netto', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ff', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ff', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ff', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ff', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-0000000000ff', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000100', 'lidl', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000100', 'aldi_sued', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000100', 'aldi_nord', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000100', 'rewe', 109, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000100', 'netto', 99, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000101', 'lidl', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000101', 'aldi_sued', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000101', 'aldi_nord', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000101', 'rewe', 365, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000101', 'netto', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000102', 'lidl', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000102', 'aldi_sued', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000102', 'aldi_nord', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000102', 'rewe', 365, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000102', 'netto', 345, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000103', 'lidl', 1999, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000103', 'aldi_sued', 1999, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000103', 'aldi_nord', 1999, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000103', 'rewe', 2199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000103', 'netto', 1999, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000104', 'lidl', 75, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000104', 'aldi_sued', 75, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000104', 'aldi_nord', 75, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000104', 'rewe', 79, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000104', 'netto', 75, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000105', 'lidl', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000105', 'aldi_sued', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000105', 'aldi_nord', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000105', 'rewe', 269, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000105', 'netto', 249, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000106', 'lidl', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000106', 'aldi_sued', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000106', 'aldi_nord', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000106', 'rewe', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000106', 'netto', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000107', 'lidl', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000107', 'aldi_sued', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000107', 'aldi_nord', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000107', 'rewe', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000107', 'netto', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000108', 'lidl', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000108', 'aldi_sued', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000108', 'aldi_nord', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000108', 'rewe', 95, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000108', 'netto', 85, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000109', 'lidl', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000109', 'aldi_sued', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000109', 'aldi_nord', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000109', 'rewe', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-000000000109', 'netto', 189, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010a', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010a', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010a', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010a', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010a', 'netto', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010b', 'lidl', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010b', 'aldi_sued', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010b', 'aldi_nord', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010b', 'rewe', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010b', 'netto', 139, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010c', 'lidl', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010c', 'aldi_sued', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010c', 'aldi_nord', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010c', 'rewe', 159, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010c', 'netto', 149, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010d', 'lidl', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010d', 'aldi_sued', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010d', 'aldi_nord', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010d', 'rewe', 219, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010d', 'netto', 199, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010e', 'lidl', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010e', 'aldi_sued', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010e', 'aldi_nord', 119, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010e', 'rewe', 129, 'manual_seed', 'official', 1.00);
INSERT INTO public.prices (product_id, chain, price_cents, source, trust_status, confidence_score)
VALUES ('22222222-0000-0000-0000-00000000010e', 'netto', 119, 'manual_seed', 'official', 1.00);
