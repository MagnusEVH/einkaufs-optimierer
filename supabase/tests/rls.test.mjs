// RLS-Tests für Konten und Haushalte. Echter Postgres (PGlite), Supabase-Teile
// nachgebaut in supabase_shim.sql. Start: cd supabase/tests && npm ci && npm test
//
// Szenario: Magnus (Allowlist, Admin), Mama (per Einladung in "Eltern"),
// Fremder (eigener Haushalt "Fremd"), anonyme Aufrufe.
// Nicht abgedeckt (eine Verbindung): gleichzeitige Transaktionen.

import { PGlite } from '@electric-sql/pglite';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const migrations = join(here, '..', 'migrations');

const db = new PGlite();
await db.exec(readFileSync(join(here, 'supabase_shim.sql'), 'utf8'));
for (const f of readdirSync(migrations).filter((f) => f.endsWith('.sql')).sort()) {
  await db.exec(readFileSync(join(migrations, f), 'utf8'));
}

// --- Helfer -----------------------------------------------------------------
async function asSuper() {
  await db.exec(`reset role; select set_config('request.jwt.claim.sub', '', false);`);
}
async function as(user) {
  await asSuper();
  await db.exec(`set role authenticated; select set_config('request.jwt.claim.sub', '${user}', false);`);
}
async function asAnon() {
  await asSuper();
  await db.exec(`set role anon;`);
}
async function asAuthAdmin() {
  await asSuper();
  await db.exec(`set role supabase_auth_admin;`);
}
async function q(sql, params) {
  return (await db.query(sql, params)).rows;
}
async function one(sql, params) {
  return (await q(sql, params))[0];
}
async function fails(sql, params, pattern, label) {
  let error = null;
  try {
    await db.query(sql, params);
  } catch (e) {
    error = e;
  }
  assert.ok(error, `sollte scheitern: ${label}`);
  if (pattern) assert.match(error.message, pattern, label);
}
// Registrierung wie GoTrue (Rolle supabase_auth_admin). confirmed = E-Mail bestätigt.
async function signUp(email, meta = {}, { confirmed = true } = {}) {
  await asAuthAdmin();
  const row = await one(
    `insert into auth.users (email, raw_user_meta_data, email_confirmed_at)
     values ($1, $2, case when $3 then now() end) returning id`,
    [email, meta, confirmed],
  );
  await asSuper();
  return row.id;
}
async function confirm(user) {
  await asAuthAdmin();
  await db.query(`update auth.users set email_confirmed_at = now() where id = $1`, [user]);
  await asSuper();
}
async function newCode(owner, household, maxUses = 1) {
  await as(owner);
  return (await one(`select public.create_invitation($1, $2) as code`, [household, maxUses])).code;
}
let passed = 0;
async function test(name, fn) {
  await fn();
  await asSuper();
  passed++;
  console.log(`  ✓ ${name}`);
}
const CODE_RE = /^[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}$/;

// --- Registrierung --------------------------------------------------------------
let magnus, mama, fremder, magnusHome, elternHome, fremdHome;

await test('Ohne Einladung und ohne Allowlist: keine Registrierung, auch nicht als Erster', async () => {
  await asAuthAdmin();
  await fails(`insert into auth.users (email) values ('erster@example.org')`, [], /Einladungscode/, 'leere Datenbank');
});

await test('Allowlist-Konto bekommt nach Bestätigung eigenen Haushalt als Owner', async () => {
  await db.query(`insert into private.signup_allowlist (email) values ('magnus@example.org')`);
  magnus = await signUp('Magnus@Example.org', { display_name: 'Magnus' }, { confirmed: false });
  assert.equal((await q(`select * from public.household_members where user_id = $1`, [magnus])).length, 0, 'vor Bestätigung kein Haushalt');
  await confirm(magnus);
  const p = await one(`select display_name, last_household_id from public.profiles where id = $1`, [magnus]);
  assert.equal(p.display_name, 'Magnus');
  magnusHome = p.last_household_id;
  assert.ok(magnusHome);
  assert.equal((await one(`select role from public.household_members where user_id = $1`, [magnus])).role, 'owner');
  assert.equal((await one(`select name from public.households where id = $1`, [magnusHome])).name, 'Haushalt Magnus');
});

