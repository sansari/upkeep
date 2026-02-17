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

The app is deployed to Railway at https://upkeep-web-production.up.railway.app

### CI/CD

GitHub Actions automatically:
- Runs security scans (Brakeman, Bundler Audit)
- Lints code with RuboCop
- Runs the test suite
- Deploys to Railway on pushes to `main` (requires `RAILWAY_TOKEN` secret)
- Verifies deployment health and displays the live URL

### Railway Token Setup

For the deploy job to work, add a `RAILWAY_TOKEN` secret to your GitHub repository:

1. Get a Railway API token from your Railway project settings
2. Add it to GitHub repository secrets as `RAILWAY_TOKEN`
3. The CI workflow will use this to deploy on main branch pushes

## Documentation

- `CLAUDE.md` - Agent notes and conventions
- `SPEC.md` - Full application specification
- `plans/` - Feature implementation plans
