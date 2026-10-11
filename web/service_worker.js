const CACHE_NAME = 'quizflip';
const STATIC_ASSETS = [
  './',
  './index.html',
  './flutter_bootstrap.js',
  './flutter.js',
  './main.dart.js',
  './version.json',
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache =>
      cache.addAll(STATIC_ASSETS).catch(() => {
        // Continue even if some assets fail to install
      })
    )
  );
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(
    (async () => {
      await checkForUpdates();
      return self.clients.claim();
    })()
  );
});

async function checkForUpdates() {
  try {
    // Try to fetch version.json from the network
    const response = await fetch('/version.json', { 
      cache: 'no-store',
      method: 'GET'
    }).catch(err => {
      throw new Error('Network error: ' + err.message);
    });
    
    if (!response.ok) {
      throw new Error('Failed to fetch version.json: ' + response.status);
    }

    const onlineVersion = await response.json();
    const cache = await caches.open(CACHE_NAME);
    
    // Get cached version
    const cachedResponse = await cache.match('/version.json');
    let cachedVersion = null;
    
    if (cachedResponse) {
      try {
        cachedVersion = await cachedResponse.json();
      } catch (e) {
        cachedVersion = null;
      }
    }

    // If this is the first install or online version is newer, update cache
    if (!cachedVersion || isNewerVersion(onlineVersion.version, cachedVersion.version)) {
      try {
        await cache.put('/version.json', response.clone());
        const previousVersion = cachedVersion ? cachedVersion.version : 'none';
        console.log(`QuizFlip App: Updated from version ${previousVersion} to ${onlineVersion.version}`);
      } catch (e) {
        console.error('Failed to update cache:', e);
      }
    } else {
      console.log(`QuizFlip App: Using cached version ${cachedVersion.version}`);
    }
  } catch (error) {
    // version.json is not accessible online, use cached version
    try {
      const cache = await caches.open(CACHE_NAME);
      const cachedResponse = await cache.match('/version.json');
      
      if (cachedResponse) {
        const cachedVersion = await cachedResponse.json();
        console.log(`QuizFlip App: Running offline version ${cachedVersion.version}`);
      } else {
        console.log('QuizFlip App: No version information available');
      }
    } catch (err) {
      console.log('QuizFlip App: Unable to determine version');
    }
  }
}

function isNewerVersion(newVersion, oldVersion) {
  const newParts = newVersion.split('.').map(Number);
  const oldParts = oldVersion.split('.').map(Number);
  
  for (let i = 0; i < Math.max(newParts.length, oldParts.length); i++) {
    const newPart = newParts[i] || 0;
    const oldPart = oldParts[i] || 0;
    
    if (newPart > oldPart) return true;
    if (newPart < oldPart) return false;
  }
  
  return false;
}

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
          }).catch(err => {
            console.error('Cache put failed:', err);
          });
        }

        return response;
      }).catch(error => {
        // Network error occurred, try to return cached version
        return caches.match(event.request).then(cached => {
          if (cached) {
            return cached;
          }
          // Return a network error response
          return new Response('Network error', {
            status: 503,
            statusText: 'Service Unavailable'
          });
        });
      });
    }).catch(err => {
      console.error('Cache match failed:', err);
      return new Response('Service Worker Error', { status: 500 });
    })
  );
});
