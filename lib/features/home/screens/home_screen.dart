import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studymate/core/theme/app_theme.dart';
import 'package:studymate/features/auth/providers/auth_provider.dart';
import 'package:studymate/features/decks/providers/deck_provider.dart';
import 'package:studymate/features/decks/models/deck_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final decksAsync = ref.watch(decksProvider);
    final publicDecksAsync = ref.watch(publicDecksProvider);
    final name = user?.displayName?.split(' ').first ?? 'Learner';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$greeting 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.text500))
                              .animate()
                              .fadeIn(delay: 50.ms),
                          Text(name,
                              style: Theme.of(context).textTheme.headlineLarge)
                              .animate()
                              .fadeIn(delay: 100.ms)
                              .slideX(begin: -0.1),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/profile'),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Center(
                          child: Text(
                            (user?.displayName ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                        ),
                      ),
                    ).animate(delay: 150.ms).scale(curve: Curves.elasticOut),
                  ],
                ),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: _StatsRow(decks: decksAsync.valueOrNull ?? [])
                    .animate(delay: 200.ms)
                    .fadeIn()
                    .slideY(begin: 0.2),
              ),
            ),

            // AI Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: GestureDetector(
                  onTap: () => context.go('/ai'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('✨ AI Flashcard Generator',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                              const SizedBox(height: 6),
                              Text('Paste any text → instant flashcards',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Try →',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
              ),
            ),

            // ── Mes Decks ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Decks',
                        style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () => context.go('/decks'),
                      child: const Text('See all',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ).animate(delay: 350.ms).fadeIn(),
              ),
            ),

            decksAsync.when(
              loading: () =>
                  SliverToBoxAdapter(child: _LoadingDecks()),
              error: (_, __) => const SliverToBoxAdapter(
                  child: Center(child: Text('Error loading decks'))),
              data: (decks) {
                if (decks.isEmpty) {
                  return SliverToBoxAdapter(
                      child: _EmptyDecks(
                          onTap: () => context.go('/decks/create')));
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: _DeckCard(deck: decks[i], index: i),
                    ),
                    childCount: decks.length,
                  ),
                );
              },
            ),

            // ── Decks Publics ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Community Decks',
                        style: Theme.of(context).textTheme.titleLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.violetSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Public',
                          style: TextStyle(
                              color: AppColors.violet,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ),
                  ],
                ).animate(delay: 400.ms).fadeIn(),
              ),
            ),

            publicDecksAsync.when(
              loading: () =>
                  SliverToBoxAdapter(child: _LoadingDecks()),
              error: (_, __) => const SliverToBoxAdapter(
                  child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Error loading public decks',
                    style: TextStyle(color: AppColors.text500)),
              )),
              data: (decks) {
                if (decks.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text('No public decks yet.',
                          style: TextStyle(color: AppColors.text500)),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: EdgeInsets.fromLTRB(
                          24, 0, 24, i == decks.length - 1 ? 100 : 12),
                      child: _PublicDeckCard(deck: decks[i], index: i),
                    ),
                    childCount: decks.length,
                  ),
                );
              },
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
        label: const Text('New Deck',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ).animate(delay: 500.ms).scale(curve: Curves.elasticOut),
    );
  }
}

// ── Widgets ──

class _StatsRow extends StatelessWidget {
  final List<DeckModel> decks;
  const _StatsRow({required this.decks});

  @override
  Widget build(BuildContext context) {
    final totalCards = decks.fold<int>(0, (sum, d) => sum + d.cardCount);
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                label: 'Decks',
                value: '${decks.length}',
                icon: '📚',
                color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                label: 'Cards',
                value: '$totalCards',
                icon: '🃏',
                color: AppColors.violet)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                label: 'Streak',
                value: '7',
                icon: '🔥',
                color: AppColors.warning)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.text500,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final DeckModel deck;
  final int index;
  const _DeckCard({required this.deck, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/decks/${deck.id}'),
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                  child: Text(deck.emoji,
                      style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deck.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.text900)),
                  const SizedBox(height: 4),
                  Text('${deck.cardCount} cards',
                      style: const TextStyle(
                          color: AppColors.text500, fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.violetSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Study →',
                  style: TextStyle(
                      color: AppColors.violet,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ],
        ),
      )
          .animate(
              delay: Duration(milliseconds: 400 + index * 80))
          .fadeIn()
          .slideX(begin: 0.1),
    );
  }
}

// Card pour les decks publics (avec badge auteur)
class _PublicDeckCard extends StatelessWidget {
  final DeckModel deck;
  final int index;
  const _PublicDeckCard({required this.deck, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/decks/${deck.id}'),
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.violetSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                  child: Text(deck.emoji,
                      style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deck.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.text900)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${deck.cardCount} cards',
                          style: const TextStyle(
                              color: AppColors.text500, fontSize: 12)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Public',
                            style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('View →',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ],
        ),
      )
          .animate(
              delay: Duration(milliseconds: 500 + index * 80))
          .fadeIn()
          .slideX(begin: 0.1),
    );
  }
}

class _EmptyDecks extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyDecks({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.border, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              const Text('📭', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text('No decks yet',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.text900)),
              const SizedBox(height: 8),
              const Text('Create your first deck to start learning!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.text500)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Create Deck',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingDecks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          2,
          (i) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Container(
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(
                        duration: 1000.ms,
                        color: Colors.white.withOpacity(0.5)),
              )),
    );
  }
}