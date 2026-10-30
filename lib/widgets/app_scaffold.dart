import 'package:flutter/material.dart';
import '../theme/vastu_theme.dart';
import 'brand_components.dart';
import 'processing_mode_selector.dart';
import 'vastu_logo.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  const AppScaffold({super.key, required this.title, required this.body});

  static const _primary = [
    ('Analyze', '/', Icons.space_dashboard_outlined),
    ('History', '/history', Icons.history_rounded),
    ('About', '/about', Icons.info_outline_rounded),
    ('Settings', '/settings', Icons.settings_outlined),
  ];
  static const _more = [
    ('Help', '/help', Icons.help_outline_rounded),
    ('Advanced settings', '/advanced', Icons.tune_rounded),
    ('Release Notes', '/releases', Icons.notes_rounded),
  ];

  void _go(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= VastuLayout.desktop;
    final current = ModalRoute.of(context)?.settings.name;
    final inset = desktop
        ? (width >= 1280 ? VastuSpace.page : VastuSpace.xxl)
        : VastuSpace.lg;
    return Theme(
      data: VastuTheme.light,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              desktop ? VastuLayout.navHeight : VastuLayout.mobileNavHeight),
          child: DecoratedBox(
            decoration: const BoxDecoration(
                color: VastuColors.background,
                border: Border(bottom: BorderSide(color: VastuColors.border))),
            child: SafeArea(
                bottom: false,
                child: Center(
                    child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: VastuLayout.contentMax + 2 * VastuSpace.page),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: inset),
                    child: Row(children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(VastuSpace.xs),
                          minimumSize: const Size(0, VastuControl.target),
                        ).copyWith(
                            side: VastuButtons.border(Colors.transparent)),
                        onPressed: () => _go(context, '/'),
                        child: VastuLogo(compact: !desktop),
                      ),
                      if (desktop) ...[
                        const SizedBox(width: VastuSpace.xxl),
                        ..._primary.map((item) => BrandNavItem(
                              label: item.$1,
                              active: current == item.$2,
                              onPressed: () => _go(context, item.$2),
                            )),
                        const Spacer(),
                        const SizedBox(width: VastuSpace.lg),
                        const SizedBox(
                            width: 224,
                            child: ProcessingModeSelector(
                                compact: true, showManage: false)),
                        const SizedBox(width: VastuSpace.sm),
                        PopupMenuButton<String>(
                          tooltip: 'More',
                          icon:
                              const Icon(Icons.help_outline_rounded, size: 20),
                          style: VastuButtons.icon(quiet: true),
                          onSelected: (route) => _go(context, route),
                          itemBuilder: (_) => _more
                              .map((item) => PopupMenuItem(
                                    value: item.$2,
                                    child: Row(children: [
                                      Icon(item.$3, size: 18),
                                      const SizedBox(width: VastuSpace.md),
                                      Text(item.$1)
                                    ]),
                                  ))
                              .toList(),
                        ),
                      ] else ...[
                        const Spacer(),
                        Builder(
                            builder: (context) => IconButton(
                                  tooltip: 'Open navigation menu',
                                  onPressed: () =>
                                      Scaffold.of(context).openDrawer(),
                                  icon: const Icon(Icons.menu_rounded),
                                )),
                      ],
                    ]),
                  ),
                ))),
          ),
        ),
        drawer: desktop
            ? null
            : Drawer(
                backgroundColor: VastuColors.background,
                child: SafeArea(
                    child: ListView(
                  padding: const EdgeInsets.all(VastuSpace.lg),
                  children: [
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: VastuSpace.xl),
                        child: VastuLogo()),
                    ...[..._primary, ..._more].map((item) => ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(VastuRadius.control)),
                          selected: current == item.$2,
                          selectedTileColor: VastuColors.sage,
                          leading: Icon(item.$3),
                          title: Text(item.$1),
                          onTap: () {
                            Navigator.pop(context);
                            _go(context, item.$2);
                          },
                        )),
                  ],
                )),
              ),
        body: SafeArea(top: false, child: body),
      ),
    );
  }
}
