import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // 1. Créer le compte Firebase Auth
      final cred = await ref.read(authServiceProvider)
          .registerWithEmail(_emailCtrl.text.trim(), _passCtrl.text);

      // 2. Mettre à jour le displayName dans Auth
      await cred.user?.updateDisplayName(_nameCtrl.text.trim());

      // 3. ✅ FIX BUG 3 : Enregistrer le profil dans Firestore
      if (cred.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .set({
          'uid': cred.user!.uid,
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'streak': 0,
          'totalCards': 0,
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès ! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );

      // ✅ FIX BUG 3 : On NE fait PAS context.go('/home') manuellement.
      // Le authStateChanges() du router détecte l'utilisateur connecté
      // et redirige automatiquement via le redirect dans router.dart.

    } catch (e) {
      if (!mounted) return;
      // Afficher un message d'erreur lisible
      String errorMsg = e.toString();
      if (errorMsg.contains('email-already-in-use')) {
        errorMsg = 'Cet email est déjà utilisé.';
      } else if (errorMsg.contains('weak-password')) {
        errorMsg = 'Mot de passe trop faible (min. 6 caractères).';
      } else if (errorMsg.contains('invalid-email')) {
        errorMsg = 'Adresse email invalide.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.go('/auth/login'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create account 🚀', style: Theme.of(context).textTheme.displayMedium)
                    .animate().fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text('Start your learning journey today',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.text500))
                    .animate(delay: 50.ms).fadeIn(),
                const SizedBox(height: 36),
                _label('Full Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'John Doe',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.text500)),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 20),
                _label('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.text500)),
                  validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 20),
                _label('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.text500),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.text500),
                      onPressed: () => setState(() => _obscure = !_obscure))),
                  validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 36),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Create Account',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 24),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(color: AppColors.text500, fontSize: 14),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => context.go('/auth/login'),
                            child: const Text('Sign in',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(color: AppColors.text700, fontWeight: FontWeight.w600, fontSize: 14));
}