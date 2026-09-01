-- RGIPT Mechanical CMS — upgrade existing installation
-- Run this ONCE if you already ran the original schema.sql.

create extension if not exists pgcrypto;

-- The original package accidentally allowed any authenticated user to insert
-- themselves into admin_users. Remove that policy: admins must be provisioned
-- by the project owner from the SQL editor/dashboard.
drop policy if exists "admin users insert self" on public.admin_users;

-- Make sure the upload bucket exists and is public for website delivery.
insert into storage.buckets (id,name,public)
values ('site-assets','site-assets',true)
on conflict (id) do update set public=true;

-- Recreate storage policies safely.
drop policy if exists "public read site assets" on storage.objects;
drop policy if exists "admin upload site assets" on storage.objects;
drop policy if exists "admin update site assets" on storage.objects;
drop policy if exists "admin delete site assets" on storage.objects;

create policy "public read site assets"
on storage.objects for select
using (bucket_id='site-assets');

create policy "admin upload site assets"
on storage.objects for insert to authenticated
with check (bucket_id='site-assets' and public.is_admin());

create policy "admin update site assets"
on storage.objects for update to authenticated
using (bucket_id='site-assets' and public.is_admin())
with check (bucket_id='site-assets' and public.is_admin());

create policy "admin delete site assets"
on storage.objects for delete to authenticated
using (bucket_id='site-assets' and public.is_admin());

-- Ensure gallery photo RLS exists for the direct multi-photo uploader.
alter table public.gallery_photos enable row level security;

