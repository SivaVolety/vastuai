# VasthuAI public profile and brand assets

The product is **VasthuAI**, https://vasthu.ai. The traditional system remains
**Vastu**. Repository/package names, API routes, existing API configuration
names and Vastu rule keys are intentionally unchanged. API hosting is configured
separately; this change does not create domains or deploy anything.

## Creator profile

Edit `lib/config/creator_profile.dart` in one place. Email and GitHub remain
unset; unconfigured or invalid entries are hidden.
LinkedIn is configured as https://www.linkedin.com/in/siva-volety-108a44263.
The Stay in Touch action uses that same centralized contact URL and opens
externally. Website uses the supplied https://vasthu.ai domain.
No creator social profile or email address was inferred from a repository URL.

The production creator portrait is bundled at `assets/images/siva_profile.png`
and declared in `pubspec.yaml`. `CreatorProfile.current.photoAsset` points to it.
The approved 786 × 772 PNG is copied unchanged: no filters, retouching, or resizing.
The rounded portrait uses `BoxFit.cover` without distortion and retains a branded
SV fallback if the configured asset cannot load. Replace the file at the same
path to update the photo; no contact or layout changes are required.

## Production logo system

The approved house / compass / lotus concept is recreated as flat vector paths,
not embedded concept screenshots. The sources are:

- `assets/branding/vasthuai-logo.svg`: horizontal lockup for the navbar, shared
  About header, drawer, and other compact branding surfaces.
- `assets/branding/vasthuai-logo-stacked.svg`: stacked full logo for larger uses.
- `assets/branding/vasthuai-icon.svg`: icon-only rounded-square mark.
- `assets/branding/vasthuai-icon-maskable.svg`: solid-background icon with its
  artwork contained within the central mask-safe circle.
- `assets/branding/vasthuai-favicon.svg`: simplified small-size master.

`BrandAssets` centralizes the Flutter asset references. `VastuLogo` provides one
“VasthuAI” semantic image label; its SVG contents and standalone `VastuMark`
instances are decorative. The navbar heights and surrounding layout are unchanged.
The wordmark is outlined from the existing DM Serif Display font, whose OFL
license is bundled at `assets/fonts/DMSerifDisplay-OFL.txt`; it needs no browser
font fallback. “Vasthu” is forest green and “AI” is saffron.

Production colors: forest `#183C36`, saffron `#C78A3B`, cream `#F7F5F0`.
No texture, shadow, gradient, photograph, or remote image is embedded in the SVGs.

## Web exports and replacement

`web/icons/vasthuai-favicon.svg` is an exact copy of the small-size master.
`web/favicon.png` is its 32px raster export and `web/icons/favicon-16.png` its
16px export. The small variant retains a broad house silhouette, a single
window, north needle, simplified compass arc, and solid lotus/base; diagonal
needles, four-pane divisions, and petal cutouts are omitted at tiny sizes.

`web/manifest.json` keeps stable paths to `Icon-192.png`, `Icon-512.png`,
`Icon-maskable-192.png`, and `Icon-maskable-512.png`. Regular icons use the
rounded-square master. Maskable icons use an opaque, full forest background
and centrally inset artwork; let the host platform apply its own outer mask.
`web/index.html` references the SVG and both favicon PNG sizes; the Apple touch
icon uses `Icon-192.png`. Native launcher icons are not changed in this pass.

To replace artwork, edit the master vectors, copy the favicon SVG to its web
path, and rasterize the matching masters at their declared dimensions. Keep
manifest filenames stable. Inspect the actual 16px and 32px pixels and a fresh
browser profile after rebuilding, since old favicon caches can persist.
