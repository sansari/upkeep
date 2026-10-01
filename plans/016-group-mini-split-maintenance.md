# Plan 016 — Group Mini-Split Maintenance

## Context

Washing the five mini-split filters is performed as one household maintenance session, but Upkeep currently tracks separate tasks with different schedules.

## Change

- Create one "All Mini-Splits" equipment entry under Whole House.
- Consolidate all five wash-filter tasks into one "Wash filters" task every three months.
- Preserve existing completion logs, noting their original equipment where needed.
- Remove only the superseded task records after their logs and any supplies have been moved.

## Verification

- Confirm exactly one grouped wash-filter task remains.
- Confirm it is scheduled every three months and retains historical logs.
- Confirm the dashboard and grouped equipment page render correctly.
