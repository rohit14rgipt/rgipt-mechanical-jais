(function () {
  const cfg = window.RGIPT_CONFIG || {};
  if (!cfg.SUPABASE_URL || cfg.SUPABASE_URL.includes('YOUR-PROJECT') || !cfg.SUPABASE_ANON_KEY || cfg.SUPABASE_ANON_KEY.includes('YOUR_')) {
    console.warn('RGIPT: Supabase is not configured. Edit js/config.js first.');
    return;
  }
  window.rgiptSupabase = window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY);
})();
