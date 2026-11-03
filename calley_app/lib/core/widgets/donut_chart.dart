import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

class DonutSegment {
  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

/// Thin ring with rounded ends and a clear gap between segments; the total
/// sits in the middle in the display face. It sweeps in once on first paint
/// and holds still if the device asks for reduced motion.
class DonutChart extends StatefulWidget {
  const DonutChart({
    super.key,
    required this.segments,
    this.size = 180,
    this.centerLabel,
    this.centerValue,
  });

  final List<DonutSegment> segments;
  final double size;
  final String? centerLabel;
  final String? centerValue;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _ctrl.value = 1;
      } else {
        _ctrl.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant DonutChart old) {
    super.didUpdateWidget(old);
    final changed =
        old.segments.length != widget.segments.length ||
        List.generate(
          old.segments.length,
          (i) => old.segments[i].value != widget.segments[i].value,
        ).any((x) => x);
    if (changed && !MediaQuery.disableAnimationsOf(context)) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final total = widget.segments.fold<int>(0, (a, s) => a + s.value);
    final semantics = widget.segments
        .map((s) => '${s.label} ${s.value}')
        .join(', ');
    return Semantics(
      label: 'Call status chart. $semantics. Total $total.',
      child: ExcludeSemantics(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _t,
            builder: (context, _) => CustomPaint(
              painter: _DonutPainter(
                segments: widget.segments,
                progress: _t.value,
                track: c.skeleton,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.centerValue ?? '$total',
                      style: context.display(
                        widget.size * 0.22,
                        weight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    if (widget.centerLabel != null) ...[
                      const SizedBox(height: 6),
                      Text(widget.centerLabel!, style: context.eyebrow()),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.progress,
    required this.track,
  });

  final List<DonutSegment> segments;
  final double progress;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.11;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);

    final total = segments.fold<int>(0, (a, s) => a + s.value);
    if (total <= 0) return;

    // Gap between segments, measured in radians at the ring's centre line.
    final gap = (stroke * 1.4) / (rect.width / 2);
    var start = -math.pi / 2;
    final full = math.pi * 2 * progress;
    var drawn = 0.0;
    for (final s in segments) {
      if (s.value <= 0) continue;
      final sweep = math.pi * 2 * s.value / total;
      final visible = math.max(sweep - gap, 0.02);
      final remaining = full - drawn;
      if (remaining <= 0) break;
      canvas.drawArc(
        rect,
        start + gap / 2,
        math.min(visible, remaining),
        false,
        paint..color = s.color,
      );
      start += sweep;
      drawn += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress ||
      old.segments != segments ||
      old.track != track;
}
