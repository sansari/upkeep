# Upkeep — Home Maintenance Manager

## 1. Overview

**Upkeep** is a personal home maintenance tracking application. It helps you stay on top of recurring maintenance tasks — like washing HVAC filters, replacing water filters, and seasonal upkeep — by organizing everything around the physical areas of your home and the equipment in each area.

### Core Concept

The data hierarchy is:

```
House
└── Area (Kitchen, Bedroom, Outdoor, Whole House, ...)
    └── Equipment (Mini-Split AC, Water Filter, Shower Head, ...)
        └── Maintenance Task (Wash filters every 2 months, Replace filter yearly, ...)
            ├── Maintenance Log (history of completions)
            ├── Supply (filters, parts — with purchase links and inventory)
            └── Instruction Image (ordered visual maintenance guidance)
```

### Management Model

**Data entry and updates happen through Claude Code conversations.** You tell Claude what you did, what equipment you have, or what supplies you bought, and it creates/updates records via rake tasks or Rails console commands.

**The web app is a read-only status dashboard.** It shows you what's due, what's overdue, what supplies are running low, and lets you drill into areas, equipment, and task details — including instructions and purchase links. It does not have forms or admin functionality.

### Users

This is a personal app for 1–2 people (you and your partner). A shared single-user password protects the app at its Fly.io-provided URL; there are no user accounts or public registration.

---

## 2. Tech Stack

| Component       | Choice                          | Notes                                              |
|-----------------|---------------------------------|----------------------------------------------------|
| Framework       | Ruby on Rails 8                 | Latest stable release                              |
| Ruby            | 3.3+                            |                                                    |
| Database        | PostgreSQL 17                   | Fly.io unmanaged Postgres                          |
| Frontend        | Hotwire (Turbo + Stimulus)      | Server-rendered, SPA-like interactivity            |
| CSS             | Tailwind CSS                    | Utility-first, mobile-friendly                     |
| Testing         | Minitest                        | Rails default                                      |
| Background Jobs | Solid Queue                     | Rails 8 default; used for periodic status checks   |
| Deployment      | Fly.io                          | Auto-deploy from GitHub via GitHub Actions         |
| API             | JSON (via `respond_to`)         | All controllers serve HTML + JSON from day one     |

---

## 3. Data Model

### 3.1 Area

Represents a physical area of the house.

| Column       | Type    | Notes                                          |
|--------------|---------|-------------------------------------------------|
| `id`         | bigint  | Primary key                                     |
| `name`       | string  | Required. E.g., "Kitchen", "Whole House"        |
| `icon`       | string  | Optional. Emoji or icon class for display        |
| `is_default` | boolean | `true` for seed data, `false` for user-created   |
| `position`   | integer | For ordering areas in the UI                     |
| `created_at` | datetime|                                                 |
| `updated_at` | datetime|                                                 |

**Associations:** `has_many :equipment` (dependent: destroy)

**Seed data:** Kitchen, Bathroom, Bedroom, Living Room, Outdoor, Garage, Basement, Attic, Studio, Whole House

### 3.2 Equipment

A device, appliance, or system within an area that requires maintenance.

| Column          | Type    | Notes                                         |
|-----------------|---------|------------------------------------------------|
| `id`            | bigint  | Primary key                                    |
| `area_id`       | bigint  | Foreign key → Area. Required.                  |
| `name`          | string  | Required. E.g., "Mini-Split AC"                |
| `description`   | text    | Optional. General description                   |
| `model_number`  | string  | Optional. For reference                         |
| `manufacturer`  | string  | Optional. For reference                         |
| `purchase_date` | date    | Optional. When the equipment was bought/installed|
| `notes`         | text    | Optional. Freeform notes                        |
| `created_at`    | datetime|                                                |
| `updated_at`    | datetime|                                                |

**Associations:**
- `belongs_to :area`
- `has_many :maintenance_tasks` (dependent: destroy)

### 3.3 MaintenanceTask

A recurring (or one-time) maintenance action for a piece of equipment.