await test('Anonyme Konten werden abgelehnt', async () => {
  await asAuthAdmin();
  await fails(`insert into auth.users (email, is_anonymous) values (null, true)`, [], /Anonyme/, 'anonym');
});

await test('Jedes Konto legt weitere Haushalte an', async () => {
  await asSuper();
  await db.query(`insert into public.app_admins (user_id) values ($1)`, [magnus]); // für admin_stats
  await as(magnus);
  elternHome = (await one(`select public.create_household('Eltern') as id`)).id;
  const hs = await q(`select name from public.households order by name`);
  assert.deepEqual(hs.map((h) => h.name), ['Eltern', 'Haushalt Magnus']);
});

await test('Einladungscode: Format mit 64 Bit, gespeichert nur als Hash', async () => {
  const codes = [];
  for (let i = 0; i < 40; i++) codes.push(await newCode(magnus, elternHome));
  for (const c of codes) assert.match(c, CODE_RE);
  const last = new Set(codes.map((c) => c.at(-1)));
  assert.ok(last.size > 4, `letzte Stelle zufällig (nicht nur 8/9/A/B): ${[...last].join('')}`);
  await as(magnus);
  const dump = JSON.stringify(await q(`select * from public.invitations`));
  for (const c of codes) assert.ok(!dump.includes(c), 'kein Klartext');
  await asSuper();
  await db.query(`update public.invitations set revoked_at = now() where revoked_at is null`);
});

await test('Mama: Code bei Registrierung, Beitritt erst nach Bestätigung, Code nicht in Kontodaten', async () => {
  const code = await newCode(magnus, elternHome);
  mama = await signUp('mama@example.org', { display_name: 'Mama', invite_code: code.toLowerCase() }, { confirmed: false });
  const meta = (await one(`select raw_user_meta_data as m from auth.users where id = $1`, [mama])).m;
  assert.ok(!JSON.stringify(meta).includes(code) && !('invite_code' in meta), 'Code entfernt');
  assert.equal((await q(`select * from public.household_members where user_id = $1`, [mama])).length, 0, 'vor Bestätigung kein Mitglied');
  await as(magnus);
  assert.deepEqual((await q(`select display_name from public.profiles order by 1`)).map((r) => r.display_name), ['Magnus'], 'unbestätigt unsichtbar');
  await confirm(mama);
  await as(mama);
  assert.deepEqual((await q(`select name from public.households`)).map((h) => h.name), ['Eltern']);
  assert.equal((await one(`select last_household_id from public.profiles where id = $1`, [mama])).last_household_id, elternHome);
  assert.equal((await one(`select role from public.household_members where user_id = $1`, [mama])).role, 'member');
  await asAuthAdmin();
  await fails(`insert into auth.users (email, raw_user_meta_data) values ('x@example.org', $1)`, [{ invite_code: code }], /Einladungscode/, 'Code verbraucht');
});

await test('Fremder kommt per Einladung, Magnus tritt aus, Fremder wird Owner', async () => {
  await as(magnus);
  fremdHome = (await one(`select public.create_household('Fremd') as id`)).id;
  const code = await newCode(magnus, fremdHome);
  fremder = await signUp('fremd@example.org', { invite_code: code });
  await as(magnus);
  await db.query(`select public.leave_household($1)`, [fremdHome]);
  await as(fremder);
  assert.deepEqual((await q(`select name from public.households`)).map((h) => h.name), ['Fremd']);
  assert.equal((await one(`select role from public.household_members where user_id = $1`, [fremder])).role, 'owner');
});

// --- Liste --------------------------------------------------------------------
const ITEM = 'aaaaaaaa-0000-4000-8000-000000000001';

await test('Liste: Mitglieder schreiben, der Server stempelt', async () => {
  await as(mama);
  await db.query(`insert into public.shopping_items (id, household_id, raw_text) values ($1, $2, 'Milch')`, [ITEM, elternHome]);
  await as(magnus);
  assert.equal((await one(`select created_by from public.shopping_items where id = $1`, [ITEM])).created_by, mama);
  await db.query(`update public.shopping_items set checked_at = now() where id = $1`, [ITEM]);
  const done = await one(`select checked_by, updated_by from public.shopping_items where id = $1`, [ITEM]);
  assert.equal(done.checked_by, magnus);
  assert.equal(done.updated_by, magnus);
});

await test('Abhaken ist idempotent, Rückgängig möglich', async () => {
  await as(mama);
  await db.query(`update public.shopping_items set checked_at = now() + interval '1 hour' where id = $1`, [ITEM]);
  assert.equal((await one(`select checked_by from public.shopping_items where id = $1`, [ITEM])).checked_by, magnus);
  await db.query(`update public.shopping_items set checked_at = null where id = $1`, [ITEM]);
  const it = await one(`select checked_at, checked_by from public.shopping_items where id = $1`, [ITEM]);
  assert.equal(it.checked_at, null);
  assert.equal(it.checked_by, null);
});

await test('Upsert vom Gerät geht, Haushalt und Ersteller bleiben fest', async () => {
  await as(magnus);
  await db.query(
    `insert into public.shopping_items (id, household_id, raw_text, quantity) values ($1, $2, 'Milch 1,5 %', 2)
     on conflict (id) do update set household_id = excluded.household_id, raw_text = excluded.raw_text, quantity = excluded.quantity`,
    [ITEM, elternHome],
  );
  const it = await one(`select household_id, raw_text, quantity, created_by from public.shopping_items where id = $1`, [ITEM]);
  assert.equal(it.raw_text, 'Milch 1,5 %');
  assert.equal(Number(it.quantity), 2);
  assert.equal(it.created_by, mama);
  await db.query(`update public.shopping_items set household_id = $2 where id = $1`, [ITEM, magnusHome]);
  assert.equal((await one(`select household_id from public.shopping_items where id = $1`, [ITEM])).household_id, elternHome, 'nicht umgehängt');
  await fails(`update public.shopping_items set created_by = $2 where id = $1`, [ITEM, magnus], /permission denied/, 'created_by');
});

await test('Fremde: nichts lesen, nichts schreiben, auch nicht per Upsert', async () => {
  await as(fremder);
  assert.equal((await q(`select * from public.shopping_items`)).length, 0);
  await fails(`insert into public.shopping_items (id, household_id, raw_text) values (gen_random_uuid(), $1, 'Hack')`, [elternHome], /row-level security/, 'Insert fremd');
  await fails(
    `insert into public.shopping_items (id, household_id, raw_text) values ($1, $2, 'Hack') on conflict (id) do update set raw_text = excluded.raw_text`,
    [ITEM, fremdHome], /row-level security/, 'Upsert auf fremde ID');
  assert.equal((await db.query(`update public.shopping_items set raw_text = 'Hack'`)).affectedRows, 0);
  assert.equal((await q(`select * from public.household_members where household_id = $1`, [elternHome])).length, 0);
  assert.equal((await q(`select * from public.profiles where id in ($1, $2)`, [magnus, mama])).length, 0);
  assert.ok((await q(`select household_id from public.invitations`)).every((r) => r.household_id === fremdHome));
  await fails(`truncate public.shopping_items`, [], /permission denied/, 'TRUNCATE');
});

// --- Profile, Mitglieder, Haushalte ---------------------------------------------
await test('Profile: Namen der Mitglieder sichtbar, fremde nicht, nur erlaubte Spalten', async () => {
  await as(mama);
  assert.deepEqual((await q(`select display_name from public.profiles order by 1`)).map((r) => r.display_name), ['Magnus', 'Mama']);
  assert.equal((await db.query(`update public.profiles set display_name = 'Hack' where id = $1`, [magnus])).affectedRows, 0);
  await fails(`update public.profiles set last_seen_on = '2099-01-01' where id = $1`, [mama], /permission denied/, 'Statistik fälschen');
  await fails(`update public.profiles set last_household_id = $2 where id = $1`, [mama, '00000000-0000-4000-8000-000000000000'], /foreign key/, 'erfundener Haushalt');
});

