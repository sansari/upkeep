# Plan 001: Initial Build

## Context

Build Upkeep, a personal home maintenance management app. The user wants to track areas of the house, equipment, recurring maintenance tasks, completion history, and supplies — all managed through Claude Code conversations with a read-only web dashboard.

## Decisions

- **App name**: Upkeep
- **Architecture**: Areas → Equipment → MaintenanceTasks → MaintenanceLogs + Supplies
- **Management model**: All data entry via Claude Code (rake tasks, Rails console). No admin UI.
- **No authentication**: Personal use only (user + partner)
- **Deployment target**: Railway (from GitHub)
- **Tech**: Rails 8, Ruby 3.3+, PostgreSQL, Hotwire/Turbo, Tailwind CSS, Minitest

## What Was Done

1. Installed Ruby 3.3.7 (via rbenv), PostgreSQL 17 (via Homebrew)
2. Created Rails app: `rails new upkeep --database=postgresql --css=tailwind --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable --skip-hotwire --skip-jbuilder --skip-test --force`
3. Added turbo-rails and stimulus-rails manually (since --skip-hotwire was used)
4. Created 5 models with migrations: Area, Equipment, MaintenanceTask, MaintenanceLog, Supply
5. Created seed data for 10 default areas
6. Created rake tasks for conversational management (upkeep:status, upkeep:complete_task, etc.)
7. Created controllers: Dashboard, Areas, Equipment, MaintenanceTasks, Supplies
8. Created views with Tailwind CSS styling
9. Created test fixtures and tests (29 tests, 71 assertions)
10. Wrote SPEC.md with full specification

## Files Created/Modified

- `SPEC.md` — full specification document
- `app/models/` — all 5 models with associations, validations, scopes
- `app/controllers/` — 5 controllers with HTML + JSON responses
- `app/views/` — all views with Tailwind styling
- `db/migrate/` — 5 migration files
- `db/seeds.rb` — 10 default areas
- `lib/tasks/upkeep.rake` — rake tasks for data management
- `test/` — model and controller tests

## Verification

- `bin/rails test` — 29 tests, 71 assertions, all passing
- `bin/dev` — app runs locally at localhost:3000