| Column              | Type     | Notes                                                  |
|---------------------|----------|--------------------------------------------------------|
| `id`                | bigint   | Primary key                                            |
| `equipment_id`      | bigint   | Foreign key → Equipment. Required.                     |
| `name`              | string   | Required. E.g., "Wash filters"                         |
| `instructions`      | text     | Optional. Detailed how-to (can be lengthy)             |
| `frequency_value`   | integer  | Required. E.g., `2` (for "every 2 months")            |
| `frequency_unit`    | string   | Required. One of: `days`, `weeks`, `months`, `years`   |
| `last_completed_at` | datetime | Null if never completed                                |
| `next_due_at`       | datetime | Computed: `last_completed_at + frequency`. Null if never set |
| `priority`          | string   | Default: `medium`. One of: `low`, `medium`, `high`, `urgent` |
| `notes`             | text     | Optional. Freeform notes                               |
| `created_at`        | datetime |                                                        |
| `updated_at`        | datetime |                                                        |

**Associations:**
- `belongs_to :equipment`
- `has_many :maintenance_logs` (dependent: destroy)
- `has_many :supplies` (dependent: destroy)
- `has_many :instruction_images` (ordered by position, dependent: destroy)

**Validations:**
- `frequency_unit` must be one of: `days`, `weeks`, `months`, `years`
- `priority` must be one of: `low`, `medium`, `high`, `urgent`

**Scopes:**
- `overdue` — `where("next_due_at < ?", Time.current)`
- `due_soon` — `where(next_due_at: Time.current..14.days.from_now)`
- `upcoming` — `where("next_due_at > ?", 14.days.from_now)`

**Methods:**
- `complete!(notes: nil)` — Creates a MaintenanceLog entry, sets `last_completed_at` to now, recalculates `next_due_at`, decrements associated supplies.
- `due_status` — Returns `:overdue`, `:due_soon`, `:upcoming`, or `:not_scheduled`
- `frequency_description` — Returns human-readable string like "Every 2 months"

### 3.4 MaintenanceTaskImage

An ordered reference diagram displayed with a maintenance task's instructions.

| Column                | Type     | Notes                                                   |
|-----------------------|----------|---------------------------------------------------------|
| `maintenance_task_id` | bigint   | Foreign key → MaintenanceTask. Required.                |
| `image_path`          | string   | Required local SVG path under `/guides/`.               |
| `alt_text`            | string   | Required accessible description.                       |
| `caption`             | string   | Optional visible explanation.                           |
| `position`            | integer  | Display order. Default: 0.                              |

### 3.5 MaintenanceLog

A record of a completed maintenance action. This is the history.

| Column                | Type     | Notes                                    |
|-----------------------|----------|------------------------------------------|
| `id`                  | bigint   | Primary key                              |
| `maintenance_task_id` | bigint   | Foreign key → MaintenanceTask. Required. |
| `completed_at`        | datetime | Required. When the task was completed.   |
| `notes`               | text     | Optional. E.g., "Used last spare filter" |
| `created_at`          | datetime |                                          |
| `updated_at`          | datetime |                                          |

**Associations:** `belongs_to :maintenance_task`

### 3.6 Supply

Something consumed during maintenance — filters, parts, cleaning products, etc. Tracks inventory and provides purchase links for easy reordering.

| Column                | Type     | Notes                                                   |
|-----------------------|----------|---------------------------------------------------------|
| `id`                  | bigint   | Primary key                                             |
| `maintenance_task_id` | bigint   | Foreign key → MaintenanceTask. Required.                |
| `name`                | string   | Required. E.g., "HVAC Filter 16x25x1"                  |
| `purchase_url`        | string   | Optional. Direct link to buy (Amazon, Home Depot, etc.) |
| `quantity_on_hand`    | integer  | Default: 0. How many spares are available.              |
| `quantity_per_use`    | integer  | Default: 1. How many consumed per maintenance cycle.    |
| `unit_price`          | decimal  | Optional. Price per unit for reference.                  |
| `notes`               | text     | Optional. E.g., "Bought 2-pack, used 1"                |
| `created_at`          | datetime |                                                         |
| `updated_at`          | datetime |                                                         |

