import 'package:flutter/material.dart';
import '../theme/vastu_theme.dart';

/// Shared interaction treatments; transparent borders reserve focus-ring space.
abstract final class VastuButtons {
  static WidgetStateProperty<MouseCursor> get cursor =>
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
      );
  static WidgetStateProperty<BorderSide> border(Color normal) =>
      WidgetStateProperty.resolveWith(
        (states) => BorderSide(
            color: states.contains(WidgetState.focused)
                ? VastuColors.forest
                : normal,
            width: VastuControl.focusWidth),
      );
  static final primary = FilledButton.styleFrom(
    minimumSize: const Size(0, VastuControl.primaryHeight),
    padding:
        const EdgeInsets.symmetric(horizontal: VastuSpace.lg, vertical: 14),
    visualDensity: VisualDensity.standard,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VastuRadius.control)),
    textStyle: VastuType.section.copyWith(fontSize: 16),
  ).copyWith(
    animationDuration: VastuControl.transition,
    splashFactory: NoSplash.splashFactory,
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    mouseCursor: cursor,
    side: border(Colors.transparent),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) {
        return VastuColors.disabledSurface;
      }
      if (states.contains(WidgetState.pressed)) {
        return VastuColors.actionPressed;
      }
      if (states.contains(WidgetState.hovered)) {
        return VastuColors.actionHover;
      }
      return VastuColors.action;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.disabled)
            ? VastuColors.muted
            : Colors.white),
  );

  static ButtonStyle secondary({bool tonal = false}) =>
      OutlinedButton.styleFrom(
        minimumSize: const Size(0, VastuControl.target),
        padding: const EdgeInsets.symmetric(
            horizontal: VastuSpace.md, vertical: VastuSpace.md),
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VastuRadius.control)),
        textStyle: VastuType.section,
      ).copyWith(
        animationDuration: VastuControl.transition,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        mouseCursor: cursor,
        side: border(VastuColors.border),
        foregroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.disabled)
                ? VastuColors.disabledInk
                : VastuColors.forest),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return VastuColors.canvas;
          }
          if (states.contains(WidgetState.pressed)) {
            return VastuColors.controlPressed;
          }
          if (states.contains(WidgetState.hovered)) {
            return VastuColors.controlHover;
          }
          return tonal ? VastuColors.sage : VastuColors.surface;
        }),
      );

  static ButtonStyle icon({bool quiet = false}) => IconButton.styleFrom(
        minimumSize: const Size.square(VastuControl.target),
        maximumSize: const Size.square(VastuControl.target),
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VastuRadius.control)),
      ).copyWith(
        animationDuration: VastuControl.transition,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        mouseCursor: cursor,
        side: border(Colors.transparent),
        foregroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.disabled)
                ? VastuColors.disabledInk
                : VastuColors.forest),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return VastuColors.controlPressed;
          }
          if (states.contains(WidgetState.hovered)) {
            return VastuColors.controlHover;
          }
          return quiet ? Colors.transparent : VastuColors.canvas;
        }),
      );
}

class BrandedCard extends StatelessWidget {
  const BrandedCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(VastuSpace.xl)});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
            color: VastuColors.surface,
            borderRadius: BorderRadius.circular(VastuRadius.card),
            border: Border.all(color: VastuColors.border),
            boxShadow: VastuTheme.shadows),
        child: child,
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.loading = false});
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: VastuButtons.primary,
          onPressed: loading ? null : onPressed,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (loading)
              const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: VastuColors.forest))
            else
              const Icon(Icons.auto_awesome_outlined, size: 18),
            const SizedBox(width: VastuSpace.sm),
            Flexible(
                child: Text(loading ? 'Analyzing your plan…' : label,
                    textAlign: TextAlign.center)),
          ]),
        ),
      );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.onPressed,
      this.tonal = false});
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool tonal;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        style: VastuButtons.secondary(tonal: tonal),
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, overflow: TextOverflow.ellipsis),
      );
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: VastuSpace.md, vertical: VastuSpace.xs),
        decoration: BoxDecoration(
            color: active ? VastuColors.sage : VastuColors.stepSurface,
            border: Border.all(color: VastuColors.border),
            borderRadius: BorderRadius.circular(VastuRadius.pill)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (active) ...[
            Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: VastuColors.success, shape: BoxShape.circle)),
            const SizedBox(width: VastuSpace.xs),
          ],
          Text(label,
              style: VastuType.caption.copyWith(
                  color: active ? VastuColors.forest : VastuColors.muted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7)),
        ]),
      );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: VastuSpace.sm),
        child: Text(text,
            style: VastuType.section.copyWith(
                fontSize: 13, letterSpacing: 0.3, color: VastuColors.forest)),
      );
}

class BrandSelect<T> extends StatefulWidget {
  const BrandSelect(
      {super.key,
      required this.value,
      required this.items,
      required this.onChanged,
      this.hint = 'Select',
      this.compact = false});
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String hint;
  final bool compact;
  @override
  State<BrandSelect<T>> createState() => _BrandSelectState<T>();
}

class _BrandSelectState<T> extends State<BrandSelect<T>> {
  final _focus = FocusNode();
  bool _hovered = false;
  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
  }

  void _focusChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _focus.removeListener(_focusChanged);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null && widget.items.isNotEmpty;
    final focused = enabled && _focus.hasFocus;
    final hover = enabled && _hovered;
    final dropdown = DropdownButtonHideUnderline(
        child: DropdownButton<T>(
      value: widget.value,
      items: widget.items,
      onChanged: widget.onChanged,
      focusNode: _focus,
      focusColor: Colors.transparent,
      mouseCursor:
          enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      hint: Text(widget.hint, overflow: TextOverflow.ellipsis),
      isExpanded: true,
      isDense: false,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(VastuRadius.control),
      dropdownColor: VastuColors.surface,
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: enabled ? VastuColors.forest : VastuColors.disabledInk,
          size: 20),
      style: VastuType.body.copyWith(fontSize: 14, height: 1.4),
    ));
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: VastuControl.transition,
        curve: Curves.easeOut,
        constraints: BoxConstraints(
            minHeight: widget.compact
                ? VastuControl.target
                : VastuControl.selectHeight),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? VastuSpace.md : VastuSpace.lg),
        decoration: BoxDecoration(
          color: !enabled
              ? VastuColors.canvas
              : (hover
                  ? VastuColors.canvas
                  : (widget.compact
                      ? VastuColors.background
                      : VastuColors.surface)),
          border: Border.all(
              color: focused
                  ? VastuColors.forest
                  : (hover
                      ? VastuColors.controlHoverBorder
                      : VastuColors.border),
              width: 1.5),
          borderRadius: BorderRadius.circular(VastuRadius.control),
          boxShadow: focused
              ? [
                  BoxShadow(
                      color: VastuColors.forest.withValues(alpha: 0.08),
                      spreadRadius: 2)
                ]
              : null,
        ),
        child: widget.compact
            ? Row(children: [
                const Icon(Icons.explore_outlined,
                    size: 16, color: VastuColors.forest),
                const SizedBox(width: VastuSpace.sm),
                Expanded(child: dropdown),
              ])
            : dropdown,
      ),
    );
  }
}

class BrandNavItem extends StatelessWidget {
  const BrandNavItem(
      {super.key,
      required this.label,
      required this.active,
      required this.onPressed});
  final String label;
  final bool active;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
        selected: active,
        child: TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(0, VastuControl.target),
            padding: const EdgeInsets.symmetric(
                horizontal: VastuSpace.lg, vertical: VastuSpace.md),
            visualDensity: VisualDensity.standard,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(VastuRadius.control)),
          ).copyWith(
            animationDuration: VastuControl.transition,
            splashFactory: NoSplash.splashFactory,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            mouseCursor: VastuButtons.cursor,
            side: VastuButtons.border(Colors.transparent),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return VastuColors.controlPressed;
              }
              if (states.contains(WidgetState.hovered)) {
                return VastuColors.controlHover;
              }
              return active ? VastuColors.sage : Colors.transparent;
            }),
          ),
          onPressed: onPressed,
          child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Text(label,
                    style: VastuType.section.copyWith(
                        color:
                            active ? VastuColors.forest : VastuColors.muted)),
                if (active)
                  Positioned(
                      bottom: -8,
                      child: Container(
                          width: 16,
                          height: 2,
                          decoration: BoxDecoration(
                              color: VastuColors.terracotta,
                              borderRadius:
                                  BorderRadius.circular(VastuRadius.pill)))),
              ]),
        ),
      );
}
