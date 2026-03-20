import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'death_painter.dart';
import 'designer_painter.dart';
import 'flame_painter.dart';
import '../../../core/theme/app_colors.dart';

/// Original HTML scene dimensions (SVG viewBox) — used for painter coordinates.
const _kSceneSize = Size(581.0, 158.0);

/// The signature DeadlineApp animation widget.
/// Recreates the "Death walks toward the Designer" CSS animation from
/// deadline-loader.html entirely in Flutter via CustomPainter.
///
/// Background is fully transparent — the surrounding Scaffold surface shows through.
class DeadlineAnimationWidget extends StatefulWidget {
  /// The deadline date. Used to compute the real-time countdown label.
  final DateTime dueDate;

  /// Compact mode for home screen widget / dashboard cards.
  /// Renders at 0.4× scale, suppresses flames, hides day label.
  final bool isMini;

  /// Full cycle duration in seconds (default 20.0).
  /// Animation loops independently of the countdown label.
  final double cycleDuration;

  /// Whether to show the countdown label ("X days Y hours left").
  final bool showCountdown;

  /// Whether the animation is in an "idle" state (no active deadlines).
  final bool isIdle;

  /// Optional label override for the idle or empty state.
  final String? customLabel;

  const DeadlineAnimationWidget({
    super.key,
    required this.dueDate,
    this.isMini = false,
    this.cycleDuration = 20.0,
    this.showCountdown = true,
    this.isIdle = false,
    this.customLabel,
  });

  @override
  State<DeadlineAnimationWidget> createState() =>
      _DeadlineAnimationWidgetState();
}

