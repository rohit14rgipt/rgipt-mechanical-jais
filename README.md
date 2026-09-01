# RGIPT Mechanical Engineering — Final Upload-Enabled CMS

This package keeps the existing RGIPT Mechanical website and adds a Supabase-powered admin CMS. The admin can upload PDFs, images and other files directly from the dashboard; public URLs are generated automatically from Supabase Storage.

## Included
- `index.html` — public website
- `admin.html` — secure admin dashboard
- `css/` — public/admin styles
- `js/` — Supabase client, public CMS loader and admin CMS
- `images/` — supplied RGIPT/faculty/department images
- `supabase/schema.sql` — initial database + RLS + storage setup
- `supabase/upgrade-upload-cms.sql` — security/upload upgrade for an already-installed earlier package

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
- Existing uploaded URLs are retained when editing unless you choose a replacement file.

## Important security note
Only the Supabase publishable key belongs in `js/config.js`. Never put a secret/service-role key in the website. Admin write access is controlled by Supabase RLS and the `admin_users` table.

## GitHub Pages
Upload the contents of `rgipt-final/` to the repository that serves the website. `admin.html` can then be opened at `/admin.html`.
