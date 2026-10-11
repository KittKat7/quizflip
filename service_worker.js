const CACHE_NAME = 'quizflip';
const VERSION_URL = './version.json';

const APP_FILES = [
  './',
  './index.html',
  './flutter_bootstrap.js',
  './flutter.js',
  './main.dart.js',
  './version.json',
];

// Fetch a resource and save it to the cache.
async function fetchAndCache(cache, request) {
  const response = await fetch(request);

  if (response.ok) {
    await cache.put(request, response.clone());
  }

  return response;
}

// Read the version from the network, falling back to the cache.
async function getAppVersion(cache) {
  try {
    const response = await fetch(
      new Request(VERSION_URL, {
        cache: 'no-store',
      })
    );

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const onlineVersion = await response.json();

    // Save the latest version.json for offline use.
    await cache.put(
      VERSION_URL,
      new Response(JSON.stringify(onlineVersion), {
        headers: {
          'Content-Type': 'application/json',
        },
      })
    );

    return onlineVersion.version;
  } catch (error) {
    console.log(
      'Unable to retrieve version.json online; using cached version.',
      error
    );

    const cachedResponse = await cache.match(VERSION_URL);

    if (cachedResponse) {
      try {
        const cachedVersion = await cachedResponse.json();
        return cachedVersion.version;
      } catch (error) {
        console.error('Cached version.json is invalid.', error);
      }
    }

    return 'unknown';
  }
}

// Called when the service worker is first installed.
self.addEventListener('install', event => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE_NAME);

      // Install the essential Flutter application files.
      await cache.addAll(APP_FILES);

      // Activate the new worker without waiting for old tabs to close.
      await self.skipWaiting();
    })()
  );
});

// Take control of open pages after activation.
self.addEventListener('activate', event => {
  event.waitUntil(
    (async () => {
      await self.clients.claim();
    })()
  );
});

// Check for an online version whenever a controlled page opens
// or navigates to a new document.
self.addEventListener('message', event => {
  if (event.data?.type === 'CHECK_VERSION') {
    event.waitUntil(checkVersionAndUpdate());
  }
});

async function checkVersionAndUpdate() {
  const cache = await caches.open(CACHE_NAME);
  const previousResponse = await cache.match(VERSION_URL);

  let previousVersion = null;

  if (previousResponse) {
    try {
      previousVersion = (await previousResponse.json()).version;
    } catch (_) {
      // An invalid cached version will be replaced if online access works.
    }
  }

  const currentVersion = await getAppVersion(cache);

  if (currentVersion !== 'unknown') {
    console.log(`QuizFlip app version being used: ${currentVersion}`);
  } else {
    console.log('QuizFlip app version being used: unknown');
  }

  if (
    currentVersion !== 'unknown' &&
    previousVersion !== null &&
    currentVersion !== previousVersion
  ) {
    console.log(
      `App version changed from ${previousVersion} to ${currentVersion}.`
    );

    // Refresh the application resources that have already been cached.
    await refreshCachedResources(cache);
  }
}

// Refresh previously cached files from the server.
async function refreshCachedResources(cache) {
  const requests = await cache.keys();

  await Promise.all(
    requests.map(async request => {
      // Do not refresh version.json here; it has already been updated.
      if (new URL(request.url).pathname.endsWith('/version.json')) {
        return;
      }

      try {
        const response = await fetch(
          new Request(request, { cache: 'no-store' })
        );

        if (response.ok) {
          await cache.put(request, response);
        }
      } catch (_) {
        // Preserve the existing cached resource when offline.
      }
    })
  );
}

self.addEventListener('fetch', event => {
  const request = event.request;

  if (request.method !== 'GET') {
    return;
  }

  const url = new URL(request.url);

  // Only handle requests from this app's own origin.
  if (url.origin !== self.location.origin) {
    return;
  }

  // version.json must be checked online, with cached fallback.
  if (url.pathname.endsWith('/version.json')) {
    event.respondWith(
      (async () => {
        const cache = await caches.open(CACHE_NAME);

        try {
          return await fetchAndCache(cache, request);
        } catch (_) {
          const cached = await cache.match(request);
          return cached || new Response(
            JSON.stringify({
              app_name: 'quizflip',
              version: 'unknown',
              package_name: 'quizflip',
            }),
            {
              headers: { 'Content-Type': 'application/json' },
            }
          );
        }
      })()
    );

    return;
  }

  // Cache-first for offline support; save newly requested resources.
  event.respondWith(
    (async () => {
      const cache = await caches.open(CACHE_NAME);
      const cached = await cache.match(request);

      if (cached) {
        return cached;
      }

      try {
        return await fetchAndCache(cache, request);
      } catch (_) {
        // Offline and not cached.
        if (request.mode === 'navigate') {
          const fallback = await cache.match('./index.html');

          if (fallback) {
            return fallback;
          }
        }

        return new Response('Offline: resource not cached.', {
          status: 503,
          statusText: 'Service Unavailable',
        });
      }
    })()
  );
});