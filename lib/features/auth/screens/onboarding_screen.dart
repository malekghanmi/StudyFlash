import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardingData(
      emoji: '🧠',
      title: 'Learn with\nFlashcards',
      subtitle: 'Create powerful flashcards and master any subject with spaced repetition science.',
      gradient: AppColors.gradientPrimary,
      bg: AppColors.primary,
    ),
    _OnboardingData(
      emoji: '🤖',
      title: 'AI-Powered\nStudy',
      subtitle: 'Paste any text and let AI generate flashcards and quizzes for you instantly.',
      gradient: LinearGradient(colors: [AppColors.violet, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
      bg: AppColors.violet,
    ),
    _OnboardingData(
      emoji: '🏆',
      title: 'Track Your\nProgress',
      subtitle: 'Compete with friends, earn badges, and watch your knowledge grow every day.',
      gradient: LinearGradient(colors: [AppColors.accent, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
      bg: AppColors.accent,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
          ),
          // Bottom controls
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.08)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) => AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? Colors.white : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () => _controller.previousPage(
                            duration: 300.ms, curve: Curves.easeInOut),
                          child: const Text('Back', style: TextStyle(color: Colors.white)),
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (_currentPage < _pages.length - 1) {
                            _controller.nextPage(duration: 300.ms, curve: Curves.easeInOut);
                          } else {
                            _finish();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 20, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: Text(
                            _currentPage < _pages.length - 1 ? 'Next →' : 'Get Started',
                            style: TextStyle(
                              color: _pages[_currentPage].bg,
                              fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _finish,
                      child: Text('Skip', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String emoji, title, subtitle;
  final LinearGradient gradient;
  final Color bg;
  const _OnboardingData({required this.emoji, required this.title, required this.subtitle, required this.gradient, required this.bg});
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: data.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 60, 32, 160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji card
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: Center(child: Text(data.emoji, style: const TextStyle(fontSize: 56))),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut)
                  .fadeIn(),
              const SizedBox(height: 40),
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1, letterSpacing: -1),
              ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 20),
              Text(
                data.subtitle,
                style: TextStyle(
                  fontSize: 17, color: Colors.white.withOpacity(0.85),
                  height: 1.6, fontWeight: FontWeight.w400),
              ).animate(delay: 250.ms).fadeIn(duration: 400.ms).slideX(begin: -0.1),
            ],
          ),
        ),
      ),
    );
  }
}
