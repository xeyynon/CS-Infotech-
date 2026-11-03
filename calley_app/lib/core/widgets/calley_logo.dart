import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The Calley mark: three nested arcs in brand colours, then the wordmark in
/// the display face. Drawn, not an image, so it stays sharp at any size.
class CalleyLogo extends StatelessWidget {
  const CalleyLogo({super.key, this.size = 44, this.showText = true});

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final mark = CustomPaint(
      size: Size.square(size),
      painter: _SwooshPainter(),
    );
    if (!showText) return mark;
    return Semantics(
      label: 'Calley, automatic call dialer',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            mark,
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Calley',
                  style: context.display(
                    size * 0.56,
                    weight: FontWeight.w800,
                    height: 1,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'AUTOMATIC CALL DIALER',
                  style: TextStyle(
                    fontFamily: Fonts.mono,
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: c.textMuted,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SwooshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    final colors = [
      const Color(0xFF22C55E),
      const Color(0xFFF59E0B),
      const Color(0xFF1F5EFF),
    ];
    final stroke = size.width * 0.16;
    for (var i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke;
      final radius = r - stroke / 2 - i * stroke * 1.15;
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        math.pi * (0.9 + i * 0.12),
        math.pi * 1.25,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
