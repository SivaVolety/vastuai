import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/brand_assets.dart';

/// Horizontal lockup: outlined serif text remains crisp without a font load.
class VastuLogo extends StatelessWidget {
  const VastuLogo({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Semantics(
      label: 'VasthuAI',
      image: true,
      child: ExcludeSemantics(
          child: SvgPicture.asset(BrandAssets.logo,
              width: compact ? 158 : 180,
              height: compact ? 52 : 60,
              fit: BoxFit.contain,
              excludeFromSemantics: true)));
}

/// Decorative mark. Its containing surface supplies semantics when necessary.
class VastuMark extends StatelessWidget {
  const VastuMark({super.key, this.size = 40});
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(BrandAssets.mark,
      width: size, height: size, excludeFromSemantics: true);
}
