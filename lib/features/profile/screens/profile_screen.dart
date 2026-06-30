import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../decks/providers/deck_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final decksAsync = ref.watch(decksProvider);
    final name = user?.displayName ?? 'Learner';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(initial,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800)),
                      ),
                    ).animate().scale(curve: Curves.elasticOut),
                    const SizedBox(height: 12),
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800))
                        .animate(delay: 100.ms).fadeIn(),
                    const SizedBox(height: 4),
                    Text(email,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8), fontSize: 14))
                        .animate(delay: 150.ms).fadeIn(),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    decksAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (decks) {
                        final totalCards = decks.fold<int>(0, (s, d) => s + d.cardCount);
                        return Row(
                          children: [
                            Expanded(child: _Stat('📚', '${decks.length}', 'Decks')),
                            const SizedBox(width: 12),
                            Expanded(child: _Stat('🃏', '$totalCards', 'Cards')),
                            const SizedBox(width: 12),
                            Expanded(child: _Stat('🔥', '7', 'Day Streak')),
                          ],
                        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2);
                      },
                    ),
                    const SizedBox(height: 28),

                    _Section('Account', [
                      _SettingTile(
                        icon: Icons.person_outline,
                        label: 'Edit Profile',
                        onTap: () => _showEditProfileDialog(context, ref, name),
                      ),
                      _SettingTile(
                        icon: Icons.lock_outline,
                        label: 'Change Password',
                        onTap: () => _showChangePasswordDialog(context, ref, email),
                      ),
                      _SettingTile(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () => _showSnackbar(context, 'Notifications coming soon!'),
                      ),
                      _SettingTile(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        onTap: () => _showSnackbar(context, 'Language: French / English'),
                      ),
                    ]).animate(delay: 300.ms).fadeIn(),
                    const SizedBox(height: 16),

                    _Section('Preferences', [
                      _SettingTile(
                        icon: Icons.dark_mode_outlined,
                        label: 'Appearance',
                        onTap: () => _showSnackbar(context, 'Light mode active'),
                      ),
                      _SettingTile(
                        icon: Icons.data_usage_outlined,
                        label: 'Storage & Cache',
                        onTap: () => _showSnackbar(context, 'Cache cleared!'),
                      ),
                    ]).animate(delay: 350.ms).fadeIn(),
                    const SizedBox(height: 16),

                    _Section('About', [
                      _SettingTile(
                        icon: Icons.info_outline,
                        label: 'About StudyMate',
                        onTap: () => _showAboutDialog(context),
                      ),
                      _SettingTile(
                        icon: Icons.star_outline,
                        label: 'Rate the App',
                        onTap: () => _showSnackbar(context, '⭐⭐⭐⭐⭐ Merci !'),
                      ),
                      _SettingTile(
                        icon: Icons.feedback_outlined,
                        label: 'Send Feedback',
                        onTap: () => _showFeedbackDialog(context),
                      ),
                    ]).animate(delay: 400.ms).fadeIn(),
                    const SizedBox(height: 24),

                    // ✅ Sign Out : force navigation vers /auth/login
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Text('Se déconnecter ?',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            content: const Text('Tu vas être déconnecté de StudyMate.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler',
                                    style: TextStyle(color: AppColors.text500)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Se déconnecter',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(authServiceProvider).signOut();
                          await Future.delayed(const Duration(milliseconds: 300));
                          if (context.mounted) context.go('/auth/login');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.errorSoft,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.error.withOpacity(0.2)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, color: AppColors.error),
                            SizedBox(width: 10),
                            Text('Sign Out',
                                style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                    ).animate(delay: 450.ms).fadeIn(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.text500)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              await ref.read(authServiceProvider).updateDisplayName(ctrl.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated! ✅'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref, String email) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('A reset link will be sent to:\n$email'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.text500)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              await ref.read(authServiceProvider).resetPassword(email);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reset email sent! Check your inbox 📧'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('📚', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('StudyMate', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0', style: TextStyle(color: AppColors.text500)),
            SizedBox(height: 8),
            Text('A premium flashcard app built with Flutter & Firebase.',
                style: TextStyle(color: AppColors.text700)),
            SizedBox(height: 8),
            Text('Powered by Gemini AI 🤖', style: TextStyle(color: AppColors.text500)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Send Feedback', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Write your feedback here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.text500)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback sent! Thank you 🙏'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji, value, label;
  const _Stat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.primary)),
          Text(label,
              style: const TextStyle(color: AppColors.text500, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4),
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.text500,
                  letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.text700, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.text900))),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.text300, size: 20),
          ],
        ),
      ),
    );
  }
}