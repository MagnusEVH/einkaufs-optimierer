// RLS-Tests für Konten und Haushalte. Echter Postgres (PGlite), Supabase-Teile
// nachgebaut in supabase_shim.sql. Start: cd supabase/tests && npm ci && npm test
//
// Szenario: Magnus (erstes Konto, Admin), Mama (per Einladung), Fremder (eigene
// Einladung von Magnus in einen anderen Haushalt), anonyme Aufrufe.

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
async function q(sql, params) {
  return (await db.query(sql, params)).rows;
}
async function one(sql, params) {
  return (await q(sql, params))[0];
}
async function fails(sql, params, pattern, label) {
  try {
    await db.query(sql, params);
  } catch (e) {
    if (pattern) assert.match(e.message, pattern, label);
    return;
  }
  assert.fail(`sollte scheitern: ${label}`);
}
// Registrierung wie GoTrue: Insert in auth.users (läuft als supabase_auth_admin)
async function signUp(email, meta = {}) {
  await asSuper();
  return (await one(`insert into auth.users (email, raw_user_meta_data) values ($1, $2) returning id`, [email, meta])).id;
}
let passed = 0;
async function test(name, fn) {
  await fn();
  await asSuper();
  passed++;
  console.log(`  ✓ ${name}`);
}

// --- Tests --------------------------------------------------------------------
let magnus, mama, fremder, magnusHome, elternHome, fremdHome, inviteMama;

await test('Erstes Konto bekommt eigenen Haushalt als Owner', async () => {
  magnus = await signUp('magnus@example.org', { display_name: 'Magnus' });
  const p = await one(`select display_name, last_household_id from public.profiles where id = $1`, [magnus]);
  assert.equal(p.display_name, 'Magnus');
  magnusHome = p.last_household_id;
  const m = await one(`select role from public.household_members where user_id = $1`, [magnus]);
  assert.equal(m.role, 'owner');
});

await test('Zweites Konto ohne Einladungscode wird abgelehnt', async () => {
  await asSuper();
  await fails(`insert into auth.users (email) values ('spam@example.org')`, [], /Einladungscode/, 'ohne Code');
  await fails(`insert into auth.users (email, raw_user_meta_data) values ('spam@example.org', '{"invite_code":"AAAA-BBBB-CCCC-DDDD"}')`, [], /Einladungscode/, 'falscher Code');
});

await test('Nur Admins legen weitere Haushalte an', async () => {
  await as(magnus);
  await fails(`select public.create_household('Eltern')`, [], /admins only/, 'ohne Admin');
  await asSuper();
  await db.query(`insert into public.app_admins (user_id) values ($1)`, [magnus]);
  await as(magnus);
  elternHome = (await one(`select public.create_household('Eltern') as id`)).id;
  assert.ok(elternHome);
  const hs = await q(`select name from public.households order by name`);
  assert.deepEqual(hs.map((h) => h.name), ['Eltern', 'Haushalt Magnus']);
});

await test('Einladung: Code einmal sichtbar, gespeichert nur als Hash', async () => {
  await as(magnus);
  inviteMama = (await one(`select public.create_invitation($1) as code`, [elternHome])).code;
  assert.match(inviteMama, /^[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}$/);
  const rows = await q(`select * from public.invitations`);
  assert.equal(rows.length, 1);
  assert.ok(!JSON.stringify(rows).includes(inviteMama), 'Code nicht im Klartext');
});

await test('Mama registriert sich mit Code und landet im Eltern-Haushalt', async () => {
  mama = await signUp('mama@example.org', { display_name: 'Mama', invite_code: inviteMama.toLowerCase() });
  await as(mama);
  const hs = await q(`select id, name from public.households`);
  assert.deepEqual(hs.map((h) => h.name), ['Eltern'], 'nur Eltern, kein eigener Haushalt');
  const p = await one(`select last_household_id from public.profiles where id = (select auth.uid())`);
  assert.equal(p.last_household_id, elternHome);
  const role = await one(`select role from public.household_members where user_id = $1`, [mama]);
  assert.equal(role.role, 'member');
});

await test('Verbrauchter Code geht nicht ein zweites Mal', async () => {
  await asSuper();
  await fails(`insert into auth.users (email, raw_user_meta_data) values ('x@example.org', $1)`, [{ invite_code: inviteMama }], /Einladungscode/, 'zweite Nutzung');
});

await test('Fremder kommt per eigener Einladung in einen dritten Haushalt', async () => {
  await as(magnus);
  fremdHome = (await one(`select public.create_household('Fremd') as id`)).id;
  const code = (await one(`select public.create_invitation($1) as code`, [fremdHome])).code;
  fremder = await signUp('fremd@example.org', { invite_code: code });
  await asSuper();
  await db.query(`delete from public.household_members where household_id = $1 and user_id = $2`, [fremdHome, magnus]);
  await as(fremder);
  const hs = await q(`select name from public.households`);
  assert.deepEqual(hs.map((h) => h.name), ['Fremd']);
  const role = await one(`select role from public.household_members where user_id = $1`, [fremder]);
  assert.equal(role.role, 'owner', 'Magnus ist raus, Fremder wird Owner');
});

