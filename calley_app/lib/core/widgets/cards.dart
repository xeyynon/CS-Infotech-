import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Flat surface on the paper background. No border: the tone difference is
/// the edge. `tone: alt` for a surface that sits on another card.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.onTap,
    this.radius = Dims.cardRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final body = Padding(padding: padding, child: child);
    return Material(
      color: color ?? c.card,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? body : InkWell(onTap: onTap, child: body),
    );
  }
}

class LedgerEntry {
  const LedgerEntry({
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
    this.caption,
  });

  final String label;
  final int value;
  final Color color;
  final VoidCallback? onTap;

  /// Small text after the figure, e.g. the share of the list.
  final String? caption;
}

/// The call-status figures as one strip of columns: a coloured dot and a
/// word, then the figure in mono. Replaces three separate boxes.
class StatLedger extends StatelessWidget {
  const StatLedger({super.key, required this.entries});

  final List<LedgerEntry> entries;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0) VerticalDivider(width: 1, color: c.border),
              Expanded(
                child: Semantics(
                  button: entries[i].onTap != null,
                  label:
                      '${entries[i].label}, ${entries[i].value} calls'
                      '${entries[i].caption == null ? '' : ', ${entries[i].caption}'}',
                  onTap: entries[i].onTap, // B-02
                  child: ExcludeSemantics(
                    child: InkWell(
                      onTap: entries[i].onTap,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: entries[i].color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    entries[i].label,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.body(
                                      12.5,
                                      weight: FontWeight.w500,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${entries[i].value}',
                                  style: context.mono(
                                    26,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                if (entries[i].caption != null) ...[
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      entries[i].caption!,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.mono(
                                        12.5,
                                        color: c.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A small fact on the greeting card: the plan, or "Sample data".
class GreetingChip {
  const GreetingChip(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// The hero card at the top of Getting Started and the dashboard.
///
/// Deep navy in BOTH themes, so the white text has the same strong contrast
/// everywhere (the old brand-blue card turned pale in dark mode and its dark
/// text washed out). Left to right: the person's initial, then "Hello" and
/// their name in the display face; under it small chips for facts worth a
/// glance (plan, sample mode). The official Calley mark sits faintly in the
/// corner. It reads as one sentence for a screen reader.
class GreetingCard extends StatelessWidget {
  const GreetingCard({
    super.key,
    required this.eyebrow,
    required this.name,
    required this.subline,
    required this.initial,
    this.chips = const [],
  });

  final String eyebrow;
  final String name;
  final String subline;
  final String initial;
  final List<GreetingChip> chips;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return MergeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dims.cardRadius),
        child: Container(
          color: c.navy,
          child: Stack(
            children: [
              Positioned(
                right: -26,
                top: -22,
                child: Opacity(
                  opacity: 0.2,
                  child: ExcludeSemantics(
                    child: Image.asset(
                      'assets/brand/calley_mark.png',
                      height: 168,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: c.onNavy,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            initial,
                            style: context.display(
                              23,
                              weight: FontWeight.w800,
                              color: c.navy,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eyebrow.toUpperCase(),
                                style: context.eyebrow(
                                  color: c.onNavy.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.display(
                                  28,
                                  weight: FontWeight.w800,
                                  color: c.onNavy,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subline,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.body(
                                  13.5,
                                  color: c.onNavy.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final chip in chips)
                            Container(
                              padding: const EdgeInsets.fromLTRB(9, 6, 12, 6),
                              decoration: BoxDecoration(
                                color: c.onNavy.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    chip.icon,
                                    size: 15,
                                    color: c.onNavy.withValues(alpha: 0.9),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    chip.label,
                                    style: context.body(
                                      12.5,
                                      weight: FontWeight.w600,
                                      color: c.onNavy,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark navy strip used as a section header ("LOAD NUMBER TO CALL").
class NavyHeader extends StatelessWidget {
  const NavyHeader(
    this.text, {
    super.key,
    this.radius = const BorderRadius.vertical(
      top: Radius.circular(Dims.cardRadius),
    ),
  });

  final String text;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(color: c.navy, borderRadius: radius),
      child: Text(text.toUpperCase(), style: context.eyebrow(color: c.onNavy)),
    );
  }
}

/// Initials in a circle. For contacts the hue comes from the name, so the
/// same person always gets the same colour.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initial,
    this.size = 40,
    this.inverted = false,
    this.seed,
  });

  final String initial;
  final double size;
  final bool inverted;

  /// When set, the background hue is derived from this string.
  final String? seed;

  static const _hues = [
    Color(0xFF1F5EFF),
    Color(0xFF0E9F6E),
    Color(0xFFD9772C),
    Color(0xFF8B5CF6),
    Color(0xFFC2415E),
    Color(0xFF0F8FA8),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Color bg;
    Color fg;
    if (seed != null) {
      bg = _hues[seed.hashCode.abs() % _hues.length];
      fg = Colors.white;
    } else if (inverted) {
      bg = c.onPrimary;
      fg = c.primary;
    } else {
      bg = c.primary;
      fg = c.onPrimary;
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        initial,
        style: context.display(size * 0.42, weight: FontWeight.w700, color: fg),
      ),
    );
  }
}

/// A status word with its colour dot. Never colour alone.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: context.body(
            12,
            weight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
      ],
    );
  }
}
