import 'package:flutter/material.dart';

/// Paints the "Death" (Azrail) character using SVG paths from deadline-loader.html.
/// Walk starts at x = -60px (off-screen-left) and travels across the full scene width.
/// Color is always #BE002A (brand red) — readable in both light and dark themes.
class DeathPainter extends CustomPainter {
  final double walkProgress; // 0.0 → 1.0 (Death's X position in scene)
  final double armRotation; // radians, pendulum swing
  final Size sceneSize;

  const DeathPainter({
    required this.walkProgress,
    required this.armRotation,
    required this.sceneSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / sceneSize.width;
    final scaleY = size.height / sceneSize.height;
    final scale = (scaleX + scaleY) / 2;

    // Death starts at -60px (off-screen left) and walks to scene width end.
    // Total travel = sceneWidth + 60 in original coords; walkProgress maps 0→1.
    final startX = -60.0 * scaleX;
    final endX = size.width;
    final walkX = startX + walkProgress * (endX - startX);

    // The SVG paths have negative X coords (centred around 0), so we translate
    // the group to walkX + 60*scale so that at walkProgress=0, Death is just
    // off the left edge, and at walkProgress=1, Death is at the right edge.
    canvas.save();
    canvas.translate(walkX + 60 * scale, 0);
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = const Color(0xFFBE002A)
      ..style = PaintingStyle.fill;

    // ── Body / Robe ──────────────────────────────────────────────────────────
    final bodyPath = Path();
    bodyPath.moveTo(-46.25, 40.416);
    bodyPath.cubicTo(-51.67, 40.135, -54.599, 43.586, -59.5, 44.334);
    bodyPath.cubicTo(-65.216, 45.205, -70.083, 43.416, -70.083, 43.416);
    bodyPath.cubicTo(-67.5, 49.0, -65.175, 50.6, -62.083, 52.0);
    bodyPath.cubicTo(-56.75, 54.416, -58.0, 55.5, -60.0, 56.5);
    bodyPath.cubicTo(-76.5, 61.333, -75.416, 84.417, -75.416, 84.417);
    bodyPath.lineTo(-75.5, 84.75);
    bodyPath.cubicTo(-76.5, 97.0, -95.75, 103.5, -95.75, 103.5);
    bodyPath.cubicTo(-56.303, 116.971, -49.5, 99.25, -49.5, 99.25);
    bodyPath.cubicTo(-45.917, 89.917, -51.053, 82.381, -51.167, 76.5);
    bodyPath.cubicTo(-51.243, 72.629, -48.325, 67.971, -45.083, 64.166);
    bodyPath.cubicTo(-41.487, 59.946, -38.125, 53.792, -38.125, 48.75);
    bodyPath.cubicTo(-38.125, 43.186, -39.833, 40.75, -46.25, 40.416);
    bodyPath.close();

    // Hood detail
    bodyPath.moveTo(-40.0, 51.959);
    bodyPath.cubicTo(-40.882, 54.963, -42.779, 58.865, -44.154, 58.496);
    bodyPath.cubicTo(-45.529, 58.127, -45.093, 54.176, -44.042, 50.792);
    bodyPath.cubicTo(-43.222, 48.152, -41.37, 44.832, -40.083, 45.209);
    bodyPath.cubicTo(-39.005, 45.523, -39.073, 48.8, -40.0, 51.959);
    bodyPath.close();

    canvas.drawPath(bodyPath, paint);

    // ── Arm + Scythe (animated together) ─────────────────────────────────────
    const pivotX = -53.375;
    const pivotY = 68.25;

    canvas.save();
    canvas.translate(pivotX, pivotY);
    canvas.rotate(armRotation);
    canvas.translate(-pivotX, -pivotY);

    // Arm path
    final armPath = Path();
    armPath.moveTo(-53.375, 75.25);
    armPath.cubicTo(-53.375, 75.25, -44.0, 77.5, -42.125, 75.5);
    armPath.cubicTo(-40.25, 73.5, -39.812, 73.158, -38.75, 72.709);
    armPath.cubicTo(-37.667, 72.25, -34.375, 71.0, -34.458, 68.0);
    armPath.cubicTo(-34.559, 64.373, -34.187, 63.406, -33.125, 62.957);
    armPath.cubicTo(-32.042, 62.5, -30.375, 61.291, -30.375, 61.291);
    armPath.cubicTo(-29.667, 61.0, -29.875, 60.416, -30.083, 59.832);
    armPath.cubicTo(-30.291, 59.248, -30.874, 57.707, -31.666, 56.873);
    armPath.cubicTo(-32.458, 56.041, -34.041, 54.999, -34.583, 55.541);
    armPath.cubicTo(-35.125, 56.082, -42.458, 62.707, -42.458, 62.707);
    armPath.cubicTo(-42.458, 62.707, -45.125, 65.498, -45.875, 62.832);
    armPath.cubicTo(-46.625, 60.166, -49.833, 61.0, -49.833, 61.0);
    armPath.cubicTo(-49.833, 61.0, -53.25, 62.416, -53.25, 62.541);
    armPath.cubicTo(-53.25, 62.666, -54.5, 68.375, -54.5, 68.375);
    armPath.lineTo(-55.083, 74.208);
    armPath.lineTo(-53.375, 75.25);
    armPath.close();
    canvas.drawPath(armPath, paint);

    // Scythe path
    final scythePath = Path();
    scythePath.moveTo(-20.996, 26.839);
    scythePath.lineTo(-63.815, 118.314);
    scythePath.lineTo(-62.003, 119.162);
    scythePath.lineTo(-23.661, 37.253);
    scythePath.cubicTo(-23.661, 37.253, -14.828, 39.896, -11.249, 44.667);
    scythePath.cubicTo(-6.249, 51.335, -6.499, 58.751, -6.499, 58.751);
    scythePath.cubicTo(-6.499, 58.751, -2.145, 51.019, -6.416, 41.085);
    scythePath.cubicTo(-10.0, 32.75, -19.647, 28.676, -19.647, 28.676);
    scythePath.lineTo(-19.184, 27.688);
    scythePath.lineTo(-20.996, 26.839);
    scythePath.close();
    canvas.drawPath(scythePath, paint);

    canvas.restore(); // arm rotation
    canvas.restore(); // death group
  }

  @override
  bool shouldRepaint(DeathPainter old) =>
      old.walkProgress != walkProgress || old.armRotation != armRotation;
}
