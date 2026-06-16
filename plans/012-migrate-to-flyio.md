# Plan 012: Migrate from Railway to Fly.io

## Context

Railway trial credits ran out, causing the app to go down. Need to migrate to a free platform that supports:
- Always-on machines (for Solid Queue background jobs that send push notifications)
- PostgreSQL database
- Docker-based deployments
- Free tier that covers our usage (~1GB RAM, small DB)

**Chosen platform**: Fly.io (free tier: 3 VMs with 256MB RAM, 3GB storage, 160GB bandwidth)

## Motivation

- Railway trial ended → app is down
- Fly.io offers better free tier for our needs
- Background jobs need to stay running (Solid Queue for badge notifications)
- Can't use Render.com because services spin down after 15 min of inactivity

## Approach

### 1. Set up development environment
- Install rbenv and Ruby 3.3.7 on new computer
- Install bundler and project dependencies
- Install flyctl CLI

### 2. Generate new credentials
- Generate new `config/master.key` (32 characters)
- Generate new VAPID key pair using `web-push` gem
- Create new encrypted credentials file with:
  - `secret_key_base`
  - VAPID `public_key` and `private_key`

### 3. Initialize Fly.io app
```bash
flyctl launch --no-deploy --name upkeep-web
```
- Creates `fly.toml` configuration
- Provisions PostgreSQL database: upkeep-web-db
- Sets up DATABASE_URL secret

### 4. Configure Fly.io
Update `fly.toml`:
- Set `auto_stop_machines = 'off'` (keep always running)
- Set `min_machines_running = 1`
- Add `SOLID_QUEUE_IN_PUMA = "1"` env var

Set secrets:
```bash
flyctl secrets set RAILS_MASTER_KEY=$(cat config/master.key)
```

### 5. Deploy app
```bash
flyctl deploy
```

### 6. Export data from Railway
```bash
pg_dump "postgresql://postgres:...@ballast.proxy.rlwy.net:49051/railway" \
  --data-only \
  --table=areas \
  --table=equipment \
  --table=maintenance_tasks \
  --table=maintenance_logs \
  --table=supplies \
  > /tmp/upkeep_data.sql
```

### 7. Import data to Fly.io
```bash
# Proxy to Fly.io database
flyctl proxy 15432:5432 -a upkeep-web-db &

# Delete seed data
psql "postgresql://upkeep_web:...@localhost:15432/upkeep_web?sslmode=disable" <<SQL
DELETE FROM supplies;
DELETE FROM maintenance_logs;
DELETE FROM maintenance_tasks;
DELETE FROM equipment;
DELETE FROM areas;
SQL

# Import data
psql "postgresql://upkeep_web:...@localhost:15432/upkeep_web?sslmode=disable" < /tmp/upkeep_data.sql
```

### 8. Verify deployment
- Check app is accessible: `https://upkeep-web.fly.dev`
- Verify data is present (overdue tasks show up)
- Confirm machines are running: `flyctl status`

### 9. Update documentation
- `CLAUDE.md`: Update deployment workflow, production commands, platform info
- `SPEC.md`: Update platform, URL, deployment section
- `.gitignore`: Ensure `/config/master.key` is ignored
- Create this plan document

## Files Modified

### New files
- `fly.toml` — Fly.io app configuration
- `config/master.key` — New 32-character encryption key (gitignored)
- `.github/workflows/fly-deploy.yml` — Auto-deploy via GitHub Actions
- `plans/012-migrate-to-flyio.md` — This plan

### Modified files
- `config/credentials.yml.enc` — New encrypted credentials with new VAPID keys
- `.gitignore` — Added `/config/master.key`
- `CLAUDE.md` — Updated deployment workflow and production commands
- `SPEC.md` — Updated platform info, deployment section, tech stack table

## Verification

```bash
# Check app status
flyctl status

# Verify deployment
curl -I https://upkeep-web.fly.dev

# Check dashboard
curl -s https://upkeep-web.fly.dev/ | grep -o "Overdue\|Due Soon\|Nothing to do"

# Verify machines are always-on
flyctl scale show  # min_machines_running = 1, auto_stop = off
```

## Notes

- **VAPID keys changed**: Push notification subscriptions will need to be re-registered (users will see permission banner again)
- **Database connection**: Fly uses different DATABASE_URL than Railway
- **No Railway cleanup yet**: Old Railway database is still accessible (for backup) but not actively used
- **Free tier limits**: 2 machines x 256MB RAM each (we're using 1GB each currently — might need to optimize later)
- **GitHub Actions**: Requires setting `FLY_API_TOKEN` secret in repository settings for auto-deploy

## Migration Date

June 15, 2026

## Production URL

- **Old**: https://upkeep-web-production.up.railway.app (down)
- **New**: https://upkeep-web.fly.dev (live)
