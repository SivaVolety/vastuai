# VasthuAI public profile and brand assets

The product is **VasthuAI**, https://vasthu.ai. The traditional system remains
**Vastu**. Repository/package names, API routes, existing API configuration
names and Vastu rule keys are intentionally unchanged. API hosting is configured
separately; this change does not create domains or deploy anything.

## Creator profile

Edit `lib/config/creator_profile.dart` in one place. Email, GitHub and LinkedIn
are deliberately null until verified values are supplied; unconfigured or
invalid entries are hidden. Website uses the supplied https://vasthu.ai domain.
No creator social profile or email address was inferred from a repository URL.

For a real approved photo, place it at `assets/images/siva_profile.jpg`, add
that exact path under `flutter: assets:` in `pubspec.yaml`, and set `photoAsset`
in `CreatorProfile.current`. Until then the UI shows a branded SV monogram,
not an invented portrait. Missing configured images fall back safely.

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