await test('Mitglieder: kein direktes Eintragen oder Löschen, nur Owner entfernt andere', async () => {
  await as(mama);
  await fails(`insert into public.household_members (household_id, user_id) values ($1, $2)`, [elternHome, fremder], /permission denied/, 'Insert');
  await fails(`delete from public.household_members where user_id = $1`, [magnus], /permission denied/, 'Delete');
  await fails(`select public.remove_member($1, $2)`, [elternHome, magnus], /only owners/, 'Mitglied entfernt Owner');
  await fails(`select public.create_invitation($1)`, [elternHome], /only owners/, 'Mitglied lädt ein');
  await as(magnus);
  await fails(`select public.remove_member($1, $2)`, [elternHome, magnus], /leave_household/, 'Owner entfernt sich selbst');
  await as(fremder);
  await fails(`select public.remove_member($1, $2)`, [elternHome, mama], /only owners/, 'Fremder');
});

await test('Haushalt: nur Owner benennt um, sonst nichts änderbar', async () => {
  await as(mama);
  assert.equal((await db.query(`update public.households set name = 'Hack' where id = $1`, [elternHome])).affectedRows, 0);
  await as(magnus);
  assert.equal((await db.query(`update public.households set name = 'Eltern Bingen' where id = $1`, [elternHome])).affectedRows, 1);
  await fails(`update public.households set created_by = $2 where id = $1`, [elternHome, mama], /permission denied/, 'created_by');
  await fails(`delete from public.households where id = $1`, [elternHome], /permission denied/, 'löschen');
});

// --- Einladungen mit bestehendem Konto -------------------------------------------
await test('Einladung annehmen: mehrfach nutzbar, Mitglied verbraucht nichts, Raten gedrosselt', async () => {
  const code = await newCode(magnus, magnusHome, 2);
  await as(mama);
  assert.equal((await one(`select public.accept_invitation($1) as id`, [code])).id, magnusHome);
  assert.equal((await one(`select public.accept_invitation($1) as id`, [code])).id, magnusHome, 'nochmal: schon Mitglied');
  await asSuper();
  assert.equal((await one(`select used_count from public.invitations where code_hash = private.code_hash($1)`, [code])).used_count, 1);
  await as(fremder);
  for (let i = 0; i < 10; i++) {
    assert.equal((await one(`select public.accept_invitation($1) as id`, [`0000-0000-0000-000${i}`])).id, null, `Fehlversuch ${i}`);
  }
  await fails(`select public.accept_invitation($1)`, [code], /too many attempts/, 'gesperrt nach 10 Fehlversuchen');
});

await test('Abgelaufene und widerrufene Einladungen gelten nicht, nur Owner widerruft', async () => {
  const c1 = await newCode(magnus, magnusHome);
  const c2 = await newCode(magnus, magnusHome);
  await asSuper();
  await db.query(`update public.invitations set expires_at = now() - interval '1 minute' where code_hash = private.code_hash($1)`, [c1]);
  const inv = await one(`select id from public.invitations where code_hash = private.code_hash($1)`, [c2]);
  await as(mama);
  await db.query(`select public.revoke_invitation($1)`, [inv.id]);
  await asSuper();
  assert.equal((await one(`select revoked_at from public.invitations where id = $1`, [inv.id])).revoked_at, null, 'Mitglied kann nicht widerrufen');
  await as(magnus);
  await db.query(`select public.revoke_invitation($1)`, [inv.id]);
  await asAuthAdmin();
  await fails(`insert into auth.users (email, raw_user_meta_data) values ('a@example.org', $1)`, [{ invite_code: c1 }], /Einladungscode/, 'abgelaufen');
  await fails(`insert into auth.users (email, raw_user_meta_data) values ('b@example.org', $1)`, [{ invite_code: c2 }], /Einladungscode/, 'widerrufen');
});

await test('Einladung wird vor der Bestätigung ungültig: Konto ohne Haushalt', async () => {
  const code = await newCode(magnus, magnusHome);
  const spaet = await signUp('spaet@example.org', { invite_code: code }, { confirmed: false });
  await asSuper();
  const invId = (await one(`select invitation_id as id from private.pending_invitations where user_id = $1`, [spaet])).id;
  await as(magnus);
  await db.query(`select public.revoke_invitation($1)`, [invId]);
  await confirm(spaet);
  assert.equal((await q(`select * from public.household_members where user_id = $1`, [spaet])).length, 0);
  await db.query(`delete from auth.users where id = $1`, [spaet]);
});