await test('Magnus sieht beide eigenen Haushalte, nicht den fremden', async () => {
  await as(magnus);
  const hs = await q(`select name from public.households order by name`);
  assert.deepEqual(hs.map((h) => h.name), ['Eltern', 'Haushalt Magnus']);
});

await test('Liste: Mitglieder schreiben, der Server stempelt', async () => {
  await as(mama);
  const id = 'aaaaaaaa-0000-4000-8000-000000000001';
  await db.query(`insert into public.shopping_items (id, household_id, raw_text, created_by) values ($1, $2, 'Milch', $3)`, [id, elternHome, magnus]);
  await as(magnus);
  const it = await one(`select raw_text, created_by, updated_by from public.shopping_items where id = $1`, [id]);
  assert.equal(it.raw_text, 'Milch');
  assert.equal(it.created_by, mama, 'created_by vom Server, nicht vom Gerät');
  await db.query(`update public.shopping_items set checked_at = now() where id = $1`, [id]);
  const done = await one(`select checked_by, updated_by from public.shopping_items where id = $1`, [id]);
  assert.equal(done.checked_by, magnus);
  assert.equal(done.updated_by, magnus);
});

await test('Abhaken ist idempotent, Rückgängig möglich', async () => {
  const id = 'aaaaaaaa-0000-4000-8000-000000000001';
  await as(mama);
  await db.query(`update public.shopping_items set checked_at = now() + interval '1 hour' where id = $1`, [id]);
  let it = await one(`select checked_by from public.shopping_items where id = $1`, [id]);
  assert.equal(it.checked_by, magnus, 'zweites Abhaken ändert nichts');
  await db.query(`update public.shopping_items set checked_at = null where id = $1`, [id]);
  it = await one(`select checked_at, checked_by from public.shopping_items where id = $1`, [id]);
  assert.equal(it.checked_at, null);
  assert.equal(it.checked_by, null);
});

await test('Haushalt oder ID eines Artikels lässt sich nicht umhängen', async () => {
  const id = 'aaaaaaaa-0000-4000-8000-000000000001';
  await as(magnus);
  await db.query(`update public.shopping_items set household_id = $2 where id = $1`, [id, magnusHome]);
  const it = await one(`select household_id from public.shopping_items where id = $1`, [id]);
  assert.equal(it.household_id, elternHome);
});

await test('Fremde Haushalte: nichts lesen, nichts schreiben', async () => {
  await as(fremder);
  assert.equal((await q(`select * from public.shopping_items`)).length, 0);
  await fails(`insert into public.shopping_items (id, household_id, raw_text) values (gen_random_uuid(), $1, 'Hack')`, [elternHome], /row-level security/, 'Insert in fremden Haushalt');
  const upd = await db.query(`update public.shopping_items set raw_text = 'Hack'`);
  assert.equal(upd.affectedRows, 0);
  assert.equal((await q(`select * from public.household_members where household_id = $1`, [elternHome])).length, 0);
  assert.equal((await q(`select * from public.profiles where id in ($1, $2)`, [magnus, mama])).length, 0);
  assert.ok((await q(`select household_id from public.invitations`)).every((r) => r.household_id === fremdHome), 'nur Einladungen des eigenen Haushalts');
});

await test('Profile: Namen der Mitglieder sichtbar, fremde nicht', async () => {
  await as(mama);
  const names = (await q(`select display_name from public.profiles order by display_name`)).map((r) => r.display_name);
  assert.deepEqual(names, ['Magnus', 'Mama']);
  const upd = await db.query(`update public.profiles set display_name = 'Hack' where id = $1`, [magnus]);
  assert.equal(upd.affectedRows, 0);
});

await test('Mitglieder: kein direktes Eintragen, nur Owner entfernt andere', async () => {
  await as(mama);
  await fails(`insert into public.household_members (household_id, user_id) values ($1, $2)`, [elternHome, fremder], /row-level security|permission denied/, 'direkter Insert');
  await fails(`select public.remove_member($1, $2)`, [elternHome, magnus], /only owners/, 'Mitglied entfernt Owner');
  await fails(`select public.create_invitation($1)`, [elternHome], /only owners/, 'Mitglied lädt ein');
  const del = await db.query(`delete from public.household_members where user_id = $1`, [magnus]);
  assert.equal(del.affectedRows, 0, 'kein direktes Löschen');
  await as(fremder);
  await fails(`select public.remove_member($1, $2)`, [elternHome, mama], /only owners/, 'Fremder');
});

