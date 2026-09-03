-- RGIPT Mechanical Engineering — Website Management Team
-- Run this ONCE in the Supabase SQL Editor if the existing project reports
-- that public.management_team is missing from the schema cache. Safe to re-run.

create extension if not exists pgcrypto;

create table if not exists public.management_team (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  roll_no text not null,
  batch text not null,
  role text,
  photo_url text,
  sort_order int not null default 1,
  published boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.management_team enable row level security;

drop policy if exists "public published management_team" on public.management_team;
drop policy if exists "admin management_team insert" on public.management_team;
drop policy if exists "admin management_team update" on public.management_team;
drop policy if exists "admin management_team delete" on public.management_team;

create policy "public published management_team" on public.management_team
for select using (published or public.is_admin());

create policy "admin management_team insert" on public.management_team
for insert to authenticated with check (public.is_admin());

create policy "admin management_team update" on public.management_team
for update to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "admin management_team delete" on public.management_team
for delete to authenticated using (public.is_admin());

-- After running this script, refresh the Admin page.
