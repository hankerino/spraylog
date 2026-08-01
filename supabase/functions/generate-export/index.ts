// generate-export — state-template record export (spec §8).
// CSV first (PDF templates are a follow-up). Writes the file to the
// private 'exports' bucket and returns a signed URL + exports row.
// Must work regardless of plan state (spec §6). Auth: caller JWT.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

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

const CSV_COLUMNS: [string, string][] = [
  ["applied_at", "Date/Time (UTC)"],
  ["state", "State"],
  ["brand_name", "Product"],
  ["epa_reg_no", "EPA Reg No"],
  ["rate_value", "Rate"],
  ["rate_unit", "Rate Unit"],
  ["area_value", "Area"],
  ["area_unit", "Area Unit"],
  ["target_pest", "Target Pest"],
  ["application_method", "Method"],
  ["lat", "Lat"],
  ["lng", "Lng"],
  ["temp_f", "Temp F"],
  ["wind_mph", "Wind mph"],
  ["wind_direction", "Wind Dir"],
  ["rate_flag", "Flag"],
  ["override_reason", "Override Reason"],
  ["transcript", "Transcript"],
  ["record_hash", "Record Hash"],
  ["signed_at", "Signed At (UTC)"],
];

function csvEscape(v: unknown): string {
  if (v == null) return "";
  const s = String(v);
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
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
    const { data: profile } = await supabase
      .from("profiles")
      .select("company_id")
      .eq("id", userData.user.id)
      .maybeSingle();
    if (!profile) return jsonResponse({ error: "No company profile" }, 403);

    const { state, range_start, range_end, format, template_key } =
      await req.json();
    if (!state || !range_start || !range_end) {
      return jsonResponse(
        { error: "state, range_start, range_end required" },
        400,
      );
    }
    const fmt = format === "pdf" ? "pdf" : "csv";
    if (fmt === "pdf") {
      return jsonResponse(
        { error: "PDF templates are not available yet — request format=csv" },
        400,
      );
    }

    const { data: rows, error: rowsError } = await supabase
      .from("applications")
      .select("*")
      .eq("company_id", profile.company_id)
      .eq("state", state)
      .gte("applied_at", `${range_start}T00:00:00Z`)
      .lte("applied_at", `${range_end}T23:59:59Z`)
      .order("applied_at", { ascending: true });

    if (rowsError) {
      console.error("export query failed", rowsError);
      return jsonResponse({ error: "Export query failed" }, 500);
    }

    const header = CSV_COLUMNS.map(([, label]) => label).join(",");
    const lines = (rows ?? []).map((r: Record<string, unknown>) =>
      CSV_COLUMNS.map(([col]) => csvEscape(r[col])).join(",")
    );
    const csv = [header, ...lines].join("\n") + "\n";

    const storagePath =
      `${profile.company_id}/${state}_${range_start}_${range_end}_${Date.now()}.csv`;
    const { error: uploadError } = await supabase.storage
      .from("exports")
      .upload(storagePath, new TextEncoder().encode(csv), {
        contentType: "text/csv",
        upsert: false,
      });
    if (uploadError) {
      console.error("export upload failed", uploadError);
      return jsonResponse({ error: "Failed to store export" }, 500);
    }

    const { data: exportRow, error: exportError } = await supabase
      .from("exports")
      .insert({
        company_id: profile.company_id,
        requested_by: userData.user.id,
        state,
        template_key: template_key ?? "generic",
        range_start,
        range_end,
        format: fmt,
        storage_path: storagePath,
      })
      .select()
      .single();
    if (exportError) {
      console.error("exports insert failed", exportError);
      return jsonResponse({ error: "Failed to record export" }, 500);
    }

    const { data: signed, error: signError } = await supabase.storage
      .from("exports")
      .createSignedUrl(storagePath, 60 * 60); // 1h
    if (signError) {
      console.error("signed url failed", signError);
      return jsonResponse({ error: "Failed to sign URL" }, 500);
    }

    return jsonResponse({
      export: exportRow,
      rows: rows?.length ?? 0,
      signed_url: signed.signedUrl,
    });
  } catch (e) {
    console.error("generate-export failure", e);
    return jsonResponse({ error: "Internal error" }, 500);
  }
});
