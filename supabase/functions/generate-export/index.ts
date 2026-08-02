// generate-export — state-template record export (spec §8).
// CSV first (PDF templates are a follow-up). Writes the file to the
// private 'exports' bucket and returns a signed URL + exports row.
// Must work regardless of plan state (spec §6). Auth: caller JWT.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  PDFDocument,
  StandardFonts,
  rgb,
} from "https://esm.sh/pdf-lib@1.17.1";

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

// ---------- PDF rendering (pdf-lib, in-function, no external service) -------

const STATE_TITLES: Record<string, string> = {
  FL: "Florida Pesticide Application Record",
  TX: "Texas Pesticide Application Record",
  CA: "California Pesticide Application Record",
};

const PDF_COLS: [string, string, number][] = [
  // [column, header, width]
  ["applied_at", "Date/Time (UTC)", 118],
  ["brand_name", "Product", 110],
  ["epa_reg_no", "EPA Reg. No.", 72],
  ["rate_value", "Rate", 45],
  ["rate_unit", "Unit", 86],
  ["area_value", "Area", 45],
  ["area_unit", "Area unit", 56],
  ["target_pest", "Target pest", 72],
  ["application_method", "Method", 64],
  ["temp_f", "°F", 34],
  ["wind_mph", "Wind", 40],
];

async function buildPdf(
  rows: Record<string, unknown>[],
  meta: { state: string; rangeStart: string; rangeEnd: string; company: string },
): Promise<Uint8Array> {
  const doc = await PDFDocument.create();
  const font = await doc.embedFont(StandardFonts.Helvetica);
  const fontBold = await doc.embedFont(StandardFonts.HelveticaBold);
  const pageW = 792; // Letter landscape
  const pageH = 612;
  const margin = 36;
  const rowH = 16;
  const headerH = 64;
  const rowsPerPage = Math.floor((pageH - margin * 2 - headerH - 24) / rowH);
  const pages = Math.max(1, Math.ceil(rows.length / rowsPerPage));
  const title = STATE_TITLES[meta.state] ??
    `${meta.state} Pesticide Application Record`;

  const fmtCell = (v: unknown): string => {
    if (v == null) return "—";
    const s = String(v);
    return s.length > 22 ? s.slice(0, 21) + "…" : s;
  };
  const fmtDate = (v: unknown): string => {
    if (!v) return "—";
    return String(v).slice(0, 16).replace("T", " ");
  };

  for (let p = 0; p < pages; p++) {
    const page = doc.addPage([pageW, pageH]);
    // header
    page.drawText(title, {
      x: margin, y: pageH - margin - 14, size: 14, font: fontBold,
    });
    page.drawText(
      `${meta.company} - State ${meta.state} - ${meta.rangeStart} -> ${meta.rangeEnd} - ${rows.length} record(s)`,
      { x: margin, y: pageH - margin - 30, size: 9, font },
    );
    page.drawText(
      "Created and retained by SprayLOG. The licensee remains responsible for accuracy.",
      { x: margin, y: pageH - margin - 42, size: 8, font, color: rgb(0.35, 0.35, 0.35) },
    );

    // table header
    let y = pageH - margin - headerH;
    let x = margin;
    for (const [, label, w] of PDF_COLS) {
      page.drawText(label, { x, y, size: 8, font: fontBold });
      x += w;
    }
    y -= 6;
    page.drawLine({
      start: { x: margin, y },
      end: { x: pageW - margin, y },
      thickness: 0.8,
      color: rgb(0.2, 0.2, 0.2),
    });

    // rows
    const slice = rows.slice(p * rowsPerPage, (p + 1) * rowsPerPage);
    for (const r of slice) {
      y -= rowH;
      x = margin;
      for (const [col, , w] of PDF_COLS) {
        const v = col === "applied_at" ? fmtDate(r[col]) : fmtCell(r[col]);
        page.drawText(v, { x, y, size: 7.5, font });
        x += w;
      }
    }

    // footer
    page.drawText(`Page ${p + 1} of ${pages}`, {
      x: pageW - margin - 70, y: margin - 14, size: 8, font,
      color: rgb(0.35, 0.35, 0.35),
    });
  }

  return doc.save();
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

    const { state, range_start, range_end, format, template_key } =
      await req.json();
    if (!state || !range_start || !range_end) {
      return jsonResponse(
        { error: "state, range_start, range_end required" },
        400,
      );
    }
    const fmt = format === "pdf" ? "pdf" : "csv";

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

    // Build payload per format
    let content: Uint8Array;
    let contentType: string;
    let ext: string;
    if (fmt === "pdf") {
      const { data: company } = await supabase
        .from("companies")
        .select("name")
        .eq("id", profile.company_id)
        .single();
      content = await buildPdf(rows ?? [], {
        state,
        rangeStart: range_start,
        rangeEnd: range_end,
        company: company?.name ?? "Company",
      });
      contentType = "application/pdf";
      ext = "pdf";
    } else {
      const header = CSV_COLUMNS.map(([, label]) => label).join(",");
      const lines = (rows ?? []).map((r: Record<string, unknown>) =>
        CSV_COLUMNS.map(([col]) => csvEscape(r[col])).join(",")
      );
      content = new TextEncoder().encode([header, ...lines].join("\n") + "\n");
      contentType = "text/csv";
      ext = "csv";
    }

    const storagePath =
      `${profile.company_id}/${state}_${range_start}_${range_end}_${Date.now()}.${ext}`;
    const { error: uploadError } = await supabase.storage
      .from("exports")
      .upload(storagePath, content, {
        contentType,
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
    return jsonResponse({ error: `Internal error: ${e}` }, 500);
  }
});
