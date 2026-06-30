import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      emoji: '📚',
      title: 'StudyMate',
      subtitle: 'Apprends plus vite, retiens mieux',
      description: 'La méthode des flashcards est prouvée scientifiquement pour booster ta mémoire à long terme.',
      color1: const Color(0xFF6366F1),
      color2: const Color(0xFF8B5CF6),
    ),
    _OnboardingData(
      emoji: '✨',
      title: 'IA Intégrée',
      subtitle: 'Génère des flashcards en 1 clic',
      description: 'Colle n\'importe quel texte de cours et l\'IA crée automatiquement des flashcards parfaites pour toi.',
      color1: const Color(0xFF8B5CF6),
      color2: const Color(0xFFEC4899),
    ),
    _OnboardingData(
      emoji: '🎯',
      title: 'Suivi de Progression',
      subtitle: 'Mesure tes progrès chaque jour',
      description: 'Suis ton score, ta série de jours et vois exactement quelles cartes tu maîtrises ou pas encore.',
      color1: const Color(0xFF06B6D4),
      color2: const Color(0xFF6366F1),
    ),
    _OnboardingData(
      emoji: '🔥',
      title: 'Prêt à commencer ?',
      subtitle: 'Rejoins des milliers d\'étudiants',
      description: 'Crée ton compte gratuitement ou connecte-toi pour reprendre là où tu t\'es arrêté.',
      color1: const Color(0xFFF59E0B),
      color2: const Color(0xFFEF4444),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
          ),

          // Skip button
          Positioned(
            top: 52,
            right: 24,
            child: !_isLastPage
                ? GestureDetector(
                    onTap: _skip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Passer',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Bottom controls
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    final selected = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: selected ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Dernière page : 2 boutons
                if (_isLastPage) ...[
                  GestureDetector(
                    onTap: () => context.go('/auth/register'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Créer un compte 🚀',
                          style: TextStyle(color: _pages[_currentPage].color1, fontWeight: FontWeight.w800, fontSize: 17),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                  const SizedBox(height: 14),

                  GestureDetector(
                    onTap: () => context.go('/auth/login'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                      ),
                      child: const Center(
                        child: Text(
                          'J\'ai déjà un compte',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                ] else ...[
                  GestureDetector(
                    onTap: _next,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Suivant →',
                          style: TextStyle(color: _pages[_currentPage].color1, fontWeight: FontWeight.w800, fontSize: 17),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String emoji, title, subtitle, description;
  final Color color1, color2;
  const _OnboardingData({
    required this.emoji, required this.title, required this.subtitle,
    required this.description, required this.color1, required this.color2,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [data.color1, data.color2],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(44),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: Center(child: Text(data.emoji, style: const TextStyle(fontSize: 68))),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).fadeIn(duration: 400.ms),
              const SizedBox(height: 48),
              Text(data.title, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1, height: 1.1),
              ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.3),
              const SizedBox(height: 14),
              Text(data.subtitle, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9), height: 1.3),
              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.3),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(data.description, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9), height: 1.6, fontWeight: FontWeight.w400),
                ),
              ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }
}