await test('Kontodaten ändern schmuggelt weder Code noch Einladung ein', async () => {
  const fremdInv = await newCode(magnus, magnusHome);
  await asSuper();
  const invId = (await one(`select id from public.invitations where code_hash = private.code_hash($1)`, [fremdInv])).id;
  const late = await signUp('spaet2@example.org', { invite_code: await newCode(magnus, magnusHome) }, { confirmed: false });
  await asAuthAdmin(); // GoTrue übernimmt Nutzerdaten per Update
  await db.query(`update auth.users set raw_user_meta_data = raw_user_meta_data || $2 where id = $1`,
    [late, { invite_code: fremdInv, pending_invitation: invId }]);
  await asSuper();
  const meta = (await one(`select raw_user_meta_data as m from auth.users where id = $1`, [late])).m;
  assert.ok(!('invite_code' in meta), 'Code per Update entfernt');
  assert.notEqual((await one(`select invitation_id from private.pending_invitations where user_id = $1`, [late])).invitation_id, invId, 'Kontodaten zählen nicht');
  await db.query(`delete from auth.users where id = $1`, [late]);
});

await test('Später angelegte Funktionen in private sind nicht aufrufbar', async () => {
  await db.exec(`create function private.later() returns int language sql as 'select 1'`);
  for (const role of ['anon', 'authenticated']) {
    assert.equal((await one(`select has_function_privilege($1, 'private.later()', 'execute') as ok`, [role])).ok, false, role);
  }
  await db.exec(`drop function private.later()`);
});

// --- Rechte von anon und interne Funktionen ------------------------------------
await test('Anonym: keine Daten, keine Funktion außer min_app_version', async () => {
  await asAnon();
  for (const t of ['public.profiles', 'public.households', 'public.household_members', 'public.invitations', 'public.shopping_items', 'public.app_admins', 'private.invite_attempts', 'private.signup_allowlist']) {
    await fails(`select * from ${t}`, [], /permission denied/, `anon liest ${t}`);
  }
  await asSuper();
  const fns = await q(`select p.oid::regprocedure::text as sig from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                       where n.nspname in ('public', 'private')`);
  assert.ok(fns.length > 15);
  for (const { sig } of fns) {
    const ok = (await one(`select has_function_privilege('anon', $1::regprocedure, 'execute') as ok`, [sig])).ok;
    assert.equal(ok, sig === 'min_app_version()', `anon darf ${sig}`);
  }
  await asAnon();
  assert.equal((await one(`select public.min_app_version() as v`)).v, 1);
});

await test('Interne Funktionen und Tabellen sind für Konten gesperrt', async () => {
  await as(mama);
  for (const f of [`private.find_invitation('x')`, `private.code_hash('x')`, `private.join_after_confirmation(null::auth.users)`]) {
    await fails(`select ${f}`, [], /permission denied/, f);
  }
  await fails(`select * from private.invite_attempts`, [], /permission denied/, 'invite_attempts');
  await fails(`insert into private.signup_allowlist values ('mama@example.org')`, [], /permission denied/, 'Allowlist');
  await fails(`insert into public.app_admins (user_id) values ($1)`, [mama], /permission denied/, 'sich zum Admin machen');
  assert.equal((await q(`select * from public.app_admins`)).length, 0, 'Admin-Liste unsichtbar');
});

await test('Admin-Statistik nur für Admins, nur Zahlen', async () => {
  await as(mama);
  await fails(`select public.admin_stats()`, [], /admins only/, 'kein Admin');
  await as(magnus);
  await db.query(`select public.touch_last_seen()`);
  const s = (await one(`select public.admin_stats() as s`)).s;
  assert.equal(s.accounts, 3);
  assert.equal(s.active_7d, 1);
  assert.equal(s.households, 3, 'Magnus, Eltern, Fremd');
  assert.equal(s.shared_households, 2);
  assert.ok(s.db_bytes > 0);
  assert.ok(!JSON.stringify(s).includes('Milch'), 'keine Produktnamen');
});

