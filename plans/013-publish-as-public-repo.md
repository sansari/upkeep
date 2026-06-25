# Plan 013 — Publish as Public GitHub Repository

## Motivation

The repo is currently private (`sansari/upkeep`). Publishing it publicly requires a security review to ensure no real credentials, personal data, or internal infrastructure details are exposed in the git history or current files.

---

## Security Findings

### 🔴 Critical — Must Fix Before Going Public

#### 1. Production Database Password in `CLAUDE.md`
Line 109 of `CLAUDE.md` contains a real Fly.io PostgreSQL credential:

```
psql "postgresql://upkeep_web:REDACTED@localhost:15432/upkeep_web?sslmode=disable"
```

The password `REDACTED` is embedded in a committed file. This means:
- It's in **git history** (commit `e4f7094` — "Migrate from Railway to Fly.io")
- Simply editing the file is not enough — the password will still be recoverable from git history

**Required actions (in this order):**
1. **Rotate the database password** on Fly.io before publishing, so the exposed credential is no longer valid
2. **Redact the password** in `CLAUDE.md`, replacing with a placeholder like `<your-db-password>`
3. **Rewrite git history** to remove the credential from past commits using `git filter-repo` — OR — accept that the commit history will contain the old (now-rotated) password (lower risk once rotated, but messier)

---

### 🟡 Medium — Should Fix

#### 2. `README.md` is Stale (References Railway)
The README still says the app is deployed to Railway. It should reflect the current Fly.io deployment.

#### 3. `CLAUDE.md` Contains Personal Context Not Useful Publicly
`CLAUDE.md` is written as internal agent notes (mentions "user + partner", personal area names, etc.). Decide: keep it as-is (shows real-world usage context) or strip personal references.

---

### 🟢 Already Fine — No Action Needed

- `config/master.key` — gitignored, never committed ✓
- `config/credentials.yml.enc` — encrypted blob, useless without master.key ✓
- `config/deploy.yml` — placeholder IPs (192.168.0.x), no real infrastructure info ✓
- `config/database.yml` — uses `ENV["DATABASE_URL"]` in production, no hardcoded credentials ✓
- `fly.toml` — app name and region, no secrets ✓
- VAPID keys — stored in encrypted credentials, not in any committed file ✓

---

## Recommended Action Plan

### Step 1 — Rotate the DB Password (Before Anything Else)
```bash
# Connect to Fly.io and change the postgres user password
flyctl ssh console -a upkeep-web-db
# Inside the console:
psql -U postgres
ALTER USER upkeep_web WITH PASSWORD 'new-strong-password-here';
\q

# Update the DATABASE_URL secret on the app
flyctl secrets set DATABASE_URL="postgresql://upkeep_web:new-strong-password@..."  -a upkeep-web
```

### Step 2 — Redact the Password in `CLAUDE.md`
Replace the literal password in the `psql` connection string with a placeholder:
```
psql "postgresql://upkeep_web:<DB_PASSWORD>@localhost:15432/upkeep_web?sslmode=disable"
```
Add a note that the password is available via `flyctl secrets list` or Fly.io dashboard.

### Step 3 — Decide on Git History
**Option A (Recommended for cleanliness):** Use `git filter-repo` to rewrite history and remove the credential from all past commits. This requires a force push and will break any existing forks/PRs.

**Option B (Acceptable if password is rotated):** Leave history as-is. The credential is no longer valid after rotation. Add a note in the commit or README that history was not rewritten. This is simpler but leaves stale credentials visible in old commits.

### Step 4 — Update `README.md`
- Change "deployed to Railway" → deployed to Fly.io at `https://upkeep-web.fly.dev`
- Update CI/CD section: remove `RAILWAY_TOKEN` references, add `FLY_API_TOKEN`
- Optionally add a brief "self-hosting" section

### Step 5 — Review `CLAUDE.md` for Personal References (Optional)
Decide whether to:
- Keep it as-is (it's genuinely useful context and personal app context is harmless)
- Remove the DB password section entirely and replace with generic instructions
- Add a note at the top explaining this file is for AI agent sessions

### Step 6 — Make Repo Public on GitHub
```bash
# Via GitHub UI: Settings → Danger Zone → Change repository visibility → Public
# Or via gh CLI:
gh repo edit sansari/upkeep --visibility public
```

### Step 7 — Verify After Going Public
- Confirm no secrets in current files: `git grep -i "password\|secret\|token\|key" -- ":(exclude)*.enc"`
- Check that the deployed app still works: `curl -s -o /dev/null -w "%{http_code}" https://upkeep-web.fly.dev/up`

---

## Files to Modify

| File | Change |
|------|--------|
| `CLAUDE.md` | Redact DB password on line 109 |
| `README.md` | Update Railway → Fly.io references |

## Files Checked — No Changes Needed

- `config/credentials.yml.enc`, `config/database.yml`, `config/deploy.yml`, `fly.toml`
- All `plans/*.md` — no credentials found
- `SPEC.md`, `CHANGELOG.md` — no credentials found

---

## Recommendation on History Rewrite

Given that this is a personal project repo and the credential will be rotated, **Option B** (leave history, rotate password) is the pragmatic choice unless you plan to share git history with others who need to trust it. If you want a clean public portfolio repo, do Option A.

---

## Risks

- If DB password is not rotated before publishing, the exposed credential is a live security risk
- History rewrite (if chosen) will invalidate any local clones — only one machine uses this, so impact is minimal
