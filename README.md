# Upkeep

Personal home maintenance management app. Tracks areas of the house, equipment, recurring maintenance tasks, completion logs, and supplies.

## Tech Stack

- Ruby 3.3.7, Rails 8.1.2, PostgreSQL 17
- Hotwire (Turbo + Stimulus), Tailwind CSS
- Solid Queue + Solid Cache
- PWA with Web Push notifications

## Setup

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

## Deployment

The app is deployed to [Fly.io](https://fly.io) at https://upkeep-web.fly.dev

### CI/CD

GitHub Actions automatically:
- Runs security scans (Brakeman, Bundler Audit)
- Lints code with RuboCop
- Runs the test suite
- Deploys to Fly.io on pushes to `main` (requires `FLY_API_TOKEN` secret)
- Verifies deployment health

### Fly.io Setup

For the deploy job to work, add a `FLY_API_TOKEN` secret to your GitHub repository:

1. Get a Fly.io API token: `flyctl auth token`
2. Add it to GitHub repository secrets as `FLY_API_TOKEN`
3. The CI workflow will use this to deploy on main branch pushes

See `fly.toml` for machine configuration and `plans/012-migrate-to-flyio.md` for full setup notes.

## Documentation

- `CLAUDE.md` - Agent notes and conventions
- `SPEC.md` - Full application specification
- `plans/` - Feature implementation plans
