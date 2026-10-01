# Plan 015 — Maintenance Guide Images

## Context

The AquaHomeGroup shower-filter replacement task needs clearer opening, descaling, and reassembly instructions. Filter orientation is difficult to describe with text alone, especially while handling wet parts.

## Approach

- Add reusable ordered instruction images to maintenance tasks.
- Render responsive reference diagrams beneath task instructions and include them in task JSON.
- Add original diagrams for the AquaHomeGroup shower system:
  - Vitamin C+E+A cartridge with the AquaHome logo side facing outward toward the spray face.
  - 20-stage cartridge with the mesh end facing incoming water from the shower arm.
- Update the production shower-filter task with concise opening, soaking, cleaning, orientation, and reassembly guidance.

## Files Modified

- `app/models/maintenance_task.rb`
- `app/models/maintenance_task_image.rb`
- `app/controllers/maintenance_tasks_controller.rb`
- `app/views/maintenance_tasks/show.html.erb`
- `db/migrate/*_create_maintenance_task_images.rb`
- `public/guides/aquahome-*.svg`
- Fixtures and controller/model tests
- `SPEC.md`
- `CHANGELOG.md`
- `CLAUDE.md`

## Verification

- Run migrations and the full Rails test suite.
- Run RuboCop and Brakeman.
- Verify the task HTML renders ordered, accessible diagrams and JSON contains their metadata.
- Inspect the shower-filter task at mobile viewport size.
- Deploy, update the production task data, and verify production health and authenticated rendering.
