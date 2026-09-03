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

-- Optional laboratory-level manual link, used by the public lab details viewer.
alter table public.laboratories add column if not exists manual_url text;

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


-- Website management team. The developer credit remains hard-coded in index.html and is not editable from Admin.
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
create policy "public published management_team" on public.management_team for select using (published or public.is_admin());
create policy "admin management_team insert" on public.management_team for insert to authenticated with check (public.is_admin());
create policy "admin management_team update" on public.management_team for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "admin management_team delete" on public.management_team for delete to authenticated using (public.is_admin());
