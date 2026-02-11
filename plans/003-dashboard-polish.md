# Plan 003: Dashboard Polish

## Context

After initial data entry, the user tested the dashboard and requested several iterations to get the notification behavior right — not too noisy, not too quiet.

## Changes Made

### Dashboard Window
- Changed from 7 days → 30 days → **2 weeks** (14 days)
- Updated `MaintenanceTask` scopes: `due_soon` uses `14.days.from_now`, `upcoming` uses `> 14.days.from_now`
- Updated `due_status` method to match

### Removed "Not Yet Scheduled" Section
- Tasks with `next_due_at: nil` are intentionally hidden from the dashboard

### Low Stock Supply Filtering
- Low stock supplies only show when their associated task is overdue or due within 2 weeks
- `DashboardController` filters: collects actionable task IDs from overdue + due_soon, then queries `Supply.low_stock.where(maintenance_task_id: actionable_task_ids)`

### "All Clear" State
- When no overdue tasks, no due_soon tasks, and no low stock supplies: show "Nothing to do. Relax." with a random cat gif from `https://cataas.com/cat/gif?t=<timestamp>`

### Log Page
- New route: `GET /log` → `MaintenanceLogsController#index`
- Reverse-chronological list of all maintenance completions with task name, location, date, time ago, and notes
- Added "Log" link to nav bar

### Nav Changes
- Removed redundant "Dashboard" link (🏠 Upkeep logo links to dashboard)
- Final nav: 🏠 Upkeep | Areas | Supplies | Log

## Files Modified

- `app/models/maintenance_task.rb` — updated scopes and due_status to 14 days
- `app/controllers/dashboard_controller.rb` — low stock filtering by actionable task IDs
- `app/views/dashboard/index.html.erb` — 2-week label, cat gif, removed "not scheduled"
- `app/controllers/maintenance_logs_controller.rb` — new controller
- `app/views/maintenance_logs/index.html.erb` — new view
- `config/routes.rb` — added log route
- `app/views/layouts/application.html.erb` — updated nav links

## Mini-Split Frequency Iterations
- Initially set Living Room & Bedroom to 6 weeks, others to 3 months
- Changed to 4 weeks for Living Room & Bedroom
- Changed back to 6 weeks for Living Room & Bedroom (final)
