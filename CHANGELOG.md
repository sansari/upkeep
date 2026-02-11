# Changelog

All notable changes to Upkeep are documented here.

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

- Created private GitHub repo (`sansari/upkeep`)
- Deployed to Railway with PostgreSQL: https://upkeep-web-production.up.railway.app
- Configured single-database setup for primary + Solid Cache + Solid Queue
- Docker entrypoint loads Solid Queue/Cache schemas on first boot
- Switched from Thruster to Puma for Railway's dynamic PORT assignment
- Migrated all development data (9 areas, 9 equipment, 9 tasks, 3 supplies, 9 logs) to production via pg_dump/pg_restore

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

- Added areas: Nida's Office, Guest Room
- Removed areas: Basement, Attic, Garage
- Renamed: Bathroom → Guest Bathroom
- Added equipment: Drinking Water Filter, Shower Head Filter, 5 Mini-Split ACs, 2 Compressors
- Configured maintenance schedules:
  - Living Room & Bedroom mini-splits: every 6 weeks
  - Studio, Nida's Office, Guest Room mini-splits: every 3 months
  - Compressors: every 6 months
  - Water filter: yearly
  - Shower head filters: every 6 months
- Added supplies with Amazon/Multipure purchase links
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
