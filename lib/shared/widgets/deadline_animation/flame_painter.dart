import 'package:flutter/material.dart';

/// Paints three layered flames (red, yellow, white) at the right side of scene.
/// Opacity is driven by [flameOpacity]; scale flickers via [flameScale].
class FlamePainter extends CustomPainter {
  final double flameOpacity; // 0.0 → 1.0
  final double flameScale; // flickering scale ~0.8 → 1.1
  final Size sceneSize;

  const FlamePainter({
    required this.flameOpacity,
    required this.flameScale,
    required this.sceneSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (flameOpacity <= 0.01) return;

    final scaleX = size.width / sceneSize.width;
    final scaleY = size.height / sceneSize.height;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Flame base center: ~530, 100 in scene coords
    // translateY: -30 (lifts flames up)
    canvas.translate(0, -30 * scaleY / scaleX);

    // Apply flicker scale around flame center
    const flameCx = 529.0;
    const flameCy = 85.0;
    canvas.translate(flameCx, flameCy);
    canvas.scale(flameScale, flameScale);
    canvas.translate(-flameCx, -flameCy);

    // Red outer flame
    _drawFlame(
      canvas,
      color: const Color(0xFFB71342),
      opacity: flameOpacity,
      path: _redFlamePath(),
    );

    // Yellow middle flame
    _drawFlame(
      canvas,
      color: const Color(0xFFF7B523),
      opacity: flameOpacity * 0.71,
      path: _yellowFlamePath(),
    );

    // White core
    _drawFlame(
      canvas,
      color: Colors.white,
      opacity: flameOpacity * 0.81,
      path: _whiteFlamePath(),
    );

    canvas.restore();
  }

  void _drawFlame(
    Canvas canvas, {
    required Color color,
    required double opacity,
    required Path path,
  }) {
    final paint = Paint()
      ..color = color.withOpacity(opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  Path _redFlamePath() {
    final p = Path();
    p.moveTo(528.377, 100.291);
    p.cubicTo(534.584, 100.291, 539.324, 97.019, 539.211, 91.715);
    p.cubicTo(539.099, 86.41, 536.277, 82.912, 530.974, 81.332);
    p.cubicTo(525.668, 79.751, 527.136, 73.432, 530.184, 71.625);
    p.cubicTo(522.847, 73.657, 522.603, 77.516, 523.074, 79.863);
    p.cubicTo(523.863, 83.814, 530.634, 84.265, 528.151, 89.343);
    p.cubicTo(525.669, 94.422, 520.139, 90.472, 521.832, 87.086);
    p.cubicTo(518.989, 89.319, 517.052, 93.767, 519.573, 96.789);
    p.cubicTo(521.256, 98.809, 524.175, 100.291, 528.377, 100.291);
    p.close();
    return p;
  }

  Path _yellowFlamePath() {
    final p = Path();
    p.moveTo(528.837, 100.291);
    p.cubicTo(533.034, 100.291, 533.945, 98.437, 534.811, 94.874);
    p.cubicTo(535.713, 91.15, 533.682, 88.667, 529.506, 84.943);
    p.cubicTo(527.11, 82.806, 527.925, 80.767, 528.941, 78.623);
    p.cubicTo(524.54, 80.541, 525.557, 83.927, 526.459, 85.281);
    p.cubicTo(527.97, 87.548, 528.558, 87.645, 526.879, 91.081);
    p.cubicTo(525.2, 94.516, 521.459, 91.845, 522.604, 89.554);
    p.cubicTo(520.683, 91.066, 520.231, 93.594, 521.076, 96.117);
    p.cubicTo(522.057, 99.051, 525.994, 100.291, 528.837, 100.291);
    p.close();
    return p;
  }

  Path _whiteFlamePath() {
    final p = Path();
    p.moveTo(529.461, 100.291);
    p.cubicTo(527.097, 100.291, 525.287, 98.969, 525.332, 96.822);
    p.cubicTo(525.372, 94.677, 526.449, 93.262, 528.473, 92.624);
    p.cubicTo(530.495, 91.986, 529.936, 89.429, 528.775, 88.699);
    p.cubicTo(531.573, 89.52, 531.665, 91.081, 531.486, 92.031);
    p.cubicTo(531.185, 93.628, 528.603, 93.81, 529.548, 95.865);
    p.cubicTo(530.46, 97.84, 532.834, 96.803, 531.957, 94.952);
    p.cubicTo(533.043, 95.855, 533.783, 97.653, 532.821, 98.876);
    p.cubicTo(532.18, 99.691, 531.064, 100.291, 529.461, 100.291);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(FlamePainter old) =>
      old.flameOpacity != flameOpacity || old.flameScale != flameScale;
}
