# Plan 002: Data Entry

## Context

With the app built, populate it with the user's actual home maintenance data. All data entry happens through Claude Code conversations using Rails runner scripts (written to tmp/ files to avoid shell quoting issues).

## What Was Done

### Areas
- Added: Nida's Office, Guest Room
- Removed: Basement, Attic, Garage
- Renamed: Bathroom → Guest Bathroom

### Equipment (9 items)
- Kitchen: Drinking Water Filter
- Bedroom: Shower Head Filter
- Studio, Bedroom, Nida's Office, Guest Room, Living Room: Mini-Split AC (5 units)
- Outdoor: Main Compressor (Whole House), Studio Compressor

### Maintenance Tasks (9 tasks)
- Replace filter (Kitchen water filter) — yearly
- Replace filters (Shower head) — every 6 months
- Wash mini-split filters — every 6 weeks (Living Room, Bedroom), every 3 months (Studio, Nida's Office, Guest Room)
- Hose down compressor — every 6 months (both compressors)

### Supplies (3 items)
- Multipure Aquaversa Filter CB6 (0 on hand, purchase URL)
- AquaHomeGroup 20-Stage Replacement Cartridge (1 on hand, Amazon link)
- AquaHomeGroup Vitamin C+E+A Replacement Cartridge (1 on hand, Amazon link)

### Maintenance Logs
- Logged filter washes from ~3 weeks ago for all mini-splits and compressors
- Logged water filter replacement (December 2025)
- Logged shower head filter replacement (today)

## Key Learning

- Use `tmp/` script files for Rails runner instead of inline commands — avoids shell quoting issues with names containing apostrophes (e.g., "Nida's Office")
