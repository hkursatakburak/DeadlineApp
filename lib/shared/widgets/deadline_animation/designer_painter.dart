import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Paints the "Designer" character.
/// Fixed position at ~514px in original 581px scene width.
/// [color] should be Theme.of(context).colorScheme.onSurface so it adapts
/// to both light (dark figure) and dark (light figure) themes.
class DesignerPainter extends CustomPainter {
  final double armRotation; // radians
  final Size sceneSize;
  final Color color;

  const DesignerPainter({
    required this.armRotation,
    required this.sceneSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / sceneSize.width;
    final scaleY = size.height / sceneSize.height;
    // ignore lerpDouble unused; kept for symmetry with death_painter
    ui.lerpDouble(scaleX, scaleY, 0.5);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // ── Body ─────────────────────────────────────────────────────────────────
    final bodyPath = Path();
    bodyPath.moveTo(514.75, 100.334);
    bodyPath.cubicTo(514.75, 100.334, 516.0, 83.5, 508.0, 83.834);
    bodyPath.cubicTo(502.499, 84.063, 502.417, 86.834, 497.167, 85.5);
    bodyPath.cubicTo(493.916, 84.674, 492.083, 69.75, 496.333, 63.5);
    bodyPath.cubicTo(501.281, 56.223, 508.419, 54.234, 509.667, 55.667);
    bodyPath.cubicTo(511.917, 58.25, 507.667, 66.5, 505.167, 69.834);
    bodyPath.cubicTo(502.667, 73.167, 503.334, 80.25, 505.667, 79.75);
    bodyPath.cubicTo(508.0, 79.25, 513.693, 79.609, 515.667, 82.0);
    bodyPath.cubicTo(518.833, 85.834, 520.583, 99.667, 520.583, 99.667);
    bodyPath.lineTo(521.5, 102.167);
    bodyPath.lineTo(517.5, 102.334);
    bodyPath.lineTo(514.75, 100.334);
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);

    // ── Head (circle) ────────────────────────────────────────────────────────
    canvas.drawCircle(const Offset(516.083, 53.25), 6.083, paint);

    // ── Writing Arm (animated) ───────────────────────────────────────────────
    const pivotX = 505.875;
    const pivotY = 68.375;

    canvas.save();
    canvas.translate(pivotX, pivotY);
    canvas.rotate(armRotation);
    canvas.translate(-pivotX, -pivotY);

    // Forearm
    final armPath = Path();
    armPath.moveTo(505.875, 64.875);
    armPath.cubicTo(505.875, 64.875, 511.75, 72.375, 518.917, 71.666);
    armPath.cubicTo(525.336, 71.031, 530.75, 68.875, 532.375, 67.625);
    armPath.cubicTo(534.0, 66.375, 534.375, 64.125, 532.625, 63.75);
    armPath.cubicTo(530.875, 63.375, 519.5, 68.875, 514.875, 67.0);
    armPath.cubicTo(508.912, 64.582, 506.625, 59.375, 506.625, 59.375);
    armPath.lineTo(504.625, 60.5);
    armPath.lineTo(505.875, 64.875);
    armPath.close();
    canvas.drawPath(armPath, paint);

    // Pen tip
    final penPath = Path();
    penPath.moveTo(525.75, 59.084);
    penPath.cubicTo(525.75, 59.084, 525.327, 58.822, 524.781, 59.172);
    penPath.cubicTo(524.195, 59.547, 524.234, 60.063, 524.234, 60.063);
    penPath.lineTo(531.406, 69.047);
    penPath.lineTo(532.667, 69.5);
    penPath.lineTo(532.563, 68.172);
    penPath.lineTo(525.75, 59.084);
    penPath.close();
    canvas.drawPath(penPath, paint);

    canvas.restore(); // arm rotation
    canvas.restore(); // scene scale
  }

  @override
  bool shouldRepaint(DesignerPainter old) =>
      old.armRotation != armRotation || old.color != color;
}