await test('Gruppen für alle: Mama legt eigene Gruppe an, Einladung als Mit-Owner', async () => {
  await as(mama);
  const kegel = (await one(`select public.create_household('Kegelclub') as id`)).id;
  await as(magnus);
  await fails(`select public.create_invitation($1, 1, 'owner')`, [kegel], /only owners/, 'fremde Gruppe');
  await as(mama);
  const code = (await one(`select public.create_invitation($1, 1, 'owner') as code`, [kegel])).code;
  await as(magnus);
  assert.equal((await one(`select public.accept_invitation($1) as id`, [code])).id, kegel);
  assert.equal((await one(`select role from public.household_members where household_id = $1 and user_id = $2`, [kegel, magnus])).role, 'owner');
  // Gleichberechtigt: Magnus kann jetzt selbst einladen und umbenennen
  assert.match((await one(`select public.create_invitation($1) as code`, [kegel])).code, CODE_RE);
  assert.equal((await db.query(`update public.households set name = 'Kegelclub Bingen' where id = $1`, [kegel])).affectedRows, 1);
  await as(mama);
  await db.query(`select public.leave_household($1)`, [kegel]);
  await as(magnus);
  await db.query(`select public.leave_household($1)`, [kegel]);
  await asSuper();
  assert.equal((await q(`select * from public.households where id = $1`, [kegel])).length, 0);
});

await test('Rollen: nur Owner ändern sie, der letzte Owner bleibt Owner', async () => {
  await as(mama);
  await fails(`select public.set_member_role($1, $2, 'owner')`, [elternHome, mama], /only owners/, 'Mitglied befördert sich');
  await as(magnus);
  await fails(`select public.set_member_role($1, $2, 'member')`, [elternHome, magnus], /last owner/, 'letzter Owner');
  await db.query(`select public.set_member_role($1, $2, 'owner')`, [elternHome, mama]);
  await as(mama);
  await db.query(`select public.set_member_role($1, $2, 'member')`, [elternHome, mama]);
  assert.equal((await one(`select role from public.household_members where household_id = $1 and user_id = $2`, [elternHome, mama])).role, 'member');
});

await test('Höchstens 20 Mitgliedschaften pro Konto', async () => {
  await as(fremder);
  const ids = [];
  const have = Number((await one(`select count(*) as n from public.household_members where user_id = $1`, [fremder])).n);
  for (let i = have; i < 20; i++) ids.push((await one(`select public.create_household($1) as id`, [`G${i}`])).id);
  await fails(`select public.create_household('Zu viel')`, [], /too many households/, '21.');
  for (const id of ids) await db.query(`select public.leave_household($1)`, [id]);
});

// --- Austritt und Löschen ---------------------------------------------------------
await test('Owner verlässt Haushalt: nächstes Mitglied wird Owner', async () => {
  await as(magnus);
  await db.query(`select public.leave_household($1)`, [elternHome]);
  await as(mama);
  assert.equal((await one(`select role from public.household_members where household_id = $1 and user_id = $2`, [elternHome, mama])).role, 'owner');
  await as(magnus);
  assert.equal((await q(`select * from public.shopping_items`)).length, 0, 'Magnus sieht die Eltern-Liste nicht mehr');
});

await test('Owner löscht Konto: Mitglied wird Owner, Haushalt ohne Mitglieder verschwindet', async () => {
  await as(magnus); // Owner von "Haushalt Magnus", Mama ist dort Mitglied
  await db.query(`select public.delete_my_account()`);
  await asSuper();
  assert.equal((await q(`select * from auth.users where id = $1`, [magnus])).length, 0);
  assert.equal((await q(`select * from public.profiles where id = $1`, [magnus])).length, 0);
  assert.equal((await one(`select role from public.household_members where household_id = $1 and user_id = $2`, [magnusHome, mama])).role, 'owner');
  await as(fremder);
  await db.query(`select public.delete_my_account()`);
  await asSuper();
  assert.equal((await q(`select * from public.households where id = $1`, [fremdHome])).length, 0, 'Fremd ohne Mitglieder gelöscht');
  assert.equal((await q(`select * from public.invitations where household_id = $1`, [fremdHome])).length, 0, 'Einladungen weg');
});

console.log(`\n✅ rls.test: ${passed} Tests grün`);
