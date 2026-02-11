# Plan 004: Railway Deployment

## Context

The app is fully built and working locally with all data entered. Deploy to Railway so the user can access it on their phone. The development database data must be replicated in production.

## Steps Taken

### 1. GitHub
- Created private repo: `gh repo create upkeep --private --source=. --push`
- Repo: https://github.com/sansari/upkeep

### 2. Production Config Changes
- **`config/database.yml`**: Replaced production section to use `DATABASE_URL` for all three database roles (primary, cache, queue) — Railway provides a single PostgreSQL instance
- **`config/environments/production.rb`**: Added `config.hosts.clear` (personal app, no auth needed)
- **`Dockerfile`**: Changed CMD from Thruster (`./bin/thrust ./bin/rails server`) to Puma directly (`./bin/rails server -b 0.0.0.0`) — Railway assigns a dynamic PORT that conflicts with Thruster's port 80
- **`bin/docker-entrypoint`**: Added Ruby script to load Solid Queue and Solid Cache schemas into the shared database if their tables don't exist

### 3. Railway Setup
- Installed Railway CLI: `brew install railway`
- Created project: `railway init --name upkeep`
- Added PostgreSQL: `railway add --database postgres`
- Created web service: `railway add --service upkeep-web`
- Set DATABASE_URL reference: `railway variable set 'DATABASE_URL=${{Postgres.DATABASE_URL}}'`
- Set env vars: RAILS_MASTER_KEY, RAILS_ENV=production, SOLID_QUEUE_IN_PUMA=1

### 4. Data Migration
- Dumped local database: `pg_dump -Fc --no-owner --no-privileges upkeep_development > /tmp/upkeep_dev.dump`
- Used public DATABASE_URL to connect: `postgresql://postgres:...@ballast.proxy.rlwy.net:49051/railway`
- Cleared seeded data via psql
- Restored with: `pg_restore --data-only --disable-triggers --no-owner --no-privileges -t areas -t equipment -t maintenance_tasks -t maintenance_logs -t supplies`
- Reset sequences via psql

### 5. Issues Encountered and Fixed
- **Solid Queue crash**: `db:prepare` only loaded primary schema, not queue/cache schemas → fixed with Ruby script in docker-entrypoint
- **Host authorization 403**: `.railway.app` string and regex patterns didn't match `upkeep-web-production.up.railway.app` → fixed with `config.hosts.clear`
- **Thruster port conflict**: Thruster binds to port 80, Railway assigns dynamic PORT → fixed by using Puma directly

## Production Details
- **URL**: https://upkeep-web-production.up.railway.app
- **Database**: Single PostgreSQL shared by primary, Solid Cache, Solid Queue
- **Public DB URL**: `postgresql://postgres:REDACTED@ballast.proxy.rlwy.net:49051/railway`

## Files Modified
- `config/database.yml`
- `config/environments/production.rb`
- `Dockerfile`
- `bin/docker-entrypoint`

## Verification
- Health check: `curl https://upkeep-web-production.up.railway.app/up` → 200
- Data verified: 9 areas, 9 equipment, 9 tasks, 9 logs, 3 supplies
