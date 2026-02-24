const CACHE_VERSION = 'v0.2.3';
const CACHE_NAME = `planmyday-${CACHE_VERSION}`;

// Only cache static assets, NOT HTML pages
const STATIC_ASSETS = [
  '/icon-192.png',
  '/icon-512.png',
  '/icon.png',
  '/icon.svg'
];

// Listen for skip waiting message from the page
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

// Install event - cache static assets only
self.addEventListener('install', (event) => {
  console.log('Service worker installing, version:', CACHE_VERSION);
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Caching static assets');
        return cache.addAll(STATIC_ASSETS);
      })
      .catch((error) => {
        console.log('Cache installation failed:', error);
      })
  );
  // Force the new service worker to activate immediately
  self.skipWaiting();
});

// Activate event - clean up ALL old caches
self.addEventListener('activate', (event) => {
  console.log('Service worker activating, version:', CACHE_VERSION);
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          // Delete ALL caches that don't match current version
          if (cacheName !== CACHE_NAME) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  // Take control of all pages immediately
  self.clients.claim();
});

// Fetch event - Network-first for everything, cache fallback for offline
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Skip non-GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  // Skip cross-origin requests
  if (url.origin !== location.origin) {
    return;
  }

  // Network-first strategy for all requests
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Only cache successful responses for static assets
        if (response.ok && isStaticAsset(url.pathname)) {
          const responseToCache = response.clone();
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseToCache);
          });
        }
        return response;
      })
      .catch(() => {
        // Network failed - try cache as fallback (offline support)
        return caches.match(event.request);
      })
  );
});

// Helper to identify static assets worth caching
function isStaticAsset(pathname) {
  return pathname.startsWith('/assets/') ||
         pathname.endsWith('.png') ||
         pathname.endsWith('.svg') ||
         pathname.endsWith('.ico') ||
         pathname.endsWith('.woff2') ||
         pathname.endsWith('.woff');
}

// Push notification event
self.addEventListener('push', (event) => {
  const options = {
    body: event.data ? event.data.text() : 'New notification from PlanMyDay',
    icon: '/icon-192.png',
    badge: '/icon-192.png',
    vibrate: [200, 100, 200],
    tag: 'planmyday-notification',
    requireInteraction: false,
    actions: [
      { action: 'view', title: 'View' },
      { action: 'dismiss', title: 'Dismiss' }
    ]
  };

  event.waitUntil(
    self.registration.showNotification('PlanMyDay', options)
  );
});

// Notification click event
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  if (event.action === 'view') {
    event.waitUntil(
      clients.openWindow('/dashboard')
    );
  }
});

// Background sync event (for offline task creation)
self.addEventListener('sync', (event) => {
  if (event.tag === 'sync-tasks') {
    event.waitUntil(syncTasks());
  }
});

async function syncTasks() {
  // This would sync any offline-created tasks when back online
  console.log('Syncing tasks...');
}
