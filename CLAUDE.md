# Upkeep — Agent Notes

Notes for Claude Code sessions working on this project.

## Project Overview

**Upkeep** is a personal home maintenance management app. It tracks areas of the house, equipment, recurring maintenance tasks, completion logs, and supplies.

- **Architecture**: Areas → Equipment → MaintenanceTasks → MaintenanceLogs + Supplies
- **Web app is read-only** — a status dashboard only, no forms or admin UI
- **All data management happens through Claude Code conversations** using rake tasks, Rails runner scripts, and Rails console
- **Single-user authentication** — a shared password from `UPKEEP_PASSWORD` protects all household data and JSON endpoints

## Tech Stack

- Ruby 3.3.7 (via rbenv), Rails 8.1.2, PostgreSQL 17
- Hotwire (Turbo + Stimulus), Tailwind CSS (tailwindcss-rails)
- Propshaft asset pipeline, importmap-rails
- Solid Queue + Solid Cache (sharing the primary database)
- Minitest for testing
- PWA with service worker, app badge, and Web Push notifications
- `web-push` gem for VAPID-based push notifications

## Key Conventions

### Data Management
- Use **rake tasks** for common operations: `rake upkeep:status`, `rake upkeep:complete_task[id]`, etc. (see `lib/tasks/upkeep.rake`)
- For complex data entry, write Ruby scripts to `tmp/` files and run with `bin/rails runner tmp/scriptname.rb` — this avoids shell quoting issues with single quotes in names (e.g. `"Partner's Office"`)
- Never use inline `bin/rails runner '...'` with code containing single quotes
- **Always use tmp/ scripts for data entry**, never inline runner — even for simple inserts, to avoid quoting bugs

### Database Schema (for data entry)

**areas**: `id`, `name` (unique), `icon`, `position`, `is_default`

**equipment**: `id`, `area_id` (FK), `name`, `manufacturer`, `model_number`, `description`, `notes`, `purchase_date`
- Note: column is `manufacturer`, not `brand`

**maintenance_tasks**: `id`, `equipment_id` (FK), `name`, `frequency_value` (int), `frequency_unit` (string, e.g. `"months"`), `last_completed_at`, `next_due_at`, `instructions`, `notes`

**maintenance_logs**: `id`, `maintenance_task_id` (FK), `completed_at`, `notes`

**supplies**: `id`, `maintenance_task_id` (FK), `name`, `quantity_on_hand` (default 0), `quantity_per_use` (default 1), `unit_price`, `purchase_url`, `notes`

### Checking Current Data
To see areas, equipment, and task status, use the rake task:
```bash
rake upkeep:status
```
Or query directly: `bin/rails runner 'Area.all.each { |a| puts "#{a.id}: #{a.name}" }'`

### Shell Environment
- Always ensure your Ruby version manager (rbenv, rvm, etc.) is active before running commands
- On macOS with rbenv via Homebrew, prefix commands with `source ~/.zshrc &&` if the correct Ruby isn't on PATH

### Authentication
- `ApplicationController` requires an encrypted authentication cookie for all application routes
- Browser requests redirect to `/session/new`; unauthenticated JSON requests return `401`
- The login password comes only from the `UPKEEP_PASSWORD` environment variable and is never committed
- Authentication lasts one year; changing the password invalidates existing cookies
- `/up`, the PWA manifest/service worker, and static icons remain public

### Dashboard Behavior
- Shows tasks due within **2 weeks** (14 days) or overdue
- Low stock supplies only appear when their associated task is due within the window
- When nothing is due, shows "Nothing to do. Relax." with a random cat gif from `https://cataas.com/cat/gif`
- "Not Yet Scheduled" tasks are intentionally hidden from the dashboard

### Deploy Workflow
All changes should be **committed, pushed to GitHub, and deployed to Fly.io** before telling the user "done". The process:

```bash
# 1. Commit
git add <files> && git commit -m "message"

# 2. Push
git push origin main

# 3. Deploy
flyctl deploy

# 4. Wait ~2-3 minutes for build, then verify
flyctl status  # should show running machines
curl -s -o /dev/null -w "%{http_code}" https://<your-app>.fly.dev/up  # should be 200
```

**Auto-deploy**: GitHub Actions automatically deploys to Fly.io on every push to main (requires FLY_API_TOKEN secret in GitHub).

### Production Data & Commands
**Never lose production data.** Always verify that migrations are additive (CREATE TABLE, ADD COLUMN) before deploying. Never run destructive SQL (DROP, TRUNCATE, DELETE without WHERE) against production. When in doubt, ask first.

