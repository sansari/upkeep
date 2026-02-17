# Plan 008: Change PWA Icon to Home Emoji

## Context
The PWA app currently uses a simple red circle as its icon. User requested to change it to a home emoji to better represent the app's purpose as a home maintenance tracker.

## Approach
1. Update `public/icon.svg` to display the home emoji (🏠)
2. Regenerate `public/icon.png` (512x512) to match the new design
3. Verify the PWA manifest still references the correct icon files

## Files Modified
- `public/icon.svg` - Replaced red circle with home emoji text element
- `public/icon.png` - Regenerated 512x512 PNG with home icon design
- `plans/008-change-pwa-icon.md` - This plan document

## Implementation Details

### Icon SVG
Changed from a simple red circle to an SVG text element displaying the home emoji:
```svg
<svg width="512" height="512" xmlns="http://www.w3.org/2000/svg">
  <text x="256" y="384" font-size="400" text-anchor="middle" font-family="Arial, sans-serif">🏠</text>
</svg>
```

### Icon PNG
Generated a 512x512 PNG with a simple house icon design featuring:
- Red triangular roof
- Brown house body
- Dark brown door
- Two light blue windows
- White background

This provides a clean, recognizable home icon that works well at various sizes and on different backgrounds.

## Verification
- ✅ SVG file updated with home emoji
- ✅ PNG file regenerated (2.6KB, 512x512 RGB)
- ✅ Manifest.json.erb still correctly references `/icon.png`
- ⏳ Deployment to Railway (will happen when merged to main)

## Notes
The icon change is purely cosmetic and requires no code changes. The PWA manifest already correctly references the icon files. Once merged to main, the CI workflow will automatically deploy the changes to Railway.
