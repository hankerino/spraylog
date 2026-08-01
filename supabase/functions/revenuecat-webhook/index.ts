// revenuecat-webhook — mirrors RevenueCat entitlement events onto
// companies.plan / companies.plan_status (spec §6, §8).
// app_user_id MUST be the company id (client logs Purchases in with it).
// Auth: shared secret in the Authorization header (same pattern as the
// AgroConectSH webhook).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ACTIVATE = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "PRODUCT_CHANGE",
]);
const DEACTIVATE = new Set(["EXPIRATION"]);

function planFromProduct(productId: string): string {
  if (productId.includes("multi")) return "multi";
  if (productId.includes("crew")) return "crew";
  return "solo";
}

Deno.serve(async (req) => {
  const expected = Deno.env.get("REVENUECAT_WEBHOOK_AUTH") ?? "";
  const provided = req.headers.get("Authorization") ?? "";
  if (!expected || provided !== expected) {
    return new Response("unauthorized", { status: 401 });
  }

  let payload: { event?: Record<string, unknown> };
  try {
    payload = await req.json();
  } catch {
    return new Response("bad json", { status: 400 });
  }
  const ev = payload.event;
  if (!ev) return new Response("no event", { status: 400 });

  const type = String(ev.type ?? "");
  const companyId = String(ev.app_user_id ?? "");
  const productId = String(ev.product_id ?? "");

  if (!companyId) return new Response("ignored", { status: 200 });

  let update: Record<string, unknown> | null = null;
  if (ACTIVATE.has(type)) {
    update = { plan: planFromProduct(productId), plan_status: "active" };
  } else if (DEACTIVATE.has(type)) {
    // Lapsed: read-only — history/export stay available forever (spec §6).
    update = { plan_status: "lapsed" };
  } else {
    return new Response("ignored", { status: 200 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
  const { error } = await supabase
    .from("companies")
    .update(update)
    .eq("id", companyId);
  if (error) {
    return new Response(`update failed: ${error.message}`, { status: 500 });
  }
  return new Response("ok", { status: 200 });
});
