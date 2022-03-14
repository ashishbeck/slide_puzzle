'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "75c9319f0636e2f618d8aaf49b07566d",
"assets/assets/audio/bubbles.wav": "6c84c6928c691f5f8f4a074e8c5e2c54",
"assets/assets/audio/button.wav": "9e40eff333b7690bef7aa2ba4fbe0fd7",
"assets/assets/audio/button_down.wav": "3b559e271c0d3e697974544223f0fc58",
"assets/assets/audio/button_up.wav": "96e50ddcb577db2d5760cc7a59d91ae5",
"assets/assets/audio/entry.wav": "21d6c87274460b489a33ffa49a968715",
"assets/assets/audio/entry_bg.wav": "0d365c90ef5ea117369d2c2be4da3178",
"assets/assets/audio/shuffle.wav": "32de4f5d7ab6b22f440cd67231f8ddb5",
"assets/assets/audio/slide_0.wav": "c3fed663de3d259396de9fce3b2bde78",
"assets/assets/audio/slide_1.wav": "900fd0fbc146e757efd7a0523f81415d",
"assets/assets/audio/slide_2.wav": "242bb5d05473e3a6990cc5806270eb4d",
"assets/assets/audio/slide_3.wav": "f16dc3485d4220afc7c07fd60680dbc7",
"assets/assets/audio/slide_4.wav": "5d91214a258627caa3c0e3afac11cb42",
"assets/assets/audio/success.wav": "680121f1d0fc48f3dd398ed498691fd6",
"assets/assets/audio/tiles.wav": "6b41e5bedafbf1c484038498036217ae",
"assets/assets/audio/tiles_exit.wav": "d6ed7bbd5a094c2d57fc9e00bc8f0ddc",
"assets/assets/audio/whoosh.wav": "58ed93c4c1be9192ff0019e8ced884a6",
"assets/assets/fonts/ARCADE_N.TTF": "949e15e96f13a4a0945d05982690a1e2",
"assets/assets/fonts/glacial-indifference.bold.otf": "070a9269082474ecd06b6d64ebd0fa2f",
"assets/assets/fonts/glacial-indifference.regular.otf": "008080d5594fd00507fc8a2c93443d39",
"assets/assets/icons/logo.png": "0baac0dbdfee4ac18ceb78f555f8ff14",
"assets/assets/icons/twitter.png": "e0367f34cc4c33f64df8e12fb24d059a",
"assets/assets/images/01-coffee-1.gif": "cafc8826c65f635b756cbb8a154b1eb3",
"assets/assets/images/02-boombox.jpg": "75c9c0bf1263c348dd6df2f21fa397da",
"assets/assets/images/03-cat.jpg": "f8f7f034fb8d2467216efead9f7fa07b",
"assets/assets/images/04-pexels_4.jpg": "273692373183abe51bb7c7abbdfa2ad7",
"assets/assets/images/05-Woman_Pop_Art.jpg": "bd5340fe2e7a177f52c367c55c380633",
"assets/assets/images/06-pexels_5.jpg": "8eaf2bc236b35592ce21ebfec061812a",
"assets/assets/images/07-telephone.jpg": "2b38c6d5762222e1be81f4eb80895bc3",
"assets/assets/images/08-drive_in.jpg": "d6e5ef10b203e15266d430dbac5ab8e9",
"assets/assets/rive/icons.riv": "83584f1fba83353a5129531450d293bb",
"assets/assets/rive/toolbar.riv": "dcf6e72d24e4ae612a3659203168ddfd",
"assets/FontManifest.json": "d536235797b471939806c827bc6e4487",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/NOTICES": "0361e455055857169d430d113cd67346",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"canvaskit/canvaskit.js": "c2b4e5f3d7a3d82aed024e7249a78487",
"canvaskit/canvaskit.wasm": "4b83d89d9fecbea8ca46f2f760c5a9ba",
"canvaskit/profiling/canvaskit.js": "ae2949af4efc61d28a4a80fffa1db900",
"canvaskit/profiling/canvaskit.wasm": "95e736ab31147d1b2c7b25f11d4c32cd",
"favicon.ico": "fbe35961c46b82a9ec070d8fb3072005",
"icons/android-icon-144x144.png": "0e3e2760eebf638c25635429676e7e9a",
"icons/android-icon-192x192.png": "3b11c81a36f1b7b466dc6ff47e9ec25b",
"icons/android-icon-36x36.png": "ade702ef9c5bcfd42e4615d38904e9a4",
"icons/android-icon-48x48.png": "b47e4d1be97b91af5610b83b82a5c389",
"icons/android-icon-72x72.png": "29c47b74e9687d5aed376946240fa070",
"icons/android-icon-96x96.png": "cf95f4d7ba46c5fffb837cb6d08c451f",
"icons/apple-icon-114x114.png": "d7376d60b4bba58dac3fad8c45172f53",
"icons/apple-icon-120x120.png": "e82907ee290899b28c7226396bc0c2ab",
"icons/apple-icon-144x144.png": "0e3e2760eebf638c25635429676e7e9a",
"icons/apple-icon-152x152.png": "08ffcaa2956cef73d1332b06f5884e12",
"icons/apple-icon-180x180.png": "89a097b5eece696bd91587616779955d",
"icons/apple-icon-57x57.png": "3919ad4da96a3ab7259ad6bc43ebc4a1",
"icons/apple-icon-60x60.png": "b602770157fd4a3063e02d8910d90277",
"icons/apple-icon-72x72.png": "29c47b74e9687d5aed376946240fa070",
"icons/apple-icon-76x76.png": "21c7738bfe81e1e41168e09764853af3",
"icons/apple-icon-precomposed.png": "19d781102d372370fa0e4ad5deb5866e",
"icons/apple-icon.png": "19d781102d372370fa0e4ad5deb5866e",
"icons/favicon-16x16.png": "eb6b1bed756071bb23bf7a1f049b6f75",
"icons/favicon-32x32.png": "9f44114f378bf11d774bda05055f8199",
"icons/favicon-96x96.png": "cf95f4d7ba46c5fffb837cb6d08c451f",
"icons/ms-icon-144x144.png": "0e3e2760eebf638c25635429676e7e9a",
"icons/ms-icon-150x150.png": "38aceed2c86fd825d9638bf004a3580b",
"icons/ms-icon-310x310.png": "345ecd66e502447fd6f0ba67d326d022",
"icons/ms-icon-70x70.png": "50575ccdc19ea7ea6e2613dc49414f8d",
"index.html": "1d85c5b833008d93e67ab3d601a30d26",
"/": "1d85c5b833008d93e67ab3d601a30d26",
"main.dart.js": "9216d31f99b7a722df6319fe2f154b0c",
"manifest.json": "1473b545e95ca2624db24c6e87c6c80a",
"version.json": "926859e2b5c4be6f4747fc5862c07050"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
//  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
