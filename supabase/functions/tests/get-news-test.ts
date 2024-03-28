// Import required libraries and modules
import {
  assert,
  assertEquals,
  assertNotEquals,
} from "https://deno.land/std@0.192.0/testing/asserts.ts";
import {
  createClient,
  SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2.23.0";
import {
  isString,
  required,
  validate,
  validateArray,
  validateObject,
} from "https://deno.land/x/validasaur@v0.15.0/mod.ts";
import { DigestContext } from "https://deno.land/std@0.160.0/crypto/_wasm_crypto/mod.ts";

// Set up the configuration for the Supabase client
const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const options = {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
    detectSessionInUrl: false,
  },
};

const testNoBody = async () => {
  var client: SupabaseClient = createClient(supabaseUrl, supabaseKey, options);

  const res = await client.functions.invoke(
    "get-news",
  );

  assertNotEquals(res.error, null);

  const context: Response = res.error.context;
  await context.body?.cancel();
  assertEquals(context.status, 400);
};

const testEmptyBody = async () => {
  var client: SupabaseClient = createClient(supabaseUrl, supabaseKey, options);

  const res = await client.functions.invoke(
    "get-news",
    { body: {} },
  );

  assertNotEquals(res.error, null);

  const context: Response = res.error.context;
  await context.body?.cancel();
  assertEquals(context.status, 400);
};

const testInvalidBody = async () => {
  var client: SupabaseClient = createClient(supabaseUrl, supabaseKey, options);

  const res = await client.functions.invoke(
    "get-news",
    { body: { categories: ["chocolate", 1234] } },
  );

  assertNotEquals(res.error, null);

  const context: Response = res.error.context;
  assertEquals(context.status, 400);
  await context.body?.cancel();
};

const testValid = async () => {
  var client: SupabaseClient = createClient(supabaseUrl, supabaseKey, options);

  const res = await client.functions.invoke(
    "get-news",
    { body: { categories: ["chocolate", "tea"] } },
  );

  assertNotEquals(res.data, null);

  const news = res.data;

  const schema = {
    news: validateObject(true, {
      articles: validateArray(
        true,
        validateObject(true, {
          title: [isString, required],
          description: [isString, required],
          content: [isString, required],
          url: [isString, required],
        }),
      ),
    }),
  };

  const [passed, _] = await validate(news, schema);
  assert(passed);
};

// Register and run the tests
Deno.test("get-news without body", testNoBody);
Deno.test("get-news with empty body", testEmptyBody);
Deno.test("get-news with invalid body", testInvalidBody);
Deno.test("get-news with valid body", testValid);
