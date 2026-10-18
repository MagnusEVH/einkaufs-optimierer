// supabase/functions/import-catalog/index.ts
// Bulk Import Interface for Grocery Catalogs (JSON / CSV)

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface ImportProductItem {
  gtin_barcode?: string;
  name: string;
  brand?: string;
  category_name?: string;
  quantity_amount?: number;
  quantity_unit?: string;
  is_bio?: boolean;
  is_private_label?: boolean;
  aliases?: string[];
  prices?: {
    lidl?: number;
    aldi_nord?: number;
    aldi_sued?: number;
    rewe?: number;
  };
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const body = await req.json();
    const items: ImportProductItem[] = Array.isArray(body) ? body : body.products || [];

    if (items.length === 0) {
      return new Response(
        JSON.stringify({ error: "No products provided in request body." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let insertedCount = 0;
    let pricesCount = 0;
    let aliasesCount = 0;

    for (const item of items) {
      if (!item.name) continue;

      // Upsert product
      const { data: prodData, error: prodErr } = await supabaseClient
        .from("products")
        .upsert(
          {
            gtin_barcode: item.gtin_barcode,
            name: item.name,
            brand: item.brand,
            quantity_amount: item.quantity_amount ?? 1.0,
            quantity_unit: item.quantity_unit ?? "piece",
            is_bio: item.is_bio ?? false,
            is_private_label: item.is_private_label ?? false,
            updated_at: new Date().toISOString(),
          },
          { onConflict: "gtin_barcode" }
        )
        .select("id")
        .single();

      if (prodErr || !prodData) continue;
      const productId = prodData.id;
      insertedCount++;

      // Aliases
      if (item.aliases && item.aliases.length > 0) {
        for (const alias of item.aliases) {
          await supabaseClient.from("product_aliases").insert({
            product_id: productId,
            alias: alias.toLowerCase().trim(),
            priority: 5,
          });
          aliasesCount++;
        }
      }

      // Prices
      if (item.prices) {
        for (const [chain, priceCents] of Object.entries(item.prices)) {
          if (typeof priceCents === "number" && priceCents > 0) {
            await supabaseClient.from("prices").insert({
              product_id: productId,
              chain: chain as any,
              price_cents: priceCents,
              source: "official_api",
              trust_status: "official",
              valid_from: new Date().toISOString(),
            });
            pricesCount++;
          }
        }
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: "Catalog import processed successfully",
        stats: {
          products_upserted: insertedCount,
          prices_inserted: pricesCount,
          aliases_inserted: aliasesCount,
        },
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