**Associations:** `belongs_to :maintenance_task`

**Methods:**
- `low_stock?` — Returns `true` if `quantity_on_hand < quantity_per_use`
- `decrement_stock!` — Reduces `quantity_on_hand` by `quantity_per_use` (floors at 0)

---

## 4. Web Dashboard

The web app is **read-only** and **mobile-friendly**. The only form is the password sign-in screen.

### 4.0 Authentication — `GET/POST/DELETE /session`

- All household data, JSON endpoints, task completion actions, and push-subscription endpoints require authentication.
- Browser requests redirect to the password sign-in page; unauthenticated JSON requests return `401 Unauthorized`.
- A successful sign-in creates an encrypted, HTTP-only, same-site cookie lasting one year.
- Changing `UPKEEP_PASSWORD` invalidates existing authentication cookies.
- Sign-in attempts are limited to 10 per IP address every 3 minutes.
- The health check, PWA manifest, service worker, and static icons remain public and contain no household data.

### 4.1 Home Dashboard — `GET /`

The landing page shows an at-a-glance summary of what needs attention within the next **2 weeks**:

**Overdue Tasks** (red/urgent section)
- Lists all tasks where `next_due_at < now`
- Each entry shows: task name, equipment name, area name, how overdue it is (e.g., "3 days overdue")

**Due Within 2 Weeks** (yellow/attention section)
- Tasks due within the next 14 days
- Shows: task name, equipment, due date

**Low Stock Supplies** (orange section)
- Only shown when the associated task is overdue or due within 2 weeks
- Shows: supply name, equipment/task it's for, quantity on hand, purchase link

**All Clear State**
- When no tasks are overdue, due soon, or have low stock supplies: shows "Nothing to do. Relax." with a random cat gif from `https://cataas.com/cat/gif`

**Note:** "Not Yet Scheduled" tasks (where `next_due_at` is null) are intentionally hidden from the dashboard.

### 4.2 Areas Index — `GET /areas`

Grid or list of all areas with summary stats:
- Area name and icon
- Number of equipment items
- Number of overdue/due soon tasks
- Click through to area detail

### 4.3 Area Detail — `GET /areas/:id`

Shows all equipment in this area:
- Equipment name, description
- Task status summary (e.g., "2 overdue, 1 due soon, 3 upcoming")
- Click through to equipment detail

### 4.4 Equipment Detail — `GET /equipment/:id`

Full view of a piece of equipment:
- Equipment info (name, description, model number, manufacturer, purchase date, notes)
- **Maintenance Tasks** — each task with:
  - Name, priority badge, status badge (overdue/due soon/upcoming)
  - Next due date
  - Frequency description
  - Click through to task detail
- **Supplies** — table of supplies with name, quantity on hand, quantity per use, purchase link

### 4.5 Task Detail — `GET /tasks/:id`

Full view of a maintenance task:
- Task name, priority, status, frequency
- Next due date, last completed date
- **Instructions** — full how-to text (can be multiple paragraphs)
- **Reference images** — ordered, captioned maintenance diagrams when configured
- **Supplies needed** — with quantities, stock status, purchase links
- **History** — chronological list of MaintenanceLog entries (date + notes)

### 4.6 Supplies Index — `GET /supplies`

All supplies across all equipment, sortable/filterable:
- Supply name
- Equipment and task it belongs to
- Quantity on hand / quantity per use
- Low stock indicator
- Purchase link (opens in new tab)

### 4.7 Maintenance Log — `GET /log`

Reverse-chronological list of all completed maintenance tasks:
- Task name and location (equipment → area)
- Completion date and time ago
- Notes (if any)

### 4.8 JSON API

Every route above also responds to `.json` format, returning the same data as JSON after authentication. Unauthenticated JSON requests return `401 Unauthorized`. This is for:
- Future iOS app
- Direct `curl` access
- Claude Code API calls if needed

---

## 5. Conversational Management

All write operations are performed through Claude Code conversations, using rake tasks or Rails console commands.

