import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:studymate/features/auth/screens/splash_screen.dart';
import 'package:studymate/features/auth/screens/login_screen.dart';
import 'package:studymate/features/auth/screens/register_screen.dart';
import 'package:studymate/features/home/screens/home_screen.dart';
import 'package:studymate/features/home/screens/main_shell.dart';
import 'package:studymate/features/decks/screens/decks_screen.dart';
import 'package:studymate/features/decks/screens/deck_detail_screen.dart';
import 'package:studymate/features/decks/screens/create_deck_screen.dart';
import 'package:studymate/features/flashcards/screens/flashcard_study_screen.dart';
import 'package:studymate/features/flashcards/screens/create_flashcard_screen.dart';
import 'package:studymate/features/ai/screens/ai_generator_screen.dart';
import 'package:studymate/features/profile/screens/profile_screen.dart';
import 'package:studymate/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthChangeNotifier();

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Page not found',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.text900)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Go Home', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;

      // ✅ Le splash s'affiche TOUJOURS — jamais redirigé automatiquement.
      // C'est SplashScreen qui décide lui-même où aller après l'animation.
      if (loc == '/splash') return null;

      final isPublicRoute =
          loc == '/auth/login' || loc == '/auth/register';

      // Non connecté sur page privée → login
      if (!isLoggedIn && !isPublicRoute) return '/auth/login';

      // Connecté sur login ou register → home
      if (isLoggedIn && isPublicRoute) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/decks', builder: (_, __) => const DecksScreen()),
          GoRoute(path: '/decks/create', builder: (_, __) => const CreateDeckScreen()),
          GoRoute(
            path: '/decks/:deckId',
            builder: (_, state) => DeckDetailScreen(deckId: state.pathParameters['deckId']!),
          ),
          GoRoute(
            path: '/decks/:deckId/study',
            builder: (_, state) => FlashcardStudyScreen(deckId: state.pathParameters['deckId']!),
          ),
          GoRoute(
            path: '/decks/:deckId/add-card',
            builder: (_, state) => CreateFlashcardScreen(deckId: state.pathParameters['deckId']!),
          ),
          GoRoute(path: '/ai', builder: (_, __) => const AiGeneratorScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});