class _DeadlineAnimationWidgetState extends State<DeadlineAnimationWidget>
    with TickerProviderStateMixin {
  // ── Walk controller (main cycle) ────────────────────────────────────────
  late AnimationController _walkCtrl;
  late Animation<double> _walkAnim; // Death's X fraction 0.0 → 1.0

  // ── Arm pendulum controller ──────────────────────────────────────────────
  late AnimationController _armCtrl;
  late Animation<double> _armAnim; // rotation in radians

  // ── Flame flicker controller ─────────────────────────────────────────────
  late AnimationController _flameCtrl;
  late Animation<double> _flameScaleAnim;

  // ── Progress bar animation (same as walk) ───────────────────────────────
  late Animation<double> _progressAnim; // 0.0 → 0.97

  // ── Real-time countdown label ────────────────────────────────────────────
  late String _timeLabel;
  late Color _labelColor;
  Timer? _countdownTimer;

  // ── Writing speed ramp schedule ─────────────────────────────────────────
  final List<_WriteRampStep> _writeRamp = const [
    _WriteRampStep(delayMs: 0, durationMs: 1500),
    _WriteRampStep(delayMs: 4000, durationMs: 1000),
    _WriteRampStep(delayMs: 8000, durationMs: 700),
    _WriteRampStep(delayMs: 12000, durationMs: 300),
    _WriteRampStep(delayMs: 15000, durationMs: 200),
  ];

  @override
  void initState() {
    super.initState();
    _updateTimeLabel();
    _initControllers();
    _startCycle();

    // Real-time per-minute update
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(_updateTimeLabel);
    });
  }

  // ── Label helpers ────────────────────────────────────────────────────────

  void _updateTimeLabel() {
    if (widget.isIdle) {
      _timeLabel = widget.customLabel ?? 'Henüz deadline yok';
      _labelColor = Colors.grey;
      return;
    }

    if (widget.customLabel != null) {
      _timeLabel = widget.customLabel!;
      // Default to urgency color calculation unless label is completely custom
    }

    final diff = widget.dueDate.difference(DateTime.now());
    if (diff.isNegative) {
      _timeLabel = 'Süre doldu';
      _labelColor = AppColors.urgencyOverdue;
    } else if (diff.inDays > 0) {
      final hours = diff.inHours % 24;
      _timeLabel = '${diff.inDays} gün $hours saat kaldı';
      _labelColor = AppColors.urgencyColor(diff.inDays);
    } else {
      final minutes = diff.inMinutes % 60;
      _timeLabel = '${diff.inHours} saat $minutes dakika kaldı';
      _labelColor = AppColors.urgencyCritical;
    }
  }

  // ── Animation init ───────────────────────────────────────────────────────

  void _initControllers() {
    final cycleDur =
        Duration(milliseconds: (widget.cycleDuration * 1000).round());

    // Walk — TweenSequence from HTML @keyframes anim-walk
    _walkCtrl = AnimationController(vsync: this, duration: cycleDur);
    _walkAnim = TweenSequence<double>([
      // 0% → 6%: stay at 0
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 6),
      // 6% → 10%: 0 → 100/520
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 100 / 520), weight: 4),
      // 10% → 15%: → 140/520
      TweenSequenceItem(
          tween: Tween(begin: 100 / 520, end: 140 / 520), weight: 5),
      // 15% → 25%: → 170/520
      TweenSequenceItem(
          tween: Tween(begin: 140 / 520, end: 170 / 520), weight: 10),
      // 25% → 35%: → 220/520
      TweenSequenceItem(
          tween: Tween(begin: 170 / 520, end: 220 / 520), weight: 10),
      // 35% → 45%: → 280/520
      TweenSequenceItem(
          tween: Tween(begin: 220 / 520, end: 280 / 520), weight: 10),
      // 45% → 55%: → 340/520
      TweenSequenceItem(
          tween: Tween(begin: 280 / 520, end: 340 / 520), weight: 10),
      // 55% → 65%: → 370/520
      TweenSequenceItem(
          tween: Tween(begin: 340 / 520, end: 370 / 520), weight: 10),
      // 65% → 75%: → 430/520
      TweenSequenceItem(
          tween: Tween(begin: 370 / 520, end: 430 / 520), weight: 10),
      // 75% → 85%: → 460/520
      TweenSequenceItem(
          tween: Tween(begin: 430 / 520, end: 460 / 520), weight: 10),
      // 85% → 100%: → 520/520
      TweenSequenceItem(tween: Tween(begin: 460 / 520, end: 1.0), weight: 15),
    ]).animate(CurvedAnimation(parent: _walkCtrl, curve: Curves.linear));

    _progressAnim = Tween<double>(begin: 0.0, end: 0.97).animate(_walkCtrl);

    // Arm pendulum — initial 1.5s, will be changed by ramp
    _armCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _armAnim = Tween<double>(
      begin: -25 * math.pi / 180,
      end: 20 * math.pi / 180,
    ).animate(CurvedAnimation(parent: _armCtrl, curve: Curves.easeInOut));
    _armCtrl.repeat(reverse: true);

    // Flame flicker
    _flameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _flameScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.8), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 25),
    ]).animate(_flameCtrl);
    _flameCtrl.repeat();
  }

  void _startCycle() {
    if (widget.isIdle) {
      _walkCtrl.stop();
      _armCtrl.stop();
      _flameCtrl.stop();
      return;
    }

    _walkCtrl.forward(from: 0);
    _armCtrl.repeat(reverse: true);
    _flameCtrl.repeat();
    _scheduleWritingRamp();

    _walkCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startCycle();
      }
    });
  }

  @override
  void didUpdateWidget(DeadlineAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isIdle != widget.isIdle ||
        oldWidget.dueDate != widget.dueDate ||
        oldWidget.customLabel != widget.customLabel) {
      setState(() {
        _updateTimeLabel();
        if (widget.isIdle) {
          _walkCtrl.reset();
          _walkCtrl.stop();
          _armCtrl.stop();
          _flameCtrl.stop();
        } else {
          if (!_walkCtrl.isAnimating) {
            _startCycle();
          }
        }
      });
    }
  }

  void _scheduleWritingRamp() {
    for (final step in _writeRamp) {
      Future.delayed(Duration(milliseconds: step.delayMs), () {
        if (!mounted) return;
        _armCtrl.duration = Duration(milliseconds: step.durationMs);
        _armCtrl.repeat(reverse: true);
      });
    }
  }

  double _flameOpacity(double cycleValue) {
    if (cycleValue < 0.74) return 0.0;
    if (cycleValue < 0.80) {
      return (cycleValue - 0.74) / 0.06;
    }
    if (cycleValue < 0.99) return 1.0;
    return 0.0;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _walkCtrl.dispose();
    _armCtrl.dispose();
    _flameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final designerColor = Theme.of(context).colorScheme.onSurface;

    Widget scene = AnimatedBuilder(
      animation: Listenable.merge([_walkCtrl, _armCtrl, _flameCtrl]),
      builder: (context, _) {
        final cycleVal = widget.isIdle ? 0.0 : _walkCtrl.value;
        final walkFrac = widget.isIdle ? 0.0 : _walkAnim.value;
        final armRot = widget.isIdle ? 0.0 : _armAnim.value;
        final progress = widget.isIdle ? 0.0 : _progressAnim.value;
        final flameOpacity =
            (widget.isMini || widget.isIdle) ? 0.0 : _flameOpacity(cycleVal);
        final flameScale = widget.isIdle ? 1.0 : _flameScaleAnim.value;

        return Stack(
          children: [
            // ── Progress bar (transparent background, only bar strip) ──
            Positioned.fill(
              child: ClipRect(
                child: CustomPaint(
                  painter: _ProgressBarPainter(progress: progress),
                ),
              ),
            ),
            // ── Death character ──
            Positioned.fill(
              child: CustomPaint(
                painter: DeathPainter(
                  walkProgress: walkFrac,
                  armRotation: armRot,
                  sceneSize: _kSceneSize,
                ),
              ),
            ),
            // ── Designer character ──
            Positioned.fill(
              child: CustomPaint(
                painter: DesignerPainter(
                  armRotation: -armRot * 0.4,
                  sceneSize: _kSceneSize,
                  color: designerColor,
                ),
              ),
            ),
            // ── Flames ──
            if (!widget.isMini)
              Positioned.fill(
                child: CustomPaint(
                  painter: FlamePainter(
                    flameOpacity: flameOpacity,
                    flameScale: flameScale,
                    sceneSize: _kSceneSize,
                  ),
                ),
              ),
            // ── Day label ──
            if (!widget.isMini && widget.showCountdown)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _DeadlineTimeLabel(
                  label: _timeLabel,
                  labelColor: _labelColor,
                  wipeProgress: cycleVal,
                ),
              ),
          ],
        );
      },
    );

    // Wrap in AspectRatio to maintain 581:158 proportion
    Widget content = AspectRatio(
      aspectRatio: _kSceneSize.width / _kSceneSize.height,
      child: scene,
    );

    if (widget.isMini) {
      content = Transform.scale(scale: 0.4, child: content);
    }

    return content;
  }
}

