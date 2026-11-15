/* المعلّم الذكي: يحفظ واجهة التطبيق والخطوط للعمل بدون إنترنت. طلبات الذكاء الاصطناعي لا تُحفظ أبداً. */
const VERSION = 'muallim-v1.6';
const SHELL = ['./', './index.html', './manifest.webmanifest', './icons/icon-192.png', './icons/icon-512.png', './icons/apple-touch-icon.png'];
self.addEventListener('install', e => { e.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(() => self.skipWaiting())); });
self.addEventListener('activate', e => { e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== VERSION).map(k => caches.delete(k)))).then(() => self.clients.claim())); });
self.addEventListener('fetch', e => {
  const req = e.request, url = new URL(req.url);
  if (req.method !== 'GET') return;
  if (url.origin === location.origin) {
    // الصفحة: من الشبكة أولاً لتصل التحديثات، ومن الحفظ عند انقطاع الإنترنت
    if (req.mode === 'navigate') { e.respondWith(fetch(req).then(r => { const cp = r.clone(); caches.open(VERSION).then(c => c.put('./index.html', cp)); return r; }).catch(() => caches.match('./index.html'))); return; }
    e.respondWith(caches.match(req).then(r => r || fetch(req).then(n => { const cp = n.clone(); caches.open(VERSION).then(c => c.put(req, cp)); return n; })));
    return;
  }
  if (url.hostname === 'fonts.googleapis.com' || url.hostname === 'fonts.gstatic.com') {
    e.respondWith(caches.match(req).then(r => r || fetch(req).then(n => { const cp = n.clone(); caches.open(VERSION).then(c => c.put(req, cp)); return n; })));
  }
});
