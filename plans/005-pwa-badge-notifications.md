# Plan 005: PWA Badge Notifications

## Context

The user added the web app to their iOS home screen. They want a notification badge on the app icon when there are overdue or due-soon tasks on the dashboard. iOS 16.4+ supports `navigator.setAppBadge()` for installed PWAs.

## Approach

Rails 8 already scaffolded PWA files (manifest + service worker) — they just needed to be enabled and wired up. The badge logic runs as a Stimulus controller attached to `<body>`.

## What Was Done

### PWA Infrastructure
1. **Routes**: Added `get "manifest"` and `get "service-worker"` routes pointing to `Rails::PwaController`
2. **Manifest** (`app/views/pwa/manifest.json.erb`): Added `short_name`, fixed `theme_color` → `#dc2626`, `background_color` → `#f9fafb`
3. **Service Worker** (`app/views/pwa/service-worker.js`): Replaced commented-out code with minimal install/activate handlers

### Badge Controller (`app/javascript/controllers/badge_controller.js`)
- Registers the service worker on connect
- Fetches dashboard JSON (`/` with Accept: application/json header)
- Counts overdue + due_soon tasks
- Calls `navigator.setAppBadge(count)` or `navigator.clearAppBadge()`
- Polls every 5 minutes while app is open
- Updates on `visibilitychange` (when app returns to foreground)
- Shows one-time permission banner (iOS requires Notification permission for badges)
- Stores dismissed state in localStorage

### Layout Changes
- Added `<link rel="manifest">` tag
- Added `data-controller="badge"` to `<body>`
- Added permission banner (hidden by default, shown via JS when conditions met)

## Limitations
- Badge only updates when the app is open (no server-side push notifications)
- Requires notification permission to be granted on iOS
- User must re-add app to home screen after PWA changes to pick up new manifest

## Files Modified/Created
- `config/routes.rb` — 2 PWA routes
- `app/views/pwa/manifest.json.erb` — colors, short_name
- `app/views/pwa/service-worker.js` — minimal SW
- `app/views/layouts/application.html.erb` — manifest link, badge controller, permission banner
- `app/javascript/controllers/badge_controller.js` — **new file**
