// validate-application — deterministic resolution of candidate fields
// against the products catalogue (spec §0.1, §8).
//
// The LLM never originates a regulated value: this function is the ONLY
// place epa_reg_no / product identity / rate-legality flags come from,
// and it is fully deterministic. Input = extraction candidates (+ state).
// Output = resolved product (or picker candidates), rate flag, state
// registration flag. Auth: caller JWT; company resolved from profiles.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const MATCH_THRESHOLD = 0.75;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// ---------- deterministic fuzzy matching (mirrors client matcher) ----------

const SPOKEN_NUMBERS: Record<string, string> = {
  two: "2", three: "3", four: "4", five: "5", six: "6", seven: "7",
  eight: "8", nine: "9", ten: "10",
};

function normalize(s: string): string {
  let out = s.toLowerCase().replace(/[^a-z0-9\s]/g, " ");
  for (const [word, digit] of Object.entries(SPOKEN_NUMBERS)) {
    out = out.replace(new RegExp(`\\b${word}\\b`, "g"), digit);
  }
  return out.replace(/\s+/g, " ").trim();
}

function tokenSortRatio(a: string, b: string): number {
  if (!a || !b) return 0;
  const ta = normalize(a).split(" ").sort().join(" ");
  const tb = normalize(b).split(" ").sort().join(" ");
  if (ta === tb) return 1;
  // dice coefficient on token bigrams
  const bigrams = (s: string): Set<string> => {
    const set = new Set<string>();
    for (let i = 0; i < s.length - 1; i++) set.add(s.slice(i, i + 2));
    return set;
  };
  const ba = bigrams(ta), bb = bigrams(tb);
  let overlap = 0;
  for (const g of ba) if (bb.has(g)) overlap++;
  return (2 * overlap) / (ba.size + bb.size || 1);
}

interface ProductRow {
  id: string;
  epa_reg_no: string;
  brand_name: string;
  brand_aliases: string[] | null;
  signal_word: string | null;
  restricted_use: boolean;
}

function scoreProduct(query: string, p: ProductRow): number {
  let best = tokenSortRatio(query, p.brand_name);
  if (normalize(p.brand_name).startsWith(normalize(query))) {
    best = Math.max(best, 0.9);
  }
  for (const alias of p.brand_aliases ?? []) {
    best = Math.max(best, tokenSortRatio(query, alias));
  }
  return best;
}

// ---------------------------------------------------------------------------

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return jsonResponse({ error: "Missing authorization" }, 401);

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );
    const { data: userData, error: userError } = await supabase.auth
      .getUser(authHeader.replace("Bearer ", ""));
    if (userError || !userData.user) {
      return jsonResponse({ error: "Invalid token" }, 401);
    }
    const { data: profile } = await supabase
      .from("profiles")
      .select("company_id")
      .eq("id", userData.user.id)
      .maybeSingle();
    if (!profile) return jsonResponse({ error: "No company profile" }, 403);

    const body = await req.json();
    const spokenProduct = String(body.spoken_product ?? "").trim();
    const state = String(body.state ?? "").trim().toUpperCase();
    const rateValue = body.rate_value != null ? Number(body.rate_value) : null;
    const rateUnit = body.rate_unit != null ? String(body.rate_unit) : null;

    // 1) load catalogue + score
    const { data: products } = await supabase
      .from("products")
      .select("id, epa_reg_no, brand_name, brand_aliases, signal_word, restricted_use");

    const scored = (products ?? [])
      .map((p: ProductRow) => ({ p, score: spokenProduct ? scoreProduct(spokenProduct, p) : 0 }))
      .sort((a, b) => b.score - a.score);

    const best = scored[0];
    if (!best || best.score < MATCH_THRESHOLD) {
      // Never guess (spec §3): force a picker with the closest options.
      return jsonResponse({
        matched: false,
        picker_candidates: scored.slice(0, 5).map((s) => ({
          product_id: s.p.id,
          brand_name: s.p.brand_name,
          epa_reg_no: s.p.epa_reg_no,
          score: s.score,
        })),
      });
    }

    const product = best.p;

    // 2) rate vs label maximum (only comparable when units align)
    const { data: rates } = await supabase
      .from("product_rates")
      .select("site_type, max_rate_value, max_rate_unit")
      .eq("product_id", product.id);

    let rateFlag: string | null = null;
    let rateMax: { value: number; unit: string } | null = null;
    if (rateValue != null && rateUnit != null && rates && rates.length > 0) {
      const row = rates.find((r: { max_rate_unit: string }) => r.max_rate_unit === rateUnit);
      if (row) {
        rateMax = { value: row.max_rate_value, unit: row.max_rate_unit };
        if (rateValue > row.max_rate_value) rateFlag = "over_label";
      }
    }

    // 3) state registration
    if (state) {
      const { data: reg } = await supabase
        .from("product_state_registrations")
        .select("status")
        .eq("product_id", product.id)
        .eq("state", state)
        .maybeSingle();
      if (!reg || reg.status !== "active") {
        rateFlag = rateFlag ?? "unregistered_in_state";
      }
    }

    return jsonResponse({
      matched: true,
      product_id: product.id,
      epa_reg_no: product.epa_reg_no,
      brand_name: product.brand_name,
      signal_word: product.signal_word,
      restricted_use: product.restricted_use,
      match_score: best.score,
      rate_flag: rateFlag,
      rate_max: rateMax,
      override_allowed: true, // hard block unless override_reason is typed (client rule)
    });
  } catch (e) {
    console.error("validate-application failure", e);
    return jsonResponse({ error: "Internal error" }, 500);
  }
});
