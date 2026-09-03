# RGIPT Mechanical Engineering — Final CMS + Compact Multi-Page Website

This package keeps the existing RGIPT Mechanical website and adds a Supabase-powered admin CMS. The admin can upload PDFs, images and other files directly from the dashboard; public URLs are generated automatically from Supabase Storage.

## Included
- `index.html` — compact public homepage
- `resources.html` — semester resources: syllabus, notes, mid-sem, end-sem, quizzes and tutorials
- `gallery.html` — department galleries with zoom/full-size/download
- `notices.html` — notices and announcements
- `labs.html` — Mechanical Engineering Lab-I, II, III and equipment
- `achievements.html` — training & placements, student projects, awards
- `events.html` — department events
- `mou.html` — MoUs / collaborations
- `nirf.html` — editable NIRF ranking history
- `media.html` — published images and videos
- `admin.html` — secure admin dashboard
- `css/` — public/admin styles
- `js/` — Supabase client, public CMS loader and admin CMS
- `images/` — supplied RGIPT/faculty/department images
- `supabase/schema.sql` — initial database + RLS + storage setup
- `supabase/upgrade-upload-cms.sql` — security/upload + new-content tables for an already-installed package

## One-time setup
1. Keep your working `js/config.js` values (Supabase project URL and publishable key). The URL must be `https://YOUR-PROJECT-REF.supabase.co` without `/rest/v1/`.
2. If you already ran the earlier `schema.sql` and the dashboard works, run `supabase/upgrade-upload-cms.sql` once in Supabase SQL Editor.
3. The `site-assets` Storage bucket must exist and be public for public website files. The upgrade script creates/configures it and restricts upload/update/delete to admins.
4. Create the admin user under Supabase Authentication and insert that user UUID into `public.admin_users` from the SQL editor.
5. Open `admin.html` and sign in.

## Direct upload workflow
- Subject Notes: select a PDF/file and Save.
- Syllabus: select a PDF and Save.
- Department Gallery: upload a cover image, then use **Gallery Photos** to upload multiple photos.
- Laboratories: upload lab image.
- Lab Equipment: select a laboratory, upload equipment image and manual PDF.
- Alumni: upload a profile photo.
- Notices: upload a notice PDF/file.
- Semester Resources: add mid-semester papers, end-semester papers, quizzes and tutorial sheets.
- Student Achievements: manage training/placements, projects and awards.
- Department Events: create/edit events with images, videos and reports.
- MoUs / Collaborations: add and edit MoUs.
- NIRF Rankings: add future years and update the ranking history.
- Homepage Slider: add/reorder/publish automatic slider images.
- Media / Videos: upload and publish images/videos.
- Existing uploaded URLs are retained when editing unless you choose a replacement file.

## Important security note
Only the Supabase publishable key belongs in `js/config.js`. Never put a secret/service-role key in the website. Admin write access is controlled by Supabase RLS and the `admin_users` table.

## GitHub Pages
Upload the project contents to the repository that serves the website. `admin.html` can then be opened at `/admin.html`. The homepage is intentionally short; detailed collections are separate pages.


## Management Team database setup

If this website is being connected to an existing Supabase project, run `supabase/management-team.sql` once in the Supabase SQL Editor. This creates the editable Website Management Team table and its RLS policies. The fixed Website Developer information is intentionally not stored in this table and cannot be edited or deleted from Admin.
