import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/deadline_animation/deadline_animation_widget.dart';
import '../../../core/theme/app_colors.dart';

/// Splash screen shown on every app launch.
/// Duration: 3.5 s → fade to /deadlines. Max wait: 5 s.
class SplashScreen extends StatefulWidget {
  /// Optional future that must resolve before navigating
  /// (e.g. delayed init). If null, only the timer governs navigation.
  final Future<void>? initFuture;

  const SplashScreen({super.key, this.initFuture});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ── Progress bar (0→1 over 3.5 s) ───────────────────────────────────────
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;

  bool _navigated = false;

  // Demo dueDate passed to the animation widget during splash
  // (just shows a 1-day deadline countdown — cosmetic only)
  final DateTime _splashDueDate =
      DateTime.now().add(const Duration(hours: 23, minutes: 30));

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();

    _progressAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(_progressCtrl);

    // Primary: navigate after 3.5 s
    final primaryTimer = Future.delayed(const Duration(milliseconds: 3500));

    // Guard: navigate after at most 5 s regardless of init
    final guardTimer = Future.delayed(const Duration(milliseconds: 5000));

    if (widget.initFuture != null) {
      // Wait for both primary timer AND initFuture, but never longer than 5 s
      Future.any([
        Future.wait([primaryTimer, widget.initFuture!]),
        guardTimer,
      ]).then((_) => _navigate());
    } else {
      primaryTimer.then((_) => _navigate());
    }
  }

  void _navigate() {
    if (_navigated || !mounted) return;
    _navigated = true;
    context.go('/deadlines');
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No backgroundColor → inherits theme surface
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main content (centered) ────────────────────────────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animation fills full width, maintains 581:158 ratio
                    DeadlineAnimationWidget(
                      dueDate: _splashDueDate,
                      isMini: false,
                      cycleDuration: 3.5,
                      showCountdown: false,
                    ),
                    const SizedBox(height: 20),
                    // App name
                    Text(
                      'DeadlineApp',
                      style: GoogleFonts.oswald(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deadlineRed,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Progress bar (bottom) ──────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, __) => LinearProgressIndicator(
                  value: _progressAnim.value,
                  minHeight: 3,
                  backgroundColor: AppColors.deadlineRed.withValues(alpha: 0.15),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.deadlineRed),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
