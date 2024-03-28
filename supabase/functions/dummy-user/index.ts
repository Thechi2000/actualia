import * as postgres from "https://deno.land/x/postgres@v0.17.0/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.40.0";

// Get the connection string from the environment variable "SUPABASE_DB_URL"
const databaseUrl = Deno.env.get("SUPABASE_DB_URL")!;

// Create a database pool with three connections that are lazily established
const pool = new postgres.Pool(databaseUrl, 3, true);

Deno.serve(async (req) => {
  const auth = req.headers.get("Authorization");
  if (!auth?.startsWith("Bearer ")) {
    return new Response("Unauthorized", { status: 401 });
  }

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    auth.substring(7),
  );

  const res = await supabaseClient.auth.admin.createUser({
    email: "actualia@example.com",
    password: "1234",
    email_confirm: true,
  });
  console.log(res);
  if (res.error !== null) {
    return new Response("Forbidden", { status: 403 });
  }

  const session = await supabaseClient.auth.signInWithPassword({
    email: "actualia@example.com",
    password: "1234",
  });
  console.log(session);

  const db = await pool.connect();
  await db
    .queryObject`INSERT INTO profiles(id, updated_at, username) VALUES (${session.data.user?.id}, now(), 'ActualIA') ON CONFLICT (id) DO NOTHING`;

  return new Response(
    JSON.stringify(session),
    { headers: { "Content-Type": "application/json" } },
  );
});
