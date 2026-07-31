// extract-application — turns a voice transcript into CANDIDATE fields.
//
// Non-negotiable (spec §0.1): the LLM never originates a regulated value.
// This function must NOT return epa_reg_no, product_id, or any legality
// judgement — deterministic resolution against the products catalogue
// happens separately in validate-application.
//
// Auth: caller JWT required (deployed WITH verify-jwt). company_id is
// resolved from profiles, never from the request body.
//
// NOTE: spec §3 names Anthropic as the extraction upstream; per user
// direction (2026-07-31) it runs on xAI Grok instead (OpenAI-compatible,
// temperature 0, same strict schema).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GROK_API_KEY = Deno.env.get("GROK_API_KEY") ?? "";
const EXTRACTION_MODEL = Deno.env.get("EXTRACTION_MODEL") ?? "grok-3-mini";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT = `You extract structured pesticide-application fields from a lawn-care technician's spoken note.
Return ONLY a single JSON object with exactly these keys (no prose, no markdown):
{
  "spoken_product": string | null,        // product name as spoken, verbatim-ish
  "rate_value": number | null,
  "rate_unit": "oz_per_1000sqft" | "lb_per_acre" | "pct_solution" | null,
  "area_value": number | null,
  "area_unit": "sqft" | "acre" | "linear_ft" | null,
  "target_pest": string | null,
  "application_method": "broadcast" | "spot" | "perimeter" | "drench" | "granular" | null,
  "site_hint": string | null,             // e.g. "front and back lawn"
  "temp_f": number | null,
  "wind_mph": number | null,
  "wind_direction": string | null,
  "confidence": number,                   // 0..1 overall extraction confidence
  "unparsed_remainder": string            // transcript parts you could not map
}
Rules:
- Never invent values not present in the transcript; use null.
- "sixty five hundred square feet" -> area_value 6500, area_unit "sqft".
- Rates like "one and a half ounces per thousand" -> 1.5, "oz_per_1000sqft".
- Do not include EPA registration numbers or legal judgements — you are a parser, not a regulator.`;

interface CandidateFields {
  spoken_product: string | null;
  rate_value: number | null;
  rate_unit: string | null;
  area_value: number | null;
  area_unit: string | null;
  target_pest: string | null;
  application_method: string | null;
  site_hint: string | null;
  temp_f: number | null;
  wind_mph: number | null;
  wind_direction: string | null;
  confidence: number;
  unparsed_remainder: string;
}

const EMPTY: CandidateFields = {
  spoken_product: null,
  rate_value: null,
  rate_unit: null,
  area_value: null,
  area_unit: null,
  target_pest: null,
  application_method: null,
  site_hint: null,
  temp_f: null,
  wind_mph: null,
  wind_direction: null,
  confidence: 0,
  unparsed_remainder: "",
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function parseCandidates(raw: string): CandidateFields {
  const match = raw.match(/\{[\s\S]*\}/);
  if (!match) return { ...EMPTY, unparsed_remainder: raw.slice(0, 500) };
  try {
    const parsed = JSON.parse(match[0]);
    return { ...EMPTY, ...parsed };
  } catch {
    return { ...EMPTY, unparsed_remainder: raw.slice(0, 500) };
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1) caller JWT + company resolution (never trust the body for these)
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

    // 2) input
    const { transcript } = await req.json();
    if (typeof transcript !== "string" || transcript.trim().length < 3) {
      return jsonResponse({ error: "transcript too short" }, 400);
    }
    const cleanTranscript = transcript.trim().slice(0, 2000);

    if (!GROK_API_KEY) {
      return jsonResponse({ error: "Extraction not configured" }, 503);
    }

    // 3) LLM call — temperature 0, strict schema, candidates only
    const llm = await fetch("https://api.x.ai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${GROK_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: EXTRACTION_MODEL,
        max_tokens: 700,
        temperature: 0,
        response_format: { type: "json_object" },
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          { role: "user", content: cleanTranscript },
        ],
      }),
    });

    if (!llm.ok) {
      const detail = await llm.text();
      console.error("Grok error", llm.status, detail);
      return jsonResponse({ error: "Extraction upstream failed" }, 502);
    }

    const llmJson = await llm.json();
    const rawText: string = llmJson.choices?.[0]?.message?.content ?? "";

    const candidates = parseCandidates(rawText);

    // 4) hard strip: regulated fields can never leave this function
    return jsonResponse({
      ...candidates,
      extraction_model: EXTRACTION_MODEL,
    });
  } catch (e) {
    console.error("extract-application failure", e);
    return jsonResponse({ error: "Internal error" }, 500);
  }
});
