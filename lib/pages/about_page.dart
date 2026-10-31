import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/creator_profile.dart';
import '../constants/app_info.dart';
import '../theme/vastu_theme.dart';
import '../widgets/brand_components.dart';
import '../widgets/about/creator_portrait.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key, this.profile = CreatorProfile.current});
  final CreatorProfile profile;
  Future<void> _contact(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {/* fall through to local feedback */}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Unable to open this contact option on this device.')));
    }
  }

  Widget _contacts(BuildContext context, bool wide) {
    final buttons = [
      for (final entry in profile.contacts.entries)
        OutlinedButton.icon(
            style: VastuButtons.secondary(),
            onPressed: () => _contact(context, entry.value),
            icon: Icon(
                entry.key == 'Email'
                    ? Icons.mail_outline
                    : Icons.open_in_new_rounded,
                size: 18),
            label: Text(entry.key))
    ];
    return wide
        ? Wrap(
            spacing: VastuSpace.md,
            runSpacing: VastuSpace.md,
            children: buttons)
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final button in buttons)
              Padding(
                  padding: const EdgeInsets.only(bottom: VastuSpace.sm),
                  child: button)
          ]);
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        final inset = wide ? VastuSpace.section : VastuSpace.lg;
        final intro =
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionLabel('Meet the creator behind VasthuAI'),
          const SizedBox(height: VastuSpace.lg),
          Text('Built at the intersection of AI, design, and tradition.',
              style: VastuType.display.copyWith(fontSize: wide ? 52 : 36)),
          const SizedBox(height: VastuSpace.xl),
          Text(profile.name, style: VastuType.title),
          const SizedBox(height: VastuSpace.md),
          const Text(
              'A student developer exploring computer vision, machine learning, and full-stack development through traditional Vastu analysis and AI-assisted explanations.',
              style: VastuType.body),
        ]);
        Widget section(String title, Widget child) => BrandedCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title, style: VastuType.title),
                  const SizedBox(height: VastuSpace.lg),
                  child
                ]));
        return SingleChildScrollView(
            padding: EdgeInsets.all(inset),
            child: Center(
                child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (wide)
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: intro),
                            const SizedBox(width: VastuSpace.section),
                            CreatorPortrait(profile: profile, size: 280)
                          ])
                    else ...[
                      intro,
                      const SizedBox(height: VastuSpace.xl),
                      Center(
                          child: CreatorPortrait(profile: profile, size: 200))
                    ],
                    const SizedBox(height: VastuSpace.section),
                    section(
                        'About me',
                        Text(
                            "I’m ${profile.name}, a student developer interested in artificial intelligence, machine learning, computer vision, and how technology interacts with human behavior. I built VasthuAI to explore how modern AI tools could make a traditionally complex process easier to understand and interact with.",
                            style: VastuType.body)),
                    const SizedBox(height: VastuSpace.xl),
                    section(
                        'How VasthuAI was built',
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                  spacing: VastuSpace.sm,
                                  runSpacing: VastuSpace.sm,
                                  children: [
                                    for (final name in [
                                      'Flutter',
                                      'Dart',
                                      'FastAPI',
                                      'Python',
                                      'YOLO',
                                      'OpenAI',
                                      'Computer vision',
                                      'REST APIs'
                                    ])
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: VastuSpace.lg,
                                              vertical: VastuSpace.md),
                                          decoration: BoxDecoration(
                                              color: VastuColors.sage,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      VastuRadius.control)),
                                          child: Text(name,
                                              style: VastuType.section))
                                  ]),
                              const SizedBox(height: VastuSpace.xl),
                              const Text(
                                  'Stable V1 is the default detector. Experimental V2 is a research beta. A deterministic rule engine evaluates placements; an optional AI layer explains the resulting findings.',
                                  style: VastuType.body),
                            ])),
                    const SizedBox(height: VastuSpace.xl),
                    section(
                        'The project',
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final step in [
                                (
                                  Icons.image_outlined,
                                  'Floor plan',
                                  'Upload a plan and align North.'
                                ),
                                (
                                  Icons.crop_free,
                                  'Object detection',
                                  'YOLO detects supported elements.'
                                ),
                                (
                                  Icons.explore_outlined,
                                  'Directional analysis',
                                  'Locate detections relative to the prepared plan.'
                                ),
                                (
                                  Icons.rule_rounded,
                                  'Deterministic Vastu rules',
                                  'Apply only the selected tradition or custom rules.'
                                ),
                                (
                                  Icons.notes_rounded,
                                  'AI-assisted explanation',
                                  'Explain the findings and supplied remedies. AI does not decide pass/fail.'
                                )
                              ])
                                Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: VastuSpace.lg),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(step.$1,
                                              color: VastuColors.forest,
                                              size: 22),
                                          const SizedBox(width: VastuSpace.lg),
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                Text(step.$2,
                                                    style: VastuType.section),
                                                const SizedBox(
                                                    height: VastuSpace.xs),
                                                Text(step.$3,
                                                    style: VastuType.small)
                                              ]))
                                        ])),
                            ])),
                    if (profile.contacts.isNotEmpty) ...[
                      const SizedBox(height: VastuSpace.xl),
                      section('Stay in touch', _contacts(context, wide)),
                    ],
                    const SizedBox(height: VastuSpace.xl),
                    Wrap(
                        spacing: VastuSpace.xl,
                        runSpacing: VastuSpace.lg,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextButton.icon(
                              onPressed: () =>
                                  Navigator.pushReplacementNamed(context, '/'),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('Try VasthuAI')),
                          Text('VasthuAI · Version $appVersion+$appBuild',
                              style: VastuType.caption),
                        ]),
                  ]),
            )));
      });
}
