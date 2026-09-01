-- RGIPT Mechanical Engineering website CMS
-- Run this whole file in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean language sql security definer set search_path = public
as $$ select exists(select 1 from public.admin_users where id = auth.uid()); $$;

create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(), title text not null, subject_code text, semester int,
  description text, file_url text, published boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.syllabus (
  id uuid primary key default gen_random_uuid(), title text not null, batch text, semester int,
  file_url text, published boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.galleries (
  id uuid primary key default gen_random_uuid(), title text not null, description text, cover_image text,
  published boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.gallery_photos (
  id uuid primary key default gen_random_uuid(), gallery_id uuid not null references public.galleries(id) on delete cascade,
  image_url text not null, caption text, created_at timestamptz not null default now()
);
create table if not exists public.laboratories (
  id uuid primary key default gen_random_uuid(), name text not null, description text, location text,
  image_url text, map_url text, published boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.equipment (
  id uuid primary key default gen_random_uuid(), laboratory_id uuid not null references public.laboratories(id) on delete cascade,
  name text not null, description text, specifications text, image_url text, manual_url text,
  published boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.alumni (
  id uuid primary key default gen_random_uuid(), name text not null, batch text, position text, company text,
  bio text, photo_url text, linkedin_url text, featured boolean not null default false,
  published boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.locations (
  id uuid primary key default gen_random_uuid(), name text not null, type text not null, building text, room text,
  description text, map_url text, published boolean not null default false, created_at timestamptz not null default now()
);
create table if not exists public.notices (
  id uuid primary key default gen_random_uuid(), title text not null, date date not null, description text,
  file_url text, published boolean not null default false, created_at timestamptz not null default now()
);

alter table public.admin_users enable row level security;
create policy "admin users read self" on public.admin_users for select to authenticated using (id=auth.uid());
create policy "admin users insert self" on public.admin_users for insert to authenticated with check (id=auth.uid());

-- Public can read only published content; admins can manage everything.

do $$ declare t text; begin
  foreach t in array array['notes','syllabus','galleries','gallery_photos','laboratories','equipment','alumni','locations','notices'] loop
    execute format('alter table public.%I enable row level security',t);
  end loop;
end $$;

create policy "public published notes" on public.notes for select using (published or public.is_admin());
create policy "admin notes insert" on public.notes for insert to authenticated with check (public.is_admin());
create policy "admin notes update" on public.notes for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin notes delete" on public.notes for delete to authenticated using (public.is_admin());

create policy "public published syllabus" on public.syllabus for select using (published or public.is_admin());
create policy "admin syllabus insert" on public.syllabus for insert to authenticated with check (public.is_admin());
create policy "admin syllabus update" on public.syllabus for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin syllabus delete" on public.syllabus for delete to authenticated using (public.is_admin());

create policy "public published galleries" on public.galleries for select using (published or public.is_admin());
create policy "admin galleries insert" on public.galleries for insert to authenticated with check (public.is_admin());
create policy "admin galleries update" on public.galleries for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin galleries delete" on public.galleries for delete to authenticated using (public.is_admin());
create policy "public gallery photos" on public.gallery_photos for select using (exists(select 1 from public.galleries g where g.id=gallery_id and (g.published or public.is_admin())));
create policy "admin gallery photos insert" on public.gallery_photos for insert to authenticated with check (public.is_admin());
create policy "admin gallery photos update" on public.gallery_photos for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin gallery photos delete" on public.gallery_photos for delete to authenticated using (public.is_admin());

create policy "public published labs" on public.laboratories for select using (published or public.is_admin());
create policy "admin labs insert" on public.laboratories for insert to authenticated with check (public.is_admin());
create policy "admin labs update" on public.laboratories for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin labs delete" on public.laboratories for delete to authenticated using (public.is_admin());

create policy "public published equipment" on public.equipment for select using (published or public.is_admin());
create policy "admin equipment insert" on public.equipment for insert to authenticated with check (public.is_admin());
create policy "admin equipment update" on public.equipment for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin equipment delete" on public.equipment for delete to authenticated using (public.is_admin());

create policy "public published alumni" on public.alumni for select using (published or public.is_admin());
create policy "admin alumni insert" on public.alumni for insert to authenticated with check (public.is_admin());
create policy "admin alumni update" on public.alumni for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin alumni delete" on public.alumni for delete to authenticated using (public.is_admin());

create policy "public published locations" on public.locations for select using (published or public.is_admin());
create policy "admin locations insert" on public.locations for insert to authenticated with check (public.is_admin());
create policy "admin locations update" on public.locations for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin locations delete" on public.locations for delete to authenticated using (public.is_admin());

create policy "public published notices" on public.notices for select using (published or public.is_admin());
create policy "admin notices insert" on public.notices for insert to authenticated with check (public.is_admin());
create policy "admin notices update" on public.notices for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin notices delete" on public.notices for delete to authenticated using (public.is_admin());

-- Public Storage bucket for website assets. Write/delete is restricted to admin users.
insert into storage.buckets (id,name,public) values ('site-assets','site-assets',true) on conflict (id) do update set public=true;
create policy "public read site assets" on storage.objects for select using (bucket_id='site-assets');
create policy "admin upload site assets" on storage.objects for insert to authenticated with check (bucket_id='site-assets' and public.is_admin());
create policy "admin update site assets" on storage.objects for update to authenticated using (bucket_id='site-assets' and public.is_admin()) with check (bucket_id='site-assets' and public.is_admin());
create policy "admin delete site assets" on storage.objects for delete to authenticated using (bucket_id='site-assets' and public.is_admin());
