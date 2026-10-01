# Changelog

All notable changes to Upkeep are documented here.

## 2026-10-01

### Added

- Added accessible, ordered reference diagrams to maintenance tasks, including AquaHomeGroup cartridge-orientation guides and shower-head opening, descaling, and reassembly instructions.

  Plan: [plans/015-maintenance-guide-images.md](plans/015-maintenance-guide-images.md)
- Added shared-password authentication for all household data and JSON endpoints, with one-year encrypted sessions, sign-out, rate-limited login attempts, and unauthenticated API protection. The health check and non-sensitive PWA assets remain public.

  Plan: [plans/014-single-user-authentication.md](plans/014-single-user-authentication.md)

### Changed

- Consolidated five mini-split filter-washing schedules into one task covering all units every three months while retaining completion history.

  Plan: [plans/016-group-mini-split-maintenance.md](plans/016-group-mini-split-maintenance.md)

### Fixed

- Removed duplicate Fly deployment from CI, retained the dedicated deploy workflow, and added manual workflow dispatch support.
- Updated Rack, Puma, Nokogiri, session, sanitizer, and WebSocket dependencies to patched releases identified by the security audit.
- Fixed CI security scans to use the repository's locked Brakeman version instead of failing solely because a newer release exists.

## 2026-06-15 — Migrate from Railway to Fly.io

Plan: [plans/012-migrate-to-flyio.md](plans/012-migrate-to-flyio.md)

- **Migrated hosting from Railway to Fly.io** (free tier)
- 2x always-on machines (shared-cpu-1x, 1GB RAM)
- Unmanaged PostgreSQL 17 database
- Auto-deploy via GitHub Actions on push to main (requires `FLY_API_TOKEN` secret)
- **Regenerated VAPID keys** for Web Push notifications (users will need to re-grant permission)
- Updated deployment documentation in CLAUDE.md and SPEC.md with Fly.io commands
- All production data successfully migrated from Railway

## 2026-02-17 — Change PWA Icon to Home Emoji

Plan: [plans/008-change-pwa-icon.md](plans/008-change-pwa-icon.md)

- Updated PWA icon from red circle to home emoji (🏠)
- Replaced `public/icon.svg` with home emoji design
- Regenerated `public/icon.png` with home icon graphic

## 2026-02-10 — Web Push Badge Notifications

Plan: [plans/007-web-push-badge-notifications.md](plans/007-web-push-badge-notifications.md)

- Added server-side Web Push notifications using VAPID authentication (`web-push` gem)
- New `PushSubscription` model stores browser push subscriptions
- Badge controller now subscribes to push after notification permission is granted
- Service worker handles `push` events to show notifications and update the app badge
- `BadgeNotificationJob` runs every 12 hours, sends push when overdue/due_soon count changes
- Job retries 3 times on failure, then self-reports via push notification
- Existing client-side polling kept as complementary mechanism

## 2026-02-10 — Documentation Workflow

Plan: [plans/006-documentation-workflow.md](plans/006-documentation-workflow.md)

- Established convention: plans committed to `plans/` directory, numbered sequentially
- Changelog entries now reference their corresponding plan
- SPEC.md updated to reflect current app behavior
- CLAUDE.md documents the plan/changelog/spec workflow for future sessions

## 2026-02-10 — PWA Badge Notifications

Plan: [plans/005-pwa-badge-notifications.md](plans/005-pwa-badge-notifications.md)

- Added PWA support: web app manifest, service worker, `navigator.setAppBadge()` integration
- App icon on iOS home screen now shows a badge count when tasks are overdue or due soon
- One-time permission banner prompts user to enable notifications (required for iOS badges)
- Badge updates on page load, every 5 minutes, and when app returns to foreground

## 2026-02-10 — Railway Deployment

Plan: [plans/004-railway-deployment.md](plans/004-railway-deployment.md)

- Created GitHub repo and deployed to Railway with PostgreSQL
- Configured single-database setup for primary + Solid Cache + Solid Queue
- Docker entrypoint loads Solid Queue/Cache schemas on first boot
- Switched from Thruster to Puma for Railway's dynamic PORT assignment
- Migrated all development data to production via pg_dump/pg_restore

## 2026-02-10 — Dashboard Polish

Plan: [plans/003-dashboard-polish.md](plans/003-dashboard-polish.md)

- Changed dashboard window from 7 days → 30 days → **2 weeks** (14 days)
- Removed "Not Yet Scheduled" section from dashboard
- Low stock supplies only appear when their associated task is due within 2 weeks
- "All clear" state shows a calming message with a random cat gif from cataas.com
- Added **Log** page: reverse-chronological list of all completed maintenance
- Removed redundant "Dashboard" nav link (🏠 Upkeep logo links to dashboard)

## 2026-02-10 — Data Entry

Plan: [plans/002-data-entry.md](plans/002-data-entry.md)

- Added areas: Office, Guest Room
- Removed areas: Basement, Attic, Garage
- Renamed: Bathroom → Guest Bathroom
- Added equipment: Drinking Water Filter, Shower Head Filter, 5 Mini-Split ACs, 2 Compressors
- Configured maintenance schedules:
  - Living Room & Bedroom mini-splits: every 6 weeks
  - Studio, Office, Guest Room mini-splits: every 3 months
  - Compressors: every 6 months
  - Water filter: yearly
  - Shower head filters: every 6 months
- Added supplies with purchase links
- Logged initial maintenance completions

## 2026-02-10 — Initial Build

Plan: [plans/001-initial-build.md](plans/001-initial-build.md)

- Rails 8.1.2, Ruby 3.3.7, PostgreSQL 17
- Data model: Area → Equipment → MaintenanceTask → MaintenanceLog + Supply
- Read-only web dashboard (all data management via Claude Code conversations)
- Rake tasks for common operations (`upkeep:status`, `upkeep:complete_task`, etc.)
- JSON API on all controllers via `respond_to` blocks
- Tailwind CSS styling, Hotwire (Turbo + Stimulus)
- 29 tests, 71 assertions — all passing
- Seeded 10 default home areas
