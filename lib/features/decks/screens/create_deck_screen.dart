import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/deck_model.dart';
import '../providers/deck_provider.dart';

const _emojis = ['📚', '🧠', '🔬', '🧮', '🌍', '🎨', '💻', '📖', '🏛️', '🧬', '🎵', '🌱', '🚀', '⚡', '🔭', '🎭'];

class CreateDeckScreen extends ConsumerStatefulWidget {
  const CreateDeckScreen({super.key});

  @override
  ConsumerState<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends ConsumerState<CreateDeckScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedEmoji = '📚';
  bool _isPublic = false;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider)!;
      final deck = DeckModel(
        id: '', title: _titleCtrl.text.trim(), description: _descCtrl.text.trim(),
        emoji: _selectedEmoji, color: '#6366F1', ownerId: user.uid,
        isPublic: _isPublic, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      final id = await ref.read(deckServiceProvider).createDeck(deck);
      if (!mounted) return;
      context.go('/decks/$id');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Deck'),
        leading: BackButton(onPressed: () => context.go('/decks')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji picker
              Text('Choose an Emoji', style: Theme.of(context).textTheme.titleMedium)
                  .animate().fadeIn(),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _emojis.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = _emojis[i]),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.only(right: 10),
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: _selectedEmoji == _emojis[i] ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedEmoji == _emojis[i] ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(child: Text(_emojis[i], style: const TextStyle(fontSize: 24))),
                    ),
                  ),
                ),
              ).animate(delay: 50.ms).fadeIn(),
              const SizedBox(height: 28),
              Text('Deck Title', style: Theme.of(context).textTheme.titleMedium).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Spanish Vocabulary'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
              ).animate(delay: 120.ms).fadeIn(),
              const SizedBox(height: 20),
              Text('Description (optional)', style: Theme.of(context).textTheme.titleMedium).animate(delay: 150.ms).fadeIn(),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'What is this deck about?'),
              ).animate(delay: 170.ms).fadeIn(),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Text('🌍', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Make Public', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.text900)),
                          Text('Others can find and use this deck', style: TextStyle(color: AppColors.text500, fontSize: 13)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isPublic,
                      onChanged: (v) => setState(() => _isPublic = v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: 36),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.cardShadow,
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Create Deck',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
