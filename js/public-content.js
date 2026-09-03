(function(){
  const sb=window.rgiptSupabase;
  if(!sb) return;
  const esc=(v='')=>String(v).replace(/[&<>'"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));
  const link=(url,text='Open')=>url?`<a class="page-link" href="${esc(url)}" target="_blank" rel="noopener">${esc(text)}</a>`:'';
  const img=(url,alt='')=>url?`<img src="${esc(url)}" alt="${esc(alt)}" loading="lazy">`:'';

  async function get(table, extra=''){
    let q=sb.from(table).select('*').eq('published',true);
    if(extra) q=q.order(extra);
    const {data,error}=await q; return {data:data||[],error};
  }

  async function loadSlider(){
    const el=document.querySelector('#rgipt-home-slider'); if(!el) return;
    const dots=document.querySelector('#rgipt-slider-dots');
    const {data}=await sb.from('homepage_slides').select('*').eq('published',true).order('sort_order').order('created_at',{ascending:false});
    const slides=data?.length?data:[{title:'Mechanical Engineering',subtitle:'Department of Mechanical Engineering · Rajiv Gandhi Institute of Petroleum Technology, Jais',description:'Academic excellence, research, laboratories and student development.',image_url:'images/mechanical-hero.jpeg',link_url:'resources.html'}];
    el.innerHTML=slides.map((s,i)=>`<article class="hero-slide ${i===0?'is-active':''}" style="background-image:url('${esc(s.image_url||'images/mechanical-hero.jpeg')}')"><div class="hero-overlay"></div><div class="hero-content"><p class="hero-small">DEPARTMENT OF MECHANICAL ENGINEERING</p><h1>${esc(s.title)}</h1><p class="hero-description">${esc(s.subtitle||s.description||'')}</p>${s.link_url?`<div class="hero-buttons"><a href="${esc(s.link_url)}" class="gold-button">Explore</a><a href="resources.html" class="outline-button">Academic Resources</a></div>`:''}</div></article>`).join('');
    if(dots) dots.innerHTML=slides.map((_,i)=>`<button class="slider-dot ${i===0?'is-active':''}" type="button" data-slide="${i}" aria-label="Slide ${i+1}"></button>`).join('');
    let index=0,timer;
    const setSlide=(n)=>{const ss=[...el.querySelectorAll('.hero-slide')]; if(!ss.length)return; index=(n+ss.length)%ss.length; ss.forEach((x,i)=>x.classList.toggle('is-active',i===index)); dots?.querySelectorAll('.slider-dot').forEach((x,i)=>x.classList.toggle('is-active',i===index));};
    const next=()=>setSlide(index+1); const prev=()=>setSlide(index-1);
    document.querySelector('.slider-next')?.addEventListener('click',()=>{next();restart()});
    document.querySelector('.slider-prev')?.addEventListener('click',()=>{prev();restart()});
    dots?.querySelectorAll('.slider-dot').forEach(b=>b.addEventListener('click',()=>{setSlide(Number(b.dataset.slide));restart()}));
    const restart=()=>{clearInterval(timer); if(slides.length>1)timer=setInterval(next,5500)}; restart();
  }

  async function loadNotes(){
    const el=document.querySelector('#rgipt-notes-list'); if(!el)return;
    const {data,error}=await sb.from('notes').select('*').eq('published',true).order('semester').order('subject_code');
    if(error){el.innerHTML='<p>Notes are currently unavailable.</p>';return;}
    el.innerHTML=data?.length?data.map(n=>`<article class="resource-item"><div><h3>${esc(n.subject_code?n.subject_code+' — ': '')}${esc(n.title)}</h3><p>${esc(n.description||'')}</p><div class="resource-meta">Semester ${esc(n.semester||'—')}</div></div><div class="resource-actions">${link(n.file_url,'View / Download')}</div></article>`).join(''):'<div class="empty-state">No notes published yet.</div>';
  }
  async function loadSyllabus(){
    const el=document.querySelector('#rgipt-syllabus-list'); if(!el)return;
    const {data,error}=await sb.from('syllabus').select('*').eq('published',true).order('batch').order('semester');
    if(error){el.innerHTML='<p>Syllabus is currently unavailable.</p>';return;}
    el.innerHTML=data?.length?data.map(s=>`<article class="resource-item"><div><h3>${esc(s.title)}</h3><div class="resource-meta">Batch: ${esc(s.batch||'—')} · Semester: ${esc(s.semester||'—')}</div></div><div class="resource-actions">${link(s.file_url,'Open Syllabus')}</div></article>`).join(''):'<div class="empty-state">No syllabus files published yet.</div>';
  }
  async function loadGallery(){
    const el=document.querySelector('#rgipt-gallery-list'); if(!el)return;
    const {data,error}=await sb.from('galleries').select('*,gallery_photos(*)').eq('published',true).order('created_at',{ascending:false});
    if(error){el.innerHTML='<p>Gallery is currently unavailable.</p>';return;}
    el.innerHTML=data?.length?data.map(g=>`<article class="gallery-album"><div class="gallery-album-body"><h3>${esc(g.title)}</h3><p>${esc(g.description||'')}</p>${g.cover_image?img(g.cover_image,g.title):''}<div class="gallery-thumbs">${(g.gallery_photos||[]).slice(0,6).map(p=>`<a href="gallery.html#${esc(g.id)}"><img class="gallery-thumb" src="${esc(p.image_url)}" alt="${esc(p.caption||g.title)}" loading="lazy"></a>`).join('')}</div></div></article>`).join(''):'<div class="empty-state">No galleries published yet.</div>';
  }
  async function loadAlumni(){
    const el=document.querySelector('#rgipt-alumni-list'); if(!el)return;
    const {data,error}=await sb.from('alumni').select('*').eq('published',true).order('featured',{ascending:false}).order('batch');
    if(error){el.innerHTML='<p>Alumni information is currently unavailable.</p>';return;}
    el.innerHTML=data?.length?data.map(a=>`<article class="page-card">${img(a.photo_url,a.name)}<h3>${esc(a.name)}</h3><p><strong>Batch:</strong> ${esc(a.batch||'—')}</p><p>${esc(a.position||'')} ${a.company?'· '+esc(a.company):''}</p>${a.bio?`<p>${esc(a.bio)}</p>`:''}${link(a.linkedin_url,'Profile')}</article>`).join(''):'<div class="empty-state">No alumni profiles published yet.</div>';
  }
  async function loadLabs(){
    const el=document.querySelector('#rgipt-equipment-list'); if(!el)return;
    const {data,error}=await sb.from('equipment').select('*,laboratories(name)').eq('published',true).order('laboratory_id').order('name');
    if(error){el.innerHTML='<p>Lab equipment is currently unavailable.</p>';return;}
    el.innerHTML=data?.length?data.map(e=>`<article class="equipment-card">${img(e.image_url,e.name)}<div><div class="resource-meta">${esc(e.laboratories?.name||'Laboratory')}</div><h3>${esc(e.name)}</h3><p>${esc(e.description||'')}</p>${e.specifications?`<p><strong>Specifications:</strong> ${esc(e.specifications)}</p>`:''}${link(e.manual_url,'Equipment Manual')}</div></article>`).join(''):'<div class="empty-state">No equipment records published yet.</div>';
  }
  async function loadLocations(){
    const el=document.querySelector('#rgipt-location-list'); if(!el)return;
    const {data,error}=await sb.from('locations').select('*').eq('published',true).order('type').order('name');
    if(error){el.innerHTML='<p>Locations are currently unavailable.</p>';return;}
    el.innerHTML=data?.length?data.map(l=>`<article class="page-card"><h3>${esc(l.name)}</h3><p><strong>Type:</strong> ${esc(l.type||'—')} · <strong>Building:</strong> ${esc(l.building||'—')} · <strong>Room:</strong> ${esc(l.room||'—')}</p><p>${esc(l.description||'')}</p>${link(l.map_url,'Open Map')}</article>`).join(''):'<div class="empty-state">No locations published yet.</div>';
  }
  async function loadManagementTeam(){
    const el=document.querySelector('#rgipt-management-team'); if(!el)return;
    const {data,error}=await sb.from('management_team').select('*').eq('published',true).order('sort_order').order('created_at',{ascending:true});
    if(error || !data?.length)return;
    el.innerHTML=data.map(m=>`<article class="management-card">${m.photo_url?`<img class="management-avatar-image" src="${esc(m.photo_url)}" alt="${esc(m.name)}" loading="lazy">`:`<div class="management-avatar" aria-hidden="true">♙</div>`}<div><h3>${esc(m.name)}</h3><p>${esc(m.roll_no||'Roll No. —')} &nbsp;·&nbsp; ${esc(m.batch||'Batch —')}</p></div></article>`).join('');
  }
  async function loadNotices(){
    const el=document.querySelector('#rgipt-notice-list'); if(!el)return;
    const {data,error}=await sb.from('notices').select('*').eq('published',true).order('date',{ascending:false}).limit(50);
    // Keep the three permanent official notice links visible at all times.
    // Published CMS notices are appended below them instead of replacing them.
    if(error || !data?.length)return;
    const dynamic=document.createElement('div');
    dynamic.className='notice-dynamic-list';
    dynamic.innerHTML=data.map(n=>`<article class="page-card"><div class="category-label">${esc(n.date||'')}</div><h3>${esc(n.title)}</h3><p>${esc(n.description||'')}</p>${link(n.file_url,'Open Notice')}</article>`).join('');
    el.appendChild(dynamic);
  }
  async function loadAcademicResources(){
    const el=document.querySelector('#academic-resource-list'); if(!el)return;
    const {data,error}=await sb.from('academic_resources').select('*').eq('published',true).order('semester').order('resource_type').order('created_at',{ascending:false});
    if(error){el.innerHTML='<div class="empty-state">Academic resource database is not available yet. Run the supplied upgrade SQL.</div>';return;}
    el.innerHTML=data?.length?data.map(r=>`<article class="resource-item" data-type="${esc(r.resource_type)}"><div><div class="category-label">${esc(r.resource_type)}</div><h3>${esc(r.title)}</h3><div class="resource-meta">${r.subject_code?esc(r.subject_code)+' · ':''}${r.semester?'Semester '+esc(r.semester):''}${r.batch?' · '+esc(r.batch):''}</div><p>${esc(r.description||'')}</p></div><div class="resource-actions">${link(r.file_url,'View / Download')}${r.external_url?link(r.external_url,'External Link'):''}</div></article>`).join(''):'<div class="empty-state">No additional semester resources have been published yet.</div>';
  }
  async function loadAchievements(){
    const el=document.querySelector('#achievement-list'); if(!el)return;
    const {data,error}=await sb.from('student_achievements').select('*').eq('published',true).order('year',{ascending:false}).order('created_at',{ascending:false});
    if(error){el.innerHTML='<div class="empty-state">Achievement database is not available yet. Run the supplied upgrade SQL.</div>';return;}
    const cats=['training_placements','projects','awards'];
    const labels={training_placements:'Training & Placements',projects:'Projects',awards:'Awards & Competitions'};
    const escCard=x=>`<article class="achievement-card"><div class="category-label">${esc(x.year||'')}</div><h3>${esc(x.title)}</h3>${x.student_name?`<p><strong>Student/Team:</strong> ${esc(x.student_name)}</p>`:''}<p>${esc(x.description||'')}</p>${x.company?`<p><strong>Organisation:</strong> ${esc(x.company)}</p>`:''}${x.link_url?link(x.link_url,'More Details'):''}${x.file_url?`<br>${link(x.file_url,'Open Attachment')}`:''}</article>`;
    cats.forEach(cat=>{
      const panel=el.querySelector(`[data-panel="${cat}"] .achievement-cards`);
      if(!panel)return;
      const rows=(data||[]).filter(x=>x.category===cat);
      panel.innerHTML=rows.length?rows.map(escCard).join(''):`<div class="empty-state">No ${esc(labels[cat].toLowerCase())} records published yet. Add them from Admin.</div>`;
    });
    el.querySelectorAll('.achievement-category-tab').forEach(btn=>btn.addEventListener('click',()=>{
      const cat=btn.dataset.category;
      el.querySelectorAll('.achievement-category-tab').forEach(x=>{x.classList.toggle('active',x===btn);x.setAttribute('aria-selected',x===btn?'true':'false')});
      el.querySelectorAll('.achievement-panel').forEach(p=>p.classList.toggle('active',p.dataset.panel===cat));
    }));
  }
  async function loadEvents(){
    const el=document.querySelector('#event-list'); if(!el)return;
    const {data,error}=await sb.from('events').select('*').eq('published',true).order('event_date',{ascending:false});
    if(error){el.innerHTML='<div class="empty-state">Events database is not available yet. Run the supplied upgrade SQL.</div>';return;}
    el.innerHTML=data?.length?data.map(e=>`<article class="event-card">${img(e.image_url,e.title)}<div class="category-label">${esc(e.event_date||'')}</div><h3>${esc(e.title)}</h3><p>${esc(e.description||'')}</p>${e.location?`<p><strong>Venue:</strong> ${esc(e.location)}</p>`:''}${e.video_url?`<p>${link(e.video_url,'Watch / Event Link')}</p>`:''}${e.file_url?`<p>${link(e.file_url,'Event File')}</p>`:''}</article>`).join(''):'<div class="empty-state">No department events published yet. Events can be added from the Admin panel.</div>';
  }
  async function loadMous(){
    const el=document.querySelector('#mou-list'); if(!el)return;
    const {data,error}=await sb.from('mous').select('*').eq('published',true).order('mou_date',{ascending:false});
    if(error){el.innerHTML='<div class="empty-state">MoU database is not available yet. Run the supplied upgrade SQL.</div>';return;}
    el.innerHTML=data?.length?data.map(m=>`<article class="mou-card"><div class="category-label">${esc(m.mou_date||'')}</div><h3>${esc(m.title)}</h3><p><strong>Partner:</strong> ${esc(m.partner||'')}</p><p>${esc(m.description||'')}</p>${m.file_url?link(m.file_url,'Open MoU'):''}${m.external_url?`<br>${link(m.external_url,'More Information')}`:''}</article>`).join(''):'<div class="empty-state">No MoUs published yet.</div>';
  }
  async function loadNirf(){
    const el=document.querySelector('#nirf-list'); if(!el)return;
    const {data,error}=await sb.from('nirf_rankings').select('*').eq('published',true).order('year',{ascending:false});
    if(error){el.innerHTML='<div class="empty-state">NIRF database is not available yet. Run the supplied upgrade SQL.</div>';return;}
    el.innerHTML=data?.length?data.map(n=>`<article class="nirf-card"><div class="nirf-year">NIRF ${esc(n.year)}</div><div class="nirf-rank">#${esc(n.rank)}</div><h3>${esc(n.category||'Engineering')}</h3><p>${esc(n.description||'')}</p>${n.source_url?link(n.source_url,'Official Source'):''}</article>`).join(''):'<div class="empty-state">No NIRF records published yet.</div>';
  }
  async function loadMedia(){
    const el=document.querySelector('#media-list'); if(!el)return;
    const {data,error}=await sb.from('media_items').select('*').eq('published',true).order('created_at',{ascending:false});
    if(error){el.innerHTML='<div class="empty-state">Media database is not available yet. Run the supplied upgrade SQL.</div>';return;}
    el.innerHTML=data?.length?data.map(m=>`<article class="media-card">${m.media_type==='video'?`<video src="${esc(m.media_url)}" controls preload="metadata"></video>`:img(m.media_url,m.title)}<div class="media-card-body"><div class="category-label">${esc(m.media_type)}</div><h3>${esc(m.title)}</h3><p>${esc(m.description||'')}</p>${m.external_url?link(m.external_url,'Open Link'):''}</div></article>`).join(''):'<div class="empty-state">No media published yet.</div>';
  }

  function init(){
    loadSlider();loadNotes();loadSyllabus();loadGallery();loadAlumni();loadLabs();loadLocations();loadNotices();loadAcademicResources();loadAchievements();loadEvents();loadMous();loadNirf();loadMedia();
  }
  document.addEventListener('DOMContentLoaded',init);
  loadManagementTeam();

})();
