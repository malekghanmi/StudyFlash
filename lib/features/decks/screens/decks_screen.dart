import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/deck_provider.dart';
import '../models/deck_model.dart';

class DecksScreen extends ConsumerStatefulWidget {
  const DecksScreen({super.key});

  @override
  ConsumerState<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends ConsumerState<DecksScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(decksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Decks', style: Theme.of(context).textTheme.headlineLarge)
                      .animate().fadeIn().slideY(begin: -0.1),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (v) => setState(() => _search = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search decks...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.text500),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ).animate(delay: 100.ms).fadeIn(),
                ],
              ),
            ),
            Expanded(
              child: decksAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
                error: (_, __) => const Center(child: Text('Error loading decks')),
                data: (decks) {
                  final filtered = _search.isEmpty
                      ? decks
                      : decks
                          .where((d) =>
                              d.title.toLowerCase().contains(_search) ||
                              d.description.toLowerCase().contains(_search))
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text(
                            _search.isEmpty ? 'No decks yet' : 'No results found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _search.isEmpty
                                ? 'Tap + to create your first deck'
                                : 'Try a different search',
                            style: const TextStyle(color: AppColors.text500),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _BigDeckCard(deck: filtered[i], index: i),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/decks/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Deck', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _BigDeckCard extends ConsumerWidget {
  final DeckModel deck;
  final int index;
  const _BigDeckCard({required this.deck, required this.index});

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer ce deck ?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Toutes les flashcards seront supprimées définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.text500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(deckServiceProvider).deleteDeck(deck.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deck supprimé ✅'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => context.go('/decks/${deck.id}'),
        onLongPress: () => _showDeleteDialog(context, ref),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                    child: Text(deck.emoji,
                        style: const TextStyle(fontSize: 30))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deck.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: AppColors.text900)),
                    const SizedBox(height: 4),
                    if (deck.description.isNotEmpty)
                      Text(deck.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppColors.text500, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Chip(
                            label: '${deck.cardCount} cards',
                            color: AppColors.violetSoft,
                            textColor: AppColors.violet),
                        if (deck.isPublic) ...[
                          const SizedBox(width: 8),
                          _Chip(
                              label: '🌍 Public',
                              color: AppColors.successSoft,
                              textColor: AppColors.success),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Delete icon button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 22),
                onPressed: () => _showDeleteDialog(context, ref),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.text300),
            ],
          ),
        ).animate(
            delay: Duration(milliseconds: index * 60)).fadeIn().slideX(begin: 0.05),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color, textColor;
  const _Chip(
      {required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}