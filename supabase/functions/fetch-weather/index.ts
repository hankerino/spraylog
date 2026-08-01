// fetch-weather — observation lookup for the confirm screen (spec §8).
// {lat, lng} -> current conditions (temp F, wind mph, wind direction),
// cached 15 min by rounded coordinate. Auth: caller JWT.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const WEATHER_API_KEY = Deno.env.get("OPENWEATHER_API_KEY") ?? "";
const CACHE_MINUTES = 15;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// In-memory cache (per isolate): rounded coord -> {at, payload}
const cache = new Map<string, { at: number; payload: unknown }>();

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

const DIRECTIONS = [
  "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
  "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW",
];

function degToCardinal(deg: number): string {
  return DIRECTIONS[Math.round(((deg % 360) / 22.5)) % 16];
}

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

    const { lat, lng } = await req.json();
    if (typeof lat !== "number" || typeof lng !== "number") {
      return jsonResponse({ error: "lat/lng required" }, 400);
    }
    if (!WEATHER_API_KEY) {
      return jsonResponse({ error: "Weather not configured" }, 503);
    }

    const key = `${lat.toFixed(2)},${lng.toFixed(2)}`;
    const hit = cache.get(key);
    if (hit && Date.now() - hit.at < CACHE_MINUTES * 60_000) {
      return jsonResponse({ ...hit.payload as object, cached: true });
    }

    const url = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lng}&appid=${WEATHER_API_KEY}&units=imperial`;
    const res = await fetch(url);
    if (!res.ok) {
      console.error("OpenWeather error", res.status, await res.text());
      return jsonResponse({ error: "Weather upstream failed" }, 502);
    }
    const w = await res.json();

    const payload = {
      temp_f: w.main?.temp ?? null,
      wind_mph: w.wind?.speed ?? null,
      wind_direction: w.wind?.deg != null ? degToCardinal(w.wind.deg) : null,
      weather_source: "openweathermap",
    };
    cache.set(key, { at: Date.now(), payload });
    return jsonResponse(payload);
  } catch (e) {
    console.error("fetch-weather failure", e);
    return jsonResponse({ error: "Internal error" }, 500);
  }
});
