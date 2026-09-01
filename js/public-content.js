(function () {
  const sb = window.rgiptSupabase;
  if (!sb) return;

  const esc = (v='') => String(v).replace(/[&<>'"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));
  const link = (url, text) => url ? `<a class="rgipt-dynamic-link" href="${esc(url)}" target="_blank" rel="noopener">${esc(text || 'Open')}</a>` : '';
  const img = (url, alt='') => url ? `<img src="${esc(url)}" alt="${esc(alt)}" loading="lazy">` : '<div class="rgipt-placeholder">RGIPT Mechanical Engineering</div>';
  const card = (title, body, extra='') => `<article class="rgipt-dynamic-card"><h3>${esc(title)}</h3><div>${body}</div>${extra}</article>`;

  async function loadNotes() {
    const el = document.querySelector('#rgipt-notes-list'); if (!el) return;
    const { data, error } = await sb.from('notes').select('*').eq('published', true).order('semester').order('subject_code');
    if (error) { el.innerHTML = '<p>Notes are currently unavailable.</p>'; return; }
    el.innerHTML = data?.length ? data.map(n => card(`${n.subject_code ? n.subject_code + ' — ' : ''}${n.title}`, `<p>${esc(n.description || '')}</p><p class="rgipt-meta">Semester ${esc(n.semester || '—')}</p>${link(n.file_url,'View / Download Notes')}`)).join('') : '<p>No notes published yet.</p>';
  }

  async function loadSyllabus() {
    const el = document.querySelector('#rgipt-syllabus-list'); if (!el) return;
    const { data, error } = await sb.from('syllabus').select('*').eq('published', true).order('batch').order('semester');
    if (error) { el.innerHTML = '<p>Syllabus is currently unavailable.</p>'; return; }
    el.innerHTML = data?.length ? data.map(s => card(s.title, `<p>Batch: ${esc(s.batch || '—')} · Semester: ${esc(s.semester || '—')}</p>${link(s.file_url,'Open Syllabus')}`)).join('') : '<p>No syllabus files published yet.</p>';
  }

  async function loadGallery() {
    const el = document.querySelector('#rgipt-gallery-list'); if (!el) return;
    const { data, error } = await sb.from('galleries').select('*,gallery_photos(*)').eq('published', true).order('created_at',{ascending:false});
    if (error) { el.innerHTML = '<p>Gallery is currently unavailable.</p>'; return; }
    const supplied = `<article class="rgipt-gallery-card"><div class="rgipt-gallery-image"><img src="images/department-group.jpg" alt="RGIPT Mechanical Engineering department group photograph" loading="lazy"></div><h3>Department Gallery</h3><p>Department photograph and highlights. More photos can be added from the Admin panel.</p></article>`;
    const dynamic = data?.length ? data.map(g => `<article class="rgipt-gallery-card"><div class="rgipt-gallery-image">${img(g.cover_image,g.title)}</div><h3>${esc(g.title)}</h3><p>${esc(g.description || '')}</p><div class="rgipt-photo-grid">${(g.gallery_photos||[]).map(p=>`<a href="${esc(p.image_url)}" target="_blank" rel="noopener"><img src="${esc(p.image_url)}" alt="${esc(p.caption||g.title)}" loading="lazy"></a>`).join('')}</div></article>`).join('') : '';
    el.innerHTML = supplied + dynamic;
  }

  async function loadAlumni() {
    const el = document.querySelector('#rgipt-alumni-list'); if (!el) return;
    const { data, error } = await sb.from('alumni').select('*').eq('published', true).order('featured',{ascending:false}).order('batch');
    if (error) { el.innerHTML = '<p>Alumni information is currently unavailable.</p>'; return; }
    el.innerHTML = data?.length ? data.map(a => `<article class="rgipt-alumni-card">${img(a.photo_url,a.name)}<div><h3>${esc(a.name)}</h3><p><strong>Batch:</strong> ${esc(a.batch||'—')}</p><p>${esc(a.position||'')} ${a.company ? '· '+esc(a.company):''}</p>${a.bio?`<p>${esc(a.bio)}</p>`:''}${link(a.linkedin_url,'Profile')}</div></article>`).join('') : '<p>No alumni profiles published yet.</p>';
  }

  async function loadLabs() {
    const el = document.querySelector('#rgipt-equipment-list'); if (!el) return;
    const { data, error } = await sb.from('equipment').select('*,laboratories(name)').eq('published', true).order('laboratory_id').order('name');
    if (error) { el.innerHTML = '<p>Lab equipment is currently unavailable.</p>'; return; }
    el.innerHTML = data?.length ? data.map(e => `<article class="rgipt-equipment-card">${img(e.image_url,e.name)}<div><p class="rgipt-meta">${esc(e.laboratories?.name || 'Laboratory')}</p><h3>${esc(e.name)}</h3><p>${esc(e.description||'')}</p>${e.specifications?`<p><strong>About / Specifications:</strong> ${esc(e.specifications)}</p>`:''}<div>${link(e.manual_url,'Equipment Manual')}</div></div></article>`).join('') : '<p>No equipment records published yet.</p>';
  }

  async function loadLocations() {
    const el = document.querySelector('#rgipt-location-list'); if (!el) return;
    const { data, error } = await sb.from('locations').select('*').eq('published', true).order('type').order('name');
    if (error) { el.innerHTML = '<p>Locations are currently unavailable.</p>'; return; }
    el.innerHTML = data?.length ? data.map(l => card(l.name, `<p><strong>Type:</strong> ${esc(l.type||'—')} · <strong>Building:</strong> ${esc(l.building||'—')} · <strong>Room:</strong> ${esc(l.room||'—')}</p><p>${esc(l.description||'')}</p>${l.map_url?link(l.map_url,'Open Map'):''}`)).join('') : '<p>No locations published yet.</p>';
  }

  async function loadNotices() {
    const el = document.querySelector('#rgipt-notice-list'); if (!el) return;
    const { data, error } = await sb.from('notices').select('*').eq('published', true).order('date',{ascending:false}).limit(10);
    if (error) { el.innerHTML = '<p>Notices are currently unavailable.</p>'; return; }
    el.innerHTML = data?.length ? data.map(n => card(n.title, `<p class="rgipt-meta">${esc(n.date||'')}</p><p>${esc(n.description||'')}</p>${link(n.file_url,'Open Notice')}`)).join('') : '<p>No notices published yet.</p>';
  }

  async function init() {
    await Promise.allSettled([loadNotes(),loadSyllabus(),loadGallery(),loadAlumni(),loadLabs(),loadLocations(),loadNotices()]);
  }
  document.addEventListener('DOMContentLoaded', init);
})();
