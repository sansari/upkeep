# Plan 002: Data Entry

## Context

With the app built, populate it with the user's actual home maintenance data. All data entry happens through Claude Code conversations using Rails runner scripts (written to tmp/ files to avoid shell quoting issues).

## What Was Done

### Areas
- Added: Office, Guest Room
- Removed: Basement, Attic, Garage
- Renamed: Bathroom → Guest Bathroom

### Equipment (9 items)
- Kitchen: Drinking Water Filter
- Bedroom: Shower Head Filter
- Studio, Bedroom, Office, Guest Room, Living Room: Mini-Split AC (5 units)
- Outdoor: Main Compressor (Whole House), Studio Compressor

### Maintenance Tasks (9 tasks)
- Replace filter (Kitchen water filter) — yearly
- Replace filters (Shower head) — every 6 months
- Wash mini-split filters — every 6 weeks (Living Room, Bedroom), every 3 months (Studio, Office, Guest Room)
- Hose down compressor — every 6 months (both compressors)

### Supplies (3 items)
- Water Filter Replacement Cartridge (0 on hand, purchase URL)
- Shower Filter Replacement Cartridge, Stage 1 (1 on hand, purchase URL)
- Shower Filter Replacement Cartridge, Stage 2 (1 on hand, purchase URL)

### Maintenance Logs
- Logged filter washes from ~3 weeks ago for all mini-splits and compressors
- Logged water filter replacement (December 2025)
- Logged shower head filter replacement (today)

## Key Learning

- Use `tmp/` script files for Rails runner instead of inline commands — avoids shell quoting issues with names containing apostrophes (e.g., "Partner's Office")
