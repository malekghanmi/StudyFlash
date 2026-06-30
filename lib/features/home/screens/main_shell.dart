import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/decks')) return 1;
    if (loc.startsWith('/ai')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: 'Home', selected: idx == 0,
                    onTap: () => context.go('/home')),
                _NavItem(icon: Icons.library_books_rounded, label: 'Decks', selected: idx == 1,
                    onTap: () => context.go('/decks')),
                _NavItem(icon: Icons.auto_awesome_rounded, label: 'AI', selected: idx == 2,
                    onTap: () => context.go('/ai'), isAi: true),
                _NavItem(icon: Icons.person_rounded, label: 'Profile', selected: idx == 3,
                    onTap: () => context.go('/profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isAi;

  const _NavItem({
    required this.icon, required this.label, required this.selected, required this.onTap, this.isAi = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isAi) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.gradientPrimary : null,
            color: selected ? null : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? Colors.white : AppColors.text500, size: 20),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(
                color: selected ? Colors.white : AppColors.text500,
                fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.text300, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              color: selected ? AppColors.primary : AppColors.text300,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