### 5.1 Rake Tasks

```
rake upkeep:status
```
Prints a summary of overdue and due-soon tasks to the terminal.

```
rake upkeep:complete_task[TASK_ID]
```
Marks a task as completed: creates a MaintenanceLog, recalculates `next_due_at`, decrements supply inventory.

```
rake upkeep:add_equipment[AREA_NAME,EQUIPMENT_NAME]
```
Creates a new equipment record under the specified area (finds area by name).

```
rake upkeep:add_task[EQUIPMENT_ID,NAME,FREQ_VALUE,FREQ_UNIT]
```
Creates a new maintenance task for the given equipment.

```
rake upkeep:add_supply[TASK_ID,NAME,PURCHASE_URL,QUANTITY]
```
Adds a supply to a maintenance task.

```
rake upkeep:update_stock[SUPPLY_ID,QUANTITY]
```
Sets the `quantity_on_hand` for a supply.
```

### 5.2 Rails Console

For anything not covered by rake tasks, Claude Code can use `rails console` to directly create or update records. Examples:

```ruby
# Add equipment with full details
e = Equipment.create!(
  area: Area.find_by!(name: "Bathroom"),
  name: "Shower Head",
  manufacturer: "AquaBliss",
  notes: "Installed January 2025"
)

# Add a task with instructions
t = MaintenanceTask.create!(
  equipment: e,
  name: "Replace filters",
  frequency_value: 6,
  frequency_unit: "months",
  priority: "medium",
  instructions: <<~INSTRUCTIONS
    1. Unscrew the shower head from the hose
    2. Remove the old sediment filter (white disc)
    3. Remove the old carbon filter (black cylinder)
    4. Insert new carbon filter first, then sediment filter
    5. Screw shower head back on and run water for 30 seconds
  INSTRUCTIONS
)

# Add supplies
Supply.create!(
  maintenance_task: t,
  name: "Sediment Filter (SF100)",
  purchase_url: "https://amazon.com/dp/EXAMPLE1",
  quantity_on_hand: 1,
  quantity_per_use: 1,
  notes: "Bought 2-pack, used 1"
)
```

### 5.3 JSON API

All resources are available via JSON endpoints for programmatic access:

- `GET /areas.json`
- `GET /areas/:id.json`
- `GET /equipment/:id.json`
- `GET /tasks/:id.json`
- `GET /supplies.json`
- `POST /tasks/:id/complete.json` — mark a task complete (returns updated task)
- Standard REST endpoints for creating/updating resources

---

## 6. Key Behaviors

### Due Date Computation

When a task is completed (via `complete!` method):

1. `last_completed_at` is set to `Time.current`
2. `next_due_at` is calculated as `Time.current + frequency_value.send(frequency_unit)`
   - E.g., for "every 2 months": `Time.current + 2.months`
3. A `MaintenanceLog` entry is created with the completion timestamp and optional notes
4. Associated supplies are decremented

### Supply Inventory Management

- Each supply tracks `quantity_on_hand` and `quantity_per_use`
- When a task is completed, each of its supplies is decremented: `quantity_on_hand -= quantity_per_use` (floors at 0)
- Supplies where `quantity_on_hand < quantity_per_use` are flagged as "low stock" on the dashboard
- Purchase links open directly in a new browser tab for one-click reordering

### Status Categories

Tasks are categorized by their `next_due_at` relative to now:

| Status       | Condition                               | Display    |
|--------------|-----------------------------------------|------------|
| `overdue`    | `next_due_at` is in the past            | Red badge  |
| `due_soon`   | `next_due_at` is within 14 days         | Yellow badge|
| `upcoming`   | `next_due_at` is more than 14 days away | Green badge|
| `not_scheduled` | `next_due_at` is null (never completed, no initial date set) | Gray badge (hidden from dashboard) |

---

## 7. Deployment

### Platform: Fly.io

- **Deploy:** `flyctl deploy` or GitHub Actions (push to `main` with `FLY_API_TOKEN` secret)
- **Machines:** 2x shared-cpu-1x, 1GB RAM, always-on (`auto_stop_machines = 'off'`)
- **Database:** Unmanaged PostgreSQL 17, single database shared by primary, Solid Cache, Solid Queue
- **No custom domain needed**
- **Authentication:** Shared password supplied through the `UPKEEP_PASSWORD` Fly secret

### Environment Variables

| Variable              | Purpose                                       | Set via             |
|-----------------------|-----------------------------------------------|---------------------|
| `DATABASE_URL`        | PostgreSQL connection                         | Auto-set by Fly     |
| `RAILS_MASTER_KEY`    | Decrypts `config/credentials.yml.enc`        | `flyctl secrets`    |
| `UPKEEP_PASSWORD`     | Shared password for web and JSON access       | `flyctl secrets`    |
| `SOLID_QUEUE_IN_PUMA` | `1` — runs Solid Queue inside Puma process   | `fly.toml`          |

### Deployment Files

- `fly.toml` — Fly.io configuration (machines, regions, env vars, HTTP service)
- `Dockerfile` — multi-stage build, Ruby 3.3.7-slim, Puma on dynamic PORT
- `bin/docker-entrypoint` — runs `db:prepare` + loads Solid Queue/Cache schemas
- `config/database.yml` — production uses `DATABASE_URL` for all three database roles
- `.github/workflows/fly-deploy.yml` — Auto-deploy on push to main (requires `FLY_API_TOKEN` secret)

---

## 8. PWA Support

The app is a Progressive Web App that can be added to the iOS/Android home screen.

### Manifest
- Served publicly at `/manifest.json` via `Rails::PwaController`; it contains no household data
- `display: standalone` for full-screen app experience
- App name: "Upkeep", theme color: `#dc2626` (red)

