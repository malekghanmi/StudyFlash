import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../flashcards/providers/flashcard_provider.dart';
import '../../flashcards/models/flashcard_model.dart';
import '../providers/deck_provider.dart';

class DeckDetailScreen extends ConsumerWidget {
  final String deckId;
  const DeckDetailScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsync = ref.watch(deckByIdProvider(deckId));
    final cardsAsync = ref.watch(flashcardsProvider(deckId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: deckAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('Error')),
        data: (deck) {
          if (deck == null) return const Center(child: Text('Deck not found'));
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => context.go('/decks'),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Supprimer ce deck ?',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          content: const Text('Toutes les flashcards seront supprimées.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuler',
                                  style: TextStyle(color: AppColors.text500)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Supprimer',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await ref.read(deckServiceProvider).deleteDeck(deckId);
                        if (context.mounted) context.go('/decks');
                      }
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(deck.emoji, style: const TextStyle(fontSize: 56))
                            .animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 12),
                        Text(deck.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 24))
                            .animate(delay: 100.ms).fadeIn(),
                        if (deck.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                            child: Text(deck.description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14))
                                .animate(delay: 150.ms).fadeIn(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: '▶ Study Now',
                          gradient: AppColors.gradientPrimary,
                          onTap: deck.cardCount == 0
                              ? null
                              : () => context.go('/decks/$deckId/study'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _IconActionButton(
                        icon: Icons.add_rounded,
                        label: 'Add Card',
                        onTap: () => context.go('/decks/$deckId/add-card'),
                      ),
                    ],
                  ),
                ),
              ),

              // Cards list header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text('Flashcards (${deck.cardCount})',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ),

              // Cards
              cardsAsync.when(
                loading: () => const SliverToBoxAdapter(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary))),
                error: (_, __) =>
                    const SliverToBoxAdapter(child: Text('Error')),
                data: (cards) {
                  if (cards.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              const Text('🃏',
                                  style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 16),
                              const Text('No cards yet',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18)),
                              const SizedBox(height: 8),
                              const Text('Add your first flashcard!',
                                  style: TextStyle(
                                      color: AppColors.text500)),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => context
                                    .go('/decks/$deckId/add-card'),
                                child: const Text('Add Card'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            i == cards.length - 1 ? 100 : 12),
                        child: _FlashcardListItem(
                            card: cards[i], index: i, ref: ref),
                      ),
                      childCount: cards.length,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  const _ActionButton(
      {required this.label, required this.gradient, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.cardShadow,
          ),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _IconActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _FlashcardListItem extends StatefulWidget {
  final FlashcardModel card;
  final int index;
  final WidgetRef ref;
  const _FlashcardListItem(
      {required this.card, required this.index, required this.ref});

  @override
  State<_FlashcardListItem> createState() => _FlashcardListItemState();
}

class _FlashcardListItemState extends State<_FlashcardListItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _expanded ? AppColors.primary : AppColors.border,
              width: _expanded ? 1.5 : 1),
          boxShadow:
              _expanded ? AppColors.cardShadow : AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.violetSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('${widget.index + 1}',
                        style: const TextStyle(
                            color: AppColors.violet,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(widget.card.question,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.text900)),
                ),
                // Delete card button
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.text300, size: 18),
                  onPressed: () async {
                    await widget.ref
                        .read(flashcardServiceProvider)
                        .deleteCard(widget.card.id, widget.card.deckId);
                  },
                ),
                Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.text300),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('A: ',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                  Expanded(
                      child: Text(widget.card.answer,
                          style: const TextStyle(
                              color: AppColors.text700, fontSize: 14))),
                ],
              ),
            ],
          ],
        ),
      ).animate(
          delay: Duration(
              milliseconds: widget.index * 50)).fadeIn().slideY(begin: 0.1),
    );
  }
}