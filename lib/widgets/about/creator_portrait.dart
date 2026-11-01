import 'package:flutter/material.dart';
import '../../config/creator_profile.dart';
import '../../theme/vastu_theme.dart';

class CreatorPortrait extends StatelessWidget {
  const CreatorPortrait({super.key, required this.profile, required this.size});
  final CreatorProfile profile;
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
        image: true,
        label: profile.photoAsset == null
            ? '${profile.name}, creator. Profile photo not yet configured.'
            : 'Portrait of ${profile.name}, creator of VasthuAI',
        child: ExcludeSemantics(
            child: Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(VastuSpace.sm),
                decoration: BoxDecoration(
                    color: VastuColors.surface,
                    borderRadius: BorderRadius.circular(VastuRadius.card),
                    border: Border.all(color: VastuColors.border),
                    boxShadow: VastuTheme.shadows),
                child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(VastuRadius.card - VastuSpace.sm),
                    child: profile.photoAsset == null
                        ? _placeholder()
                        : Image.asset(profile.photoAsset!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder())))),
      );
  Widget _placeholder() => ColoredBox(
      color: VastuColors.sage,
      child: Stack(alignment: Alignment.center, children: [
        Text('SV',
            style: VastuType.display
                .copyWith(fontSize: size * .32, color: VastuColors.forest)),
        const Positioned(
            right: VastuSpace.lg,
            top: VastuSpace.lg,
            child: Icon(Icons.north_east_rounded,
                size: 24, color: VastuColors.terracotta)),
        const Positioned(
            bottom: VastuSpace.lg,
            child: Text('THE CREATOR', style: VastuType.caption)),
      ]));
}
