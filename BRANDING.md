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

## Mark replacement

The single editable mark source is `web/icons/vastuai-mark.svg`.
`BrandAssets.mark` in `lib/config/brand_assets.dart` points to that source;
`VastuMark` renders it through the bundled SVG renderer. `web/index.html` also
uses the same SVG as its scalable favicon. Keep the stable filenames when
replacing the visual mark so references and deployed manifests stay compatible.
The artwork is unchanged in Phase 4.

References: `web/index.html` uses `web/favicon.png` (32),
`web/icons/favicon-16.png`, the SVG, and `Icon-192.png` for Apple touch.
`web/manifest.json` uses `Icon-192.png`, `Icon-512.png`,
`Icon-maskable-192.png` and `Icon-maskable-512.png`.
Regenerate all PNG variants from the selected replacement SVG, with the maskable
mark inside the central safe zone. Use a strong simple silhouette at 16px;
avoid fine architectural details. Forest #183C36 and terracotta #D97757 remain
current mark colors. No new final logo was introduced in Phase 4.

Replace the master SVG, then regenerate its PNG size variants. The in-app mark
updates automatically from that same asset; no painter geometry needs editing.
