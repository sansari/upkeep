# Upkeep — Agent Notes

Notes for Claude Code sessions working on this project.

## Project Overview

**Upkeep** is a personal home maintenance management app. It tracks areas of the house, equipment, recurring maintenance tasks, completion logs, and supplies.

- **Architecture**: Areas → Equipment → MaintenanceTasks → MaintenanceLogs + Supplies
- **Web app is read-only** — a status dashboard only, no forms or admin UI
- **All data management happens through Claude Code conversations** using rake tasks, Rails runner scripts, and Rails console
- **No authentication** — personal use only (user + partner)

## Tech Stack

- Ruby 3.3.7 (via rbenv), Rails 8.1.2, PostgreSQL 17
- Hotwire (Turbo + Stimulus), Tailwind CSS (tailwindcss-rails)
- Propshaft asset pipeline, importmap-rails
- Solid Queue + Solid Cache (sharing the primary database)
- Minitest for testing
- PWA with service worker and app badge support

## Key Conventions

### Data Management
- Use **rake tasks** for common operations: `rake upkeep:status`, `rake upkeep:complete_task[id]`, etc. (see `lib/tasks/upkeep.rake`)
- For complex data entry, write Ruby scripts to `tmp/` files and run with `bin/rails runner tmp/scriptname.rb` — this avoids shell quoting issues with single quotes in names like "Nida's Office"
- Never use inline `bin/rails runner '...'` with code containing single quotes

### Shell Environment
- The user's shell is zsh. Always prefix commands with `source ~/.zshrc &&` to ensure rbenv and PostgreSQL are on the PATH
- Without this, commands fall back to macOS system Ruby 2.6 which is incompatible

### Dashboard Behavior
- Shows tasks due within **2 weeks** (14 days) or overdue
- Low stock supplies only appear when their associated task is due within the window
- When nothing is due, shows "Nothing to do. Relax." with a random cat gif from `https://cataas.com/cat/gif`
- "Not Yet Scheduled" tasks are intentionally hidden from the dashboard

### Deploy Workflow
All changes should be **committed, pushed to GitHub, and deployed to Railway** before telling the user "done". The process:

```bash
# 1. Commit
git add <files> && git commit -m "message"

# 2. Push
git push origin main

# 3. Deploy (make sure upkeep-web service is linked)
cd ~/Code/upkeep
railway service upkeep-web
railway up --detach

# 4. Wait ~2.5 minutes for build, then verify
railway service status  # should show SUCCESS
curl -s -o /dev/null -w "%{http_code}" https://upkeep-web-production.up.railway.app/up  # should be 200
```

### Production Data
To update production data directly (e.g., marking tasks complete, adding equipment):
```bash
# Use the public DATABASE_URL for psql access
PROD_DB_URL="postgresql://postgres:REDACTED@ballast.proxy.rlwy.net:49051/railway"
psql "$PROD_DB_URL" -c "SQL HERE"
```

`railway run` doesn't work well locally because it uses the system Ruby 2.6 instead of rbenv.

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
  models/
    area.rb                    # has_many :equipment
    equipment.rb               # belongs_to :area, has_many :maintenance_tasks
    maintenance_task.rb        # Core model — scopes, complete!, due_status
    maintenance_log.rb         # Completion records
    supply.rb                  # Inventory tracking with low_stock?
  views/
    layouts/application.html.erb  # Nav, badge controller, permission banner
    dashboard/index.html.erb      # Main dashboard view
    pwa/
      manifest.json.erb           # PWA manifest
      service-worker.js           # Minimal service worker
  javascript/
    controllers/
      badge_controller.js         # PWA badge + notification permission
lib/tasks/
  upkeep.rake                     # Rake tasks for data management
config/
  routes.rb                       # Includes PWA routes
  database.yml                    # Production uses DATABASE_URL for all databases
db/
  seeds.rb                        # Default areas (10, but 3 were removed from DB)
```

## Railway Setup

- **Project**: upkeep
- **Services**: upkeep-web (Rails app) + Postgres
- **URL**: https://upkeep-web-production.up.railway.app
- **Environment variables**: RAILS_MASTER_KEY, RAILS_ENV=production, SOLID_QUEUE_IN_PUMA=1, DATABASE_URL (auto-set)
- **Docker entrypoint** loads Solid Queue/Cache schemas into the shared database on first boot
- **Dockerfile** uses Puma directly (not Thruster) to work with Railway's dynamic PORT

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a log of all major changes.