// ── Progress bar only (no background fill) ───────────────────────────────────

class _ProgressBarPainter extends CustomPainter {
  final double progress;

  const _ProgressBarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 8px bar at the very bottom of the scene
    const barH = 8.0;
    final barY = size.height - barH;
    final barW = size.width * progress;

    final paint = Paint()
      ..color = AppColors.deadlineRed
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, barY, barW, barH), paint);

    // Faint track line
    final trackPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, barY + barH / 2),
        Offset(size.width, barY + barH / 2), trackPaint);
  }

  @override
  bool shouldRepaint(_ProgressBarPainter old) => old.progress != progress;
}

// ── Real-time label with colour-wipe effect ──────────────────────────────────

class _DeadlineTimeLabel extends StatelessWidget {
  final String label;
  final Color labelColor;
  final double wipeProgress;

  const _DeadlineTimeLabel({
    required this.label,
    required this.labelColor,
    required this.wipeProgress,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;
    // We use a fixed width for the label container to ensure centering stays consistent
    const labelWidth = 581.0;
    final wipeWidth = labelWidth * wipeProgress * 0.98;

    return SizedBox(
      height: 28,
      child: Stack(
        children: [
          // 1. Base Layer (Theme-adaptive): Shows ONLY the part not yet reached by the wipe
          Positioned.fill(
            child: ClipRect(
              clipper: _PartClipper(progressWidth: wipeWidth, isLeft: false),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: baseColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          // 2. Red Layer: Shows ONLY the part reached by the wipe
          Positioned.fill(
            child: ClipRect(
              clipper: _PartClipper(progressWidth: wipeWidth, isLeft: true),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.deadlineRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartClipper extends CustomClipper<Rect> {
  final double progressWidth;
  final bool isLeft;

  _PartClipper({required this.progressWidth, required this.isLeft});

  @override
  Rect getClip(Size size) {
    if (isLeft) {
      return Rect.fromLTWH(0, 0, progressWidth, size.height);
    } else {
      // Small 0.5px adjustments can sometimes help with anti-aliasing gaps,
      // but exact partitioning is usually cleanest.
      return Rect.fromLTWH(
          progressWidth, 0, size.width - progressWidth, size.height);
    }
  }

  @override
  bool shouldReclip(_PartClipper oldClipper) =>
      oldClipper.progressWidth != progressWidth || oldClipper.isLeft != isLeft;
}

// Helper model
class _WriteRampStep {
  final int delayMs;
  final int durationMs;
  const _WriteRampStep({required this.delayMs, required this.durationMs});
}