### Service Worker
- Served publicly at `/service-worker.js` so installation and push handling work before sign-in
- Minimal service worker — install + activate + push handlers
- No complex caching (this is a simple status dashboard)

### App Icon Badge
- Uses `navigator.setAppBadge()` API (iOS 16.4+)
- Badge count = number of overdue + due_soon tasks
- Updates on page load, every 5 minutes, and on `visibilitychange`
- Requires notification permission on iOS (one-time permission banner shown)

### Web Push Notifications
- Server-side push via `web-push` gem with VAPID authentication
- After granting notification permission, the browser subscribes to push and sends the subscription to `POST /push_subscriptions`
- `BadgeNotificationJob` runs every 12 hours via Solid Queue recurring schedule
- Sends push notification when overdue + due_soon task count changes
- Service worker receives push, shows notification, and updates app badge — even when app is closed
- Job retries 3 times on failure, then sends a failure notification via push
- Expired/invalid subscriptions are automatically cleaned up

---

## 9. Future Enhancements

These are documented for future reference but are **not yet built**:

- **Multi-user accounts** — Replace the shared password with individual accounts and household task assignment
- **Native iOS app** — Separate repository, Swift/SwiftUI, consumes the JSON API
- **Photo attachments** — Active Storage for photos of equipment, issues, completed work
- **Email/push notifications** — Alerts when tasks become overdue or due soon
- **Cost tracking** — Track actual costs per maintenance, annual reports
- **Calendar view** — Visual calendar showing upcoming maintenance
- **Admin web forms** — If conversational management proves insufficient for some workflows

---

## 10. Development Setup

### Prerequisites

- Ruby 3.3+
- Rails 8
- PostgreSQL (running locally)
- Node.js (for Tailwind CSS build)

### Getting Started

```bash
# Clone the repo
git clone <repo-url> ~/Code/upkeep
cd ~/Code/upkeep

# Install dependencies
bundle install

# Create and migrate database
bin/rails db:create db:migrate db:seed

# Start the server
bin/dev
```

### Seed Data

The seed file (`db/seeds.rb`) creates the predefined areas:

- Kitchen, Bathroom, Bedroom, Living Room, Outdoor, Garage, Basement, Attic, Studio, Whole House

No equipment or tasks are seeded — those are added through conversations.

### Running Tests

```bash
bin/rails test
```