await test('Haushalt umbenennen nur als Owner', async () => {
  await as(mama);
  const r1 = await db.query(`update public.households set name = 'Hack' where id = $1`, [elternHome]);
  assert.equal(r1.affectedRows, 0);
  await as(magnus);
  const r2 = await db.query(`update public.households set name = 'Eltern Bingen' where id = $1`, [elternHome]);
  assert.equal(r2.affectedRows, 1);
});

await test('Einladung annehmen mit bestehendem Konto, Raten wird gedrosselt', async () => {
  await as(fremder);
  for (let i = 0; i < 10; i++) {
    const r = await one(`select public.accept_invitation($1) as id`, [`0000-0000-0000-000${i}`]);
    assert.equal(r.id, null, `Fehlversuch ${i} liefert null`);
  }
  await as(magnus);
  const code = (await one(`select public.create_invitation($1) as code`, [magnusHome])).code;
  await as(fremder);
  await fails(`select public.accept_invitation($1)`, [code], /too many attempts/, 'nach 10 Fehlversuchen gesperrt');
  await as(mama);
  const hid = (await one(`select public.accept_invitation($1) as id`, [code])).id;
  assert.equal(hid, magnusHome);
  assert.equal((await q(`select * from public.households`)).length, 2);
});

await test('Abgelaufene und widerrufene Einladungen gelten nicht', async () => {
  await as(magnus);
  const c1 = (await one(`select public.create_invitation($1) as code`, [magnusHome])).code;
  const c2 = (await one(`select public.create_invitation($1) as code`, [magnusHome])).code;
  await asSuper();
  await db.query(`update public.invitations set expires_at = now() - interval '1 minute' where code_hash = private.code_hash($1)`, [c1]);
  const inv = await one(`select id from public.invitations where code_hash = private.code_hash($1)`, [c2]);
  await as(mama);
  await db.query(`select public.revoke_invitation($1)`, [inv.id]);
  await asSuper();
  assert.equal((await one(`select revoked_at from public.invitations where id = $1`, [inv.id])).revoked_at, null, 'Mitglied kann nicht widerrufen');
  await as(magnus);
  await db.query(`select public.revoke_invitation($1)`, [inv.id]);
  await asSuper();
  await fails(`insert into auth.users (email, raw_user_meta_data) values ('a@example.org', $1)`, [{ invite_code: c1 }], /Einladungscode/, 'abgelaufen');
  await fails(`insert into auth.users (email, raw_user_meta_data) values ('b@example.org', $1)`, [{ invite_code: c2 }], /Einladungscode/, 'widerrufen');
});

await test('Anonym: keine Daten, keine Funktionen außer min_app_version', async () => {
  await asAnon();
  for (const t of ['profiles', 'households', 'household_members', 'invitations', 'shopping_items', 'app_admins']) {
    await fails(`select * from public.${t}`, [], /permission denied/, `anon liest ${t}`);
  }
  for (const f of [`public.admin_stats()`, `public.accept_invitation('x')`, `public.create_invitation(gen_random_uuid())`, `private.user_household_ids()`]) {
    await fails(`select ${f}`, [], /permission denied/, `anon ruft ${f}`);
  }
  assert.equal((await one(`select public.min_app_version() as v`)).v, 1);
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
  assert.equal(s.shared_households, 2, 'Magnus+Mama in Eltern und in Magnus');
  assert.ok(s.db_bytes > 0);
  assert.ok(!JSON.stringify(s).includes('Milch'), 'keine Produktnamen');
});

await test('Admin-Tabelle ist für Clients unsichtbar und unveränderbar', async () => {
  await as(mama);
  assert.equal((await q(`select * from public.app_admins`)).length, 0);
  await fails(`insert into public.app_admins (user_id) values ($1)`, [mama], /row-level security/, 'sich selbst zum Admin machen');
});

await test('Owner verlässt Haushalt: nächstes Mitglied wird Owner', async () => {
  await as(magnus);
  await db.query(`select public.leave_household($1)`, [elternHome]);
  await as(mama);
  const r = await one(`select role from public.household_members where household_id = $1 and user_id = $2`, [elternHome, mama]);
  assert.equal(r.role, 'owner');
  await as(magnus);
  assert.equal((await q(`select * from public.shopping_items`)).length, 0, 'Magnus sieht die Eltern-Liste nicht mehr');
});

await test('Konto löschen: Profil und verwaister Haushalt verschwinden', async () => {

  await as(fremder);
  await db.query(`select public.delete_my_account()`);
  await asSuper();
  assert.equal((await q(`select * from auth.users where id = $1`, [fremder])).length, 0);
  assert.equal((await q(`select * from public.profiles where id = $1`, [fremder])).length, 0);
  assert.equal((await q(`select * from public.households where id = $1`, [fremdHome])).length, 0, 'Haushalt ohne Mitglieder gelöscht');
  assert.equal((await q(`select * from public.households where id = $1`, [elternHome])).length, 1, 'Eltern bleiben');
});

console.log(`\n✅ rls.test: ${passed} Tests grün`);
