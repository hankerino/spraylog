// send-notice — customer notice for a signed application (spec §8).
// Resend email first (user direction: Twilio SMS is last, after M6).
// Renders the notice, sends it, writes a notices row either way.
// Auth: caller JWT; company resolved from profiles, never the body.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const RESEND_FROM =
  Deno.env.get("RESEND_FROM") ?? "SprayLog <notices@resend.dev>";

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

function renderNotice(app: Record<string, unknown>): string {
  const when = app.applied_at
    ? new Date(String(app.applied_at)).toLocaleString("en-US", {
        dateStyle: "medium",
        timeStyle: "short",
        timeZone: "UTC",
      })
    : "";
  return [
    `Pesticide application notice — ${app.brand_name ?? "product"}`,
    ``,
    `Product: ${app.brand_name ?? "-"} (EPA Reg. No. ${app.epa_reg_no ?? "-"})`,
    `Applied: ${when} UTC`,
    `Rate: ${app.rate_value ?? "-"} ${app.rate_unit ?? ""}`,
    `Area: ${app.area_value ?? "-"} ${app.area_unit ?? ""}`,
    `State: ${app.state ?? "-"}`,
    ``,
    `This record was created and retained by your applicator. The licensee remains responsible for accuracy.`,
  ].join("\n");
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

    const { application_id, channel, destination } = await req.json();
    if (!application_id || !channel || !destination) {
      return jsonResponse(
        { error: "application_id, channel, destination required" },
        400,
      );
    }
    if (channel !== "email") {
      // Twilio is deliberately last per user direction.
      return jsonResponse(
        { error: "Only email notices are supported at this time" },
        400,
      );
    }

    // Fetch the record (tenant-checked via company resolution)
    const { data: app } = await supabase
      .from("applications")
      .select("*")
      .eq("id", application_id)
      .eq("company_id", profile.company_id)
      .maybeSingle();
    if (!app) return jsonResponse({ error: "Application not found" }, 404);

    const body = renderNotice(app);

    let status = "skipped_no_provider";
    let providerId: string | null = null;

    if (RESEND_API_KEY) {
      const res = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${RESEND_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          from: RESEND_FROM,
          to: [destination],
          subject: `Pesticide application notice — ${app.brand_name ?? "record"}`,
          text: body,
        }),
      });
      if (res.ok) {
        const sent = await res.json();
        providerId = sent.id ?? null;
        status = "sent";
      } else {
        console.error("Resend error", res.status, await res.text());
        status = "failed";
      }
    }

    const { data: notice, error: noticeError } = await supabase
      .from("notices")
      .insert({
        company_id: profile.company_id,
        application_id,
        channel,
        destination,
        body,
        sent_at: status === "sent" ? new Date().toISOString() : null,
        delivery_status: status,
        provider_id: providerId,
      })
      .select()
      .single();

    if (noticeError) {
      console.error("notices insert failed", noticeError);
      return jsonResponse({ error: "Failed to persist notice" }, 500);
    }

    return jsonResponse({ status, notice });
  } catch (e) {
    console.error("send-notice failure", e);
    return jsonResponse({ error: "Internal error" }, 500);
  }
});
