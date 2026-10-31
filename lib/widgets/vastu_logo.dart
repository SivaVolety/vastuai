import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/brand_assets.dart';
import '../theme/vastu_theme.dart';

class VastuLogo extends StatelessWidget {
  const VastuLogo({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'VasthuAI',
        image: true,
        child: ExcludeSemantics(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
          VastuMark(size: compact ? 34 : 40),
          const SizedBox(width: 10),
          Text('VasthuAI',
              style: VastuType.title
                  .copyWith(fontSize: compact ? 26 : 29, letterSpacing: -0.6)),
        ])),
      );
}

/// Standalone vector mark for compact brand placements.
class VastuMark extends StatelessWidget {
  const VastuMark({super.key, this.size = 40});
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(BrandAssets.mark,
      width: size, height: size, excludeFromSemantics: true);
}