**To run Rails commands against production** via Fly SSH:
```bash
flyctl ssh console -C "bin/rails runner 'RUBY CODE'"
```

**For rake tasks against production:**
```bash
flyctl ssh console -C "bin/rails upkeep:status"
```

**For direct database access** (run migrations, console, etc):
```bash
# SSH into app machine
flyctl ssh console

# Or proxy to database and connect locally
# Find your DB app name in fly.toml or: flyctl postgres list
flyctl proxy 15432:5432 -a <your-db-app> &
# Connection string available via: flyctl ssh console --command 'printenv DATABASE_URL'
psql "<DATABASE_URL with localhost:15432>"
```

For complex Ruby scripts, write to `tmp/` and run with `flyctl ssh console -C "bin/rails runner tmp/scriptname.rb"` to avoid shell quoting issues.

## File Structure (Key Files)

```
app/
  controllers/
    dashboard_controller.rb    # Main dashboard with JSON API
    areas_controller.rb
    equipment_controller.rb
    maintenance_tasks_controller.rb
    maintenance_logs_controller.rb  # Log page
    supplies_controller.rb
    push_subscriptions_controller.rb  # Web Push subscription management
    sessions_controller.rb            # Shared-password login/logout
  models/
    area.rb                    # has_many :equipment
    equipment.rb               # belongs_to :area, has_many :maintenance_tasks
    maintenance_task.rb        # Core model — scopes, complete!, due_status
    maintenance_log.rb         # Completion records
    supply.rb                  # Inventory tracking with low_stock?
    push_subscription.rb       # Web Push subscription (endpoint, keys)
  views/
    layouts/application.html.erb    # Nav, badge controller, permission banner
    layouts/authentication.html.erb # Standalone login layout
    sessions/new.html.erb           # Password sign-in screen
    dashboard/index.html.erb        # Main dashboard view
    pwa/
      manifest.json.erb           # PWA manifest
      service-worker.js           # Service worker with push handlers
  javascript/
    controllers/
      badge_controller.js         # PWA badge + push subscription
  jobs/
    badge_notification_job.rb   # Recurring job: push badge count changes
lib/tasks/
  upkeep.rake                     # Rake tasks for data management
config/
  routes.rb                       # Includes PWA routes
  recurring.yml                   # Solid Queue recurring jobs
  database.yml                    # Production uses DATABASE_URL for all databases
db/
  seeds.rb                        # Default areas (10, but 3 were removed from DB)
plans/
  001-initial-build.md            # Plan for each major feature/change
  002-data-entry.md
  ...
SPEC.md                           # Full app specification (keep in sync!)
CHANGELOG.md                      # All notable changes with plan references
CLAUDE.md                         # This file — agent instructions
```

## Fly.io Setup

See `fly.toml` for machine configuration. Key points:

- **App name / URL**: Set in `fly.toml`. Run `flyctl launch` to provision a new app.
- **Database**: Attach an unmanaged Postgres app via `flyctl postgres create` + `flyctl postgres attach`
- **Required secrets**: `RAILS_MASTER_KEY` and `UPKEEP_PASSWORD`, both set with `flyctl secrets`
- **`DATABASE_URL`** is auto-set by Fly when you attach a Postgres database
- **VAPID keys** for Web Push are stored in Rails credentials (encrypted), not env vars — generate with `bin/rails credentials:edit`
- **`SOLID_QUEUE_IN_PUMA=1`** is set in `fly.toml` env section
- **Docker entrypoint** loads Solid Queue/Cache schemas into the shared database on first boot
- **Dockerfile** uses Puma directly (not Thruster) to work with Fly's dynamic PORT

## Documentation Workflow

Every functional change must update **all three** of these:

### 1. Plans → `plans/NNN-short-name.md`
- Before implementing non-trivial features, write a plan file
- Plans are numbered sequentially (001, 002, ...)
- Include: context/motivation, approach, files modified, verification steps
- **Commit the plan with the feature** — plans are part of the repo

### 2. Changelog → `CHANGELOG.md`
- Update after every functional change
- Each entry references its plan: `Plan: [plans/NNN-name.md](plans/NNN-name.md)`
- Reverse chronological order

### 3. Spec → `SPEC.md`
- Update after every functional change to reflect current app behavior
- The spec should always describe the **current** state of the app, not the original design
- Key sections to keep in sync: dashboard behavior, routes, scopes, deployment config

### 4. This file → `CLAUDE.md`
- Update with new conventions, file structure changes, or workflow notes
- This is what future Claude Code sessions read first
