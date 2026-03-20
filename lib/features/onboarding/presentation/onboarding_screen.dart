import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/widgets/deadline_animation/deadline_animation_widget.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (mounted) context.go('/deadlines');
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      _OnboardingSlide(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.transparent,
              width: double.infinity,
              height: 200,
              child: Center(
                child: DeadlineAnimationWidget(
                  // Demo date for onboarding: 5 days from now
                  dueDate: DateTime.now().add(const Duration(days: 5)),
                  cycleDuration: 20.0,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'DeadlineApp',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.deadlineRed,
                  ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Son teslim tarihlerinizi, görevlerinizi ve notlarınızı tek bir yerde yönetin. Azrail size yaklaşmadan önce bitirin!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ).animate().fadeIn(delay: 500.ms),
            ),
          ],
        ),
      ),
      _OnboardingSlide(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month,
                    size: 100, color: AppColors.deadlineRed)
                .animate()
                .scale(delay: 200.ms),
            const SizedBox(height: 40),
            Text(
              'Google Takvim\nEntegrasyonu',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Görevlerinizi ve deadlinelerinizi Google Takvim ile senkronize edin. Her cihazınızda güncel kalın.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ).animate().fadeIn(delay: 400.ms),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_link),
              label: const Text('Google Takvim\'e Bağlan'),
            ).animate().fadeIn(delay: 600.ms),
            TextButton(
              onPressed: () {},
              child: const Text('Şimdi değil'),
            ),
          ],
        ),
      ),
      _OnboardingSlide(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.widgets_outlined,
                    size: 100, color: AppColors.deadlineRed)
                .animate()
                .scale(delay: 200.ms),
            const SizedBox(height: 40),
            Text(
              'Ana Ekran Widget\'ı',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Ana ekranınıza DeadlineApp widget\'ı ekleyin. En yakın deadlinezi her zaman görün, Azrail\'i takip edin.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ).animate().fadeIn(delay: 400.ms),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Proje Teslimi',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('3 gün kaldı',
                              style: TextStyle(
                                  color: AppColors.urgencyWarning,
                                  fontSize: 12)),
                        ],
                      ),
                      const Spacer(),
                      DeadlineAnimationWidget(
                        // Demo date for mini widget preview: 3 days from now
                        dueDate: DateTime.now().add(const Duration(days: 3)),
                        isMini: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: _complete,
              icon: const Icon(Icons.check),
              label: const Text('Başla!'),
            ).animate().fadeIn(delay: 600.ms).scale(delay: 600.ms),
          ],
        ),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: slides,
              ),
            ),
            // Page indicators + nav
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _pageCtrl.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                      child: const Text('Geri'),
                    )
                  else
                    const SizedBox(width: 80),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        slides.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? AppColors.deadlineRed
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage < slides.length - 1)
                    FilledButton(
                      onPressed: () => _pageCtrl.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                      child: const Text('İleri'),
                    )
                  else
                    FilledButton(
                      onPressed: _complete,
                      child: const Text('Başla'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final Widget child;
  const _OnboardingSlide({required this.child});

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.all(16), child: child);
}
