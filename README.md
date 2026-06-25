# Upkeep

Personal home maintenance management app. Tracks areas of the house, equipment, recurring maintenance tasks, completion logs, and supplies.

<img width="480" height="1040" alt="IMG_6348" src="https://github.com/user-attachments/assets/5c5e9044-2e7b-4e86-82fa-5b687d060313" />
<img width="480" height="1040" alt="IMG_6347" src="https://github.com/user-attachments/assets/8d56b0b8-f3ae-413a-9c3d-a1b7933b3355" />


**All data management happens through Claude Code conversations** — the web app is a read-only status dashboard. No admin UI, no forms.

## Tech Stack

- Ruby 3.3.7, Rails 8.1.2, PostgreSQL 17
- Hotwire (Turbo + Stimulus), Tailwind CSS
- Solid Queue + Solid Cache (sharing the primary database)
- PWA with Web Push notifications (`web-push` gem, VAPID)

## Local Development

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Set up the database:
   ```bash
   bin/rails db:setup
   ```

3. Run the test suite:
   ```bash
   bin/rails test
   ```

4. Start the development server:
   ```bash
   bin/dev
   ```

## Self-Hosting on Fly.io

### 1. Install flyctl

```bash
brew install flyctl
flyctl auth login
```

### 2. Create the app

```bash
flyctl launch --no-deploy
```

This creates `fly.toml`. Edit it to set `auto_stop_machines = 'off'` and `min_machines_running = 1` if you're using Solid Queue for background jobs.

### 3. Create and attach a Postgres database

```bash
flyctl postgres create --name your-app-db
flyctl postgres attach your-app-db
```

This auto-sets the `DATABASE_URL` secret on your app.

### 4. Generate credentials

Generate a new `config/master.key` and credentials file with your VAPID keys for Web Push:

```bash
# Generate new master key and credentials
bin/rails credentials:edit

# Inside the credentials file, add:
# vapid:
#   public_key: <generate with: bin/rails runner "puts WebPush.generate_key.public_key">
#   private_key: <generate with: bin/rails runner "puts WebPush.generate_key.private_key">
```

### 5. Set secrets

```bash
flyctl secrets set RAILS_MASTER_KEY=$(cat config/master.key)
```

### 6. Deploy

```bash
flyctl deploy
```

### 7. Enter your data

Once deployed, add your home's areas, equipment, and maintenance tasks via Claude Code:

```bash
# See what's in the database
bin/rails upkeep:status

# Or write a data entry script and run it
bin/rails runner tmp/my_data.rb
```

See `lib/tasks/upkeep.rake` for available rake tasks and `CLAUDE.md` for agent conventions.

## CI/CD

GitHub Actions automatically:
- Runs security scans (Brakeman, Bundler Audit)
- Lints code with RuboCop
- Runs the test suite
- Deploys to Fly.io on pushes to `main` (requires `FLY_API_TOKEN` secret)

To enable auto-deploy:
1. Get a Fly.io API token: `flyctl auth token`
2. Add it to GitHub repository secrets as `FLY_API_TOKEN`

## Documentation

- `CLAUDE.md` — Agent notes and conventions for Claude Code sessions
- `SPEC.md` — Full application specification
- `plans/` — Feature implementation plans
