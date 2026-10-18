// supabase/functions/places-proxy/index.ts
// Proxy for Google Places API to find Lidl, Aldi, and Rewe stores,
// protect API keys server-side, and cache results in PostGIS.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface PlacesRequest {
  latitude: number;
  longitude: number;
  radius_meters?: number;
}

// Calculate Haversine distance in meters
function haversineDistanceMeters(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371000; // Earth radius in meters
  const dLat = (lat2 - lat1) * (Math.PI / 180);
  const dLon = (lon2 - lon1) * (Math.PI / 180);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * (Math.PI / 180)) *
      Math.cos(lat2 * (Math.PI / 180)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Cluster stores with < 500m distance between them
function clusterStores(stores: any[], thresholdMeters = 500) {
  const n = stores.length;
  const parent = Array.from({ length: n }, (_, i) => i);

  function find(i: number): number {
    if (parent[i] === i) return i;
    parent[i] = find(parent[i]);
    return parent[i];
  }

  function union(i: number, j: number) {
    const rootI = find(i);
    const rootJ = find(j);
    if (rootI !== rootJ) {
      parent[rootI] = rootJ;
    }
  }

  for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
      const dist = haversineDistanceMeters(
        stores[i].latitude,
        stores[i].longitude,
        stores[j].latitude,
        stores[j].longitude
      );
      if (dist <= thresholdMeters) {
        union(i, j);
      }
    }
  }

  const clusterMap = new Map<number, number>();
  let clusterCounter = 1;

  return stores.map((s, idx) => {
    const root = find(idx);
    if (!clusterMap.has(root)) {
      clusterMap.set(root, clusterCounter++);
    }
    return {
      ...s,
      cluster_num: clusterMap.get(root)!,
    };
  });
}

function detectChain(name: string): string | null {
  const lower = name.toLowerCase();
  if (lower.includes("lidl")) return "lidl";
  if (lower.includes("aldi süd") || lower.includes("aldi sued")) return "aldi_sued";
  if (lower.includes("aldi nord") || lower.includes("aldi")) return "aldi_nord";
  if (lower.includes("rewe")) return "rewe";
  return null;
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

    const body: PlacesRequest = await req.json();
    const { latitude, longitude, radius_meters = 5000 } = body;

    if (!latitude || !longitude) {
      return new Response(
        JSON.stringify({ error: "Missing latitude or longitude" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const apiKey = Deno.env.get("GOOGLE_MAPS_API_KEY");

    // 1. If Google Maps API Key is provided, query Google Places API
    let rawPlaces: any[] = [];
    if (apiKey) {
      const placesUrl = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&radius=${radius_meters}&type=supermarket&key=${apiKey}`;
      const response = await fetch(placesUrl);
      const data = await response.json();

      if (data.results) {
        for (const place of data.results) {
          const chain = detectChain(place.name);
          if (chain) {
            rawPlaces.push({
              google_place_id: place.place_id,
              name: place.name,
              chain,
              address: place.vicinity,
              latitude: place.geometry.location.lat,
              longitude: place.geometry.location.lng,
            });
          }
        }
      }
    }

    // 2. Query PostGIS database for existing / cached stores
    const { data: dbStores, error: dbError } = await supabaseClient.rpc(
      "get_nearby_store_clusters",
      {
        p_lat: latitude,
        p_lng: longitude,
        p_radius_meters: radius_meters,
      }
    );

    let combinedStores = dbStores || [];

    // If new places were found from Google API, insert/upsert into DB
    if (rawPlaces.length > 0) {
      for (const p of rawPlaces) {
        await supabaseClient
          .from("stores")
          .upsert(
            {
              chain: p.chain,
              name: p.name,
              address: p.address,
              location: `POINT(${p.longitude} ${p.latitude})`,
              google_place_id: p.google_place_id,
              updated_at: new Date().toISOString(),
            },
            { onConflict: "google_place_id" }
          );
      }

      // Re-fetch clustered stores from PostGIS
      const { data: refreshed } = await supabaseClient.rpc(
        "get_nearby_store_clusters",
        {
          p_lat: latitude,
          p_lng: longitude,
          p_radius_meters: radius_meters,
        }
      );
      if (refreshed) combinedStores = refreshed;
    }

    // Fallback in-memory clustering if DB RPC is not yet executed in live environment
    const finalStores = clusterStores(
      combinedStores.map((s: any) => ({
        id: s.id,
        chain: s.chain,
        name: s.name,
        address: s.address,
        latitude: s.latitude,
        longitude: s.longitude,
        distance_meters: Math.round(
          haversineDistanceMeters(latitude, longitude, s.latitude, s.longitude)
        ),
      }))
    );

    return new Response(
      JSON.stringify({
        success: true,
        user_location: { latitude, longitude },
        search_radius_meters: radius_meters,
        total_stores_found: finalStores.length,
        stores: finalStores,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
