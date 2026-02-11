# Plan 006: Documentation Workflow

## Context

Plans were living in Claude Code's internal `~/.claude/plans/` directory and not committed to the repo. The user wants plans in the repo for reference, changelogs to reference plans, SPEC.md to stay in sync with the app, and CLAUDE.md to document all of this.

## What Was Done

1. Created `plans/` directory in the repo root
2. Reconstructed and committed plans for all major phases (001–006)
3. Updated `CHANGELOG.md` to reference plan files in each entry
4. Updated `SPEC.md` to reflect current app behavior (2-week window, log page, PWA, etc.)
5. Added "Documentation Workflow" section to `CLAUDE.md` establishing conventions:
   - Plans go in `plans/NNN-short-name.md`, committed with the feature
   - Changelog updated after every functional change, referencing the plan
   - SPEC.md updated after every functional change to reflect current behavior
   - CLAUDE.md updated with new conventions or workflow changes

## Files Modified/Created
- `plans/001-initial-build.md` through `plans/006-documentation-workflow.md` — new files
- `CHANGELOG.md` — plan references added
- `SPEC.md` — updated to match current app
- `CLAUDE.md` — documentation workflow section added
