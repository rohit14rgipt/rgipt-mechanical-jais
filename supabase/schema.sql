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

alter table public.admin_users enable row level security;
create policy "admin users read self" on public.admin_users for select to authenticated using (id=auth.uid());
create policy "admin users insert self" on public.admin_users for insert to authenticated with check (id=auth.uid());

-- Public can read only published content; admins can manage everything.

do $$ declare t text; begin
  foreach t in array array['notes','syllabus','galleries','gallery_photos','laboratories','equipment','alumni','locations','notices','management_team'] loop
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

create policy "public published management_team" on public.management_team for select using (published or public.is_admin());
create policy "admin management_team insert" on public.management_team for insert to authenticated with check (public.is_admin());
create policy "admin management_team update" on public.management_team for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin management_team delete" on public.management_team for delete to authenticated using (public.is_admin());

-- Public Storage bucket for website assets. Write/delete is restricted to admin users.
insert into storage.buckets (id,name,public) values ('site-assets','site-assets',true) on conflict (id) do update set public=true;
create policy "public read site assets" on storage.objects for select using (bucket_id='site-assets');
create policy "admin upload site assets" on storage.objects for insert to authenticated with check (bucket_id='site-assets' and public.is_admin());
create policy "admin update site assets" on storage.objects for update to authenticated using (bucket_id='site-assets' and public.is_admin()) with check (bucket_id='site-assets' and public.is_admin());
create policy "admin delete site assets" on storage.objects for delete to authenticated using (bucket_id='site-assets' and public.is_admin());
-- RGIPT Mechanical Engineering CMS — 2026 upgrade
-- Run once on an existing installation. Safe to re-run.

create extension if not exists pgcrypto;

-- Existing security fix.
drop policy if exists "admin users insert self" on public.admin_users;

