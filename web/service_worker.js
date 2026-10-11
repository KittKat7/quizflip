let CACHE_NAME = 'quizflip-default'; // fallback

self.addEventListener('install', event => {
  event.waitUntil(
    // First, fetch version.json to get the version
    fetch('./version.json')
      .then(response => response.json())
      .then(config => {
        // Set cache name from version
        CACHE_NAME = `quizflip-v${config.version}`;
        console.log(`Service Worker: Using cache ${CACHE_NAME}`);
        
        // Now open the cache and add files
        return caches.open(CACHE_NAME).then(cache =>
          cache.addAll([
            './',
            './index.html',
            './flutter_bootstrap.js',
            './flutter.js',
            './main.dart.js',
            './version.json' // Cache this too!
          ])
        );
      })
      .catch(error => {
        console.error('Failed to load version.json:', error);
        // Fallback: use default CACHE_NAME
        return caches.open(CACHE_NAME).then(cache =>
          cache.addAll([
            './',
            './index.html',
            './flutter_bootstrap.js',
            './flutter.js',
            './main.dart.js',
          ])
        );
      })
  );
});

self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') {
    return;
  }

  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) {
        return cached;
      }

      return fetch(event.request).then(response => {
        if (response.ok) {
          const copy = response.clone();

          caches.open(CACHE_NAME).then(cache => {
            cache.put(event.request, copy);
          });
        }

        return response;
      });
    })
  );
});