-- New content tables.
create table if not exists public.academic_resources (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  resource_type text not null check (resource_type in ('mid_sem','end_sem','quiz','tutorial')),
  subject_code text,
  semester int,
  batch text,
  description text,
  file_url text,
  external_url text,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.student_achievements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null check (category in ('training_placements','projects','awards')),
  student_name text,
  year int,
  company text,
  description text,
  photo_url text,
  file_url text,
  link_url text,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  event_date date not null,
  location text,
  description text,
  image_url text,
  video_url text,
  file_url text,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.mous (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  partner text not null,
  mou_date date,
  description text,
  file_url text,
  external_url text,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.nirf_rankings (
  id uuid primary key default gen_random_uuid(),
  year int not null,
  rank int not null,
  category text not null default 'Engineering',
  description text,
  source_url text,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.homepage_slides (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text,
  description text,
  image_url text not null,
  link_url text,
  sort_order int not null default 0,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.media_items (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  media_type text not null check (media_type in ('image','video')),
  description text,
  media_url text not null,
  external_url text,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

-- RLS for new tables.
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['academic_resources','student_achievements','events','mous','nirf_rankings','homepage_slides','media_items'] LOOP
    EXECUTE format('alter table public.%I enable row level security',t);
  END LOOP;
END $$;

-- Drop/recreate policies so the upgrade is idempotent.
drop policy if exists "public published academic_resources" on public.academic_resources;
drop policy if exists "admin academic_resources insert" on public.academic_resources;
drop policy if exists "admin academic_resources update" on public.academic_resources;
drop policy if exists "admin academic_resources delete" on public.academic_resources;
create policy "public published academic_resources" on public.academic_resources for select using (published or public.is_admin());
create policy "admin academic_resources insert" on public.academic_resources for insert to authenticated with check (public.is_admin());
create policy "admin academic_resources update" on public.academic_resources for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin academic_resources delete" on public.academic_resources for delete to authenticated using (public.is_admin());

drop policy if exists "public published student_achievements" on public.student_achievements;
drop policy if exists "admin student_achievements insert" on public.student_achievements;
drop policy if exists "admin student_achievements update" on public.student_achievements;
drop policy if exists "admin student_achievements delete" on public.student_achievements;
create policy "public published student_achievements" on public.student_achievements for select using (published or public.is_admin());
create policy "admin student_achievements insert" on public.student_achievements for insert to authenticated with check (public.is_admin());
create policy "admin student_achievements update" on public.student_achievements for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin student_achievements delete" on public.student_achievements for delete to authenticated using (public.is_admin());

drop policy if exists "public published events" on public.events;
drop policy if exists "admin events insert" on public.events;
drop policy if exists "admin events update" on public.events;
drop policy if exists "admin events delete" on public.events;
create policy "public published events" on public.events for select using (published or public.is_admin());
create policy "admin events insert" on public.events for insert to authenticated with check (public.is_admin());
create policy "admin events update" on public.events for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin events delete" on public.events for delete to authenticated using (public.is_admin());

drop policy if exists "public published mous" on public.mous;
drop policy if exists "admin mous insert" on public.mous;
drop policy if exists "admin mous update" on public.mous;
drop policy if exists "admin mous delete" on public.mous;
create policy "public published mous" on public.mous for select using (published or public.is_admin());
create policy "admin mous insert" on public.mous for insert to authenticated with check (public.is_admin());
create policy "admin mous update" on public.mous for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin mous delete" on public.mous for delete to authenticated using (public.is_admin());

drop policy if exists "public published nirf_rankings" on public.nirf_rankings;
drop policy if exists "admin nirf_rankings insert" on public.nirf_rankings;
drop policy if exists "admin nirf_rankings update" on public.nirf_rankings;
drop policy if exists "admin nirf_rankings delete" on public.nirf_rankings;
create policy "public published nirf_rankings" on public.nirf_rankings for select using (published or public.is_admin());
create policy "admin nirf_rankings insert" on public.nirf_rankings for insert to authenticated with check (public.is_admin());
create policy "admin nirf_rankings update" on public.nirf_rankings for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin nirf_rankings delete" on public.nirf_rankings for delete to authenticated using (public.is_admin());

drop policy if exists "public published homepage_slides" on public.homepage_slides;
drop policy if exists "admin homepage_slides insert" on public.homepage_slides;
drop policy if exists "admin homepage_slides update" on public.homepage_slides;
drop policy if exists "admin homepage_slides delete" on public.homepage_slides;
create policy "public published homepage_slides" on public.homepage_slides for select using (published or public.is_admin());
create policy "admin homepage_slides insert" on public.homepage_slides for insert to authenticated with check (public.is_admin());
create policy "admin homepage_slides update" on public.homepage_slides for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin homepage_slides delete" on public.homepage_slides for delete to authenticated using (public.is_admin());

drop policy if exists "public published media_items" on public.media_items;
drop policy if exists "admin media_items insert" on public.media_items;
drop policy if exists "admin media_items update" on public.media_items;
drop policy if exists "admin media_items delete" on public.media_items;
create policy "public published media_items" on public.media_items for select using (published or public.is_admin());
create policy "admin media_items insert" on public.media_items for insert to authenticated with check (public.is_admin());
create policy "admin media_items update" on public.media_items for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin media_items delete" on public.media_items for delete to authenticated using (public.is_admin());

-- Storage bucket and policies.
insert into storage.buckets (id,name,public) values ('site-assets','site-assets',true)
on conflict (id) do update set public=true;
drop policy if exists "public read site assets" on storage.objects;
drop policy if exists "admin upload site assets" on storage.objects;
drop policy if exists "admin update site assets" on storage.objects;
drop policy if exists "admin delete site assets" on storage.objects;
create policy "public read site assets" on storage.objects for select using (bucket_id='site-assets');
create policy "admin upload site assets" on storage.objects for insert to authenticated with check (bucket_id='site-assets' and public.is_admin());
create policy "admin update site assets" on storage.objects for update to authenticated using (bucket_id='site-assets' and public.is_admin()) with check (bucket_id='site-assets' and public.is_admin());
create policy "admin delete site assets" on storage.objects for delete to authenticated using (bucket_id='site-assets' and public.is_admin());

-- Seed the three requested lab names if they do not already exist.
insert into public.laboratories(name,description,published)
select 'Mechanical Engineering Lab-I','Core mechanical engineering practicals and experimental learning.',true
where not exists(select 1 from public.laboratories where lower(name)=lower('Mechanical Engineering Lab-I'));
insert into public.laboratories(name,description,published)
select 'Mechanical Engineering Lab-II','Refrigeration & Air Conditioning and Internal Combustion Engine practical work.',true
where not exists(select 1 from public.laboratories where lower(name)=lower('Mechanical Engineering Lab-II'));
insert into public.laboratories(name,description,published)
select 'Mechanical Engineering Lab-III','Production-oriented practical facilities for manufacturing and production engineering.',true
where not exists(select 1 from public.laboratories where lower(name)=lower('Mechanical Engineering Lab-III'));

-- Verified NIRF 2025 record requested by the department.
insert into public.nirf_rankings(year,rank,category,description,source_url,published)
select 2025,78,'Engineering','RGIPT was ranked 78th in the NIRF 2025 Engineering category.','https://www.nirfindia.org/Rankings/2025/EngineeringRanking.html',true
where not exists(select 1 from public.nirf_rankings where year=2025 and category='Engineering');

-- Useful current collaboration records; admins may edit/delete/add them.
insert into public.mous(title,partner,mou_date,description,external_url,published)
select 'MoU between RGIPT and IIT Bombay','Indian Institute of Technology Bombay','2026-01-30','Academic, training and research cooperation between RGIPT and IIT Bombay.','https://rgipt.ac.in/site/writereaddata/siteContent/202602021719488613MOU_IIT%20Bombay.pdf',true
where not exists(select 1 from public.mous where partner='Indian Institute of Technology Bombay' and mou_date='2026-01-30');
insert into public.mous(title,partner,mou_date,description,published)
select 'MoU with Institute of Chemical Technology, Mumbai','Institute of Chemical Technology, Mumbai','2025-09-11','Collaboration in research, innovation and technology development in petroleum, energy and chemical sciences.',true
where not exists(select 1 from public.mous where partner='Institute of Chemical Technology, Mumbai' and mou_date='2025-09-11');

insert into public.homepage_slides(title,subtitle,description,image_url,link_url,sort_order,published)
select 'Mechanical Engineering','Rajiv Gandhi Institute of Petroleum Technology, Jais','Academic excellence, research, laboratories and student development.','images/mechanical-hero.jpeg','resources.html',1,true
where not exists(select 1 from public.homepage_slides where title='Mechanical Engineering');
insert into public.homepage_slides(title,subtitle,description,image_url,link_url,sort_order,published)
select 'Department Community','Mechanical Engineering · RGIPT Jais','Department activities, students and faculty.','images/department-group.jpg','gallery.html',2,true
where not exists(select 1 from public.homepage_slides where title='Department Community');
insert into public.homepage_slides(title,subtitle,description,image_url,link_url,sort_order,published)
select 'NIRF 2025 — Rank 78','Engineering Category','RGIPT achieved 78th rank in the NIRF 2025 Engineering category. Future ranking slides can be edited from Admin.','images/rgipt-logo.png','nirf.html',3,true
where not exists(select 1 from public.homepage_slides where title='NIRF 2025 — Rank 78');
update public.homepage_slides set image_url='images/mechanical-hero.jpeg' where title='NIRF 2025 — Rank 78';
