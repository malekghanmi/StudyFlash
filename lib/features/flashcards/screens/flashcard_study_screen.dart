import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studymate/core/theme/app_theme.dart';
import 'package:studymate/features/flashcards/models/flashcard_model.dart';
import 'package:studymate/features/flashcards/providers/flashcard_provider.dart';

class FlashcardStudyScreen extends ConsumerStatefulWidget {
  final String deckId;
  const FlashcardStudyScreen({super.key, required this.deckId});

  @override
  ConsumerState<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends ConsumerState<FlashcardStudyScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showAnswer = false;
  int _known = 0;
  int _learning = 0;
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  // ── Minuteur ──
  late Stopwatch _stopwatch;
  Timer? _ticker;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnim = Tween<double>(begin: 0, end: pi).animate(
        CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));

    // Démarrer le minuteur dès l'entrée
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds = _stopwatch.elapsed.inSeconds);
    });
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _stopwatch.stop();
    _ticker?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Couleur du timer selon la durée
  Color get _timerColor {
    if (_elapsedSeconds < 60) return AppColors.success;
    if (_elapsedSeconds < 180) return AppColors.warning;
    return AppColors.error;
  }

  void _flip() {
    setState(() => _showAnswer = !_showAnswer);
    if (_showAnswer) {
      _flipCtrl.forward();
    } else {
      _flipCtrl.reverse();
    }
  }

  void _next(List<FlashcardModel> cards, bool knew) {
    if (knew) _known++; else _learning++;
    ref.read(flashcardServiceProvider).markReviewed(cards[_currentIndex].id);
    setState(() {
      _showAnswer = false;
      _flipCtrl.reset();
      if (_currentIndex < cards.length - 1) {
        _currentIndex++;
      } else {
        _stopwatch.stop();
        _ticker?.cancel();
        _showResults(cards.length);
      }
    });
  }

  void _showResults(int total) {
    final totalTime = _elapsedSeconds;
    final avgPerCard = total > 0 ? (totalTime / total).round() : 0;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true, // ✅ permet au sheet de prendre la hauteur nécessaire
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                const Text('Session Complete!',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColors.text900)),
                const SizedBox(height: 6),
                Text('You reviewed $total cards',
                    style: const TextStyle(color: AppColors.text500, fontSize: 15)),
                const SizedBox(height: 20),

                // Stats : connus + en cours
                Row(
                  children: [
                    Expanded(child: _ResultStat(label: 'Known', value: '$_known', color: AppColors.success)),
                    const SizedBox(width: 10),
                    Expanded(child: _ResultStat(label: 'Learning', value: '$_learning', color: AppColors.warning)),
                  ],
                ),
                const SizedBox(height: 10),

                // Stats : durée totale + moyenne
                Row(
                  children: [
                    Expanded(child: _ResultStat(label: 'Durée totale', value: _formatDuration(totalTime), color: AppColors.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: _ResultStat(label: 'Moy. / carte', value: '${avgPerCard}s', color: AppColors.violet)),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(16)),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      context.go('/decks/${widget.deckId}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Back to Deck',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}min' : '${m}min ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(flashcardsProvider(widget.deckId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Study Mode'),
        leading: BackButton(onPressed: () => context.go('/decks/${widget.deckId}'),
            color: AppColors.text900),
        // ── Minuteur dans l'AppBar ──
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _timerColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _timerColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_rounded, size: 14, color: _timerColor),
                    const SizedBox(width: 5),
                    Text(
                      _formattedTime,
                      style: TextStyle(
                          color: _timerColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: cardsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) => const Center(child: Text('Error')),
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(child: Text('No cards to study'));
          }
          if (_currentIndex >= cards.length) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final card = cards[_currentIndex];
          final progress = (_currentIndex + 1) / cards.length;

          return Column(
            children: [
              // Progress
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_currentIndex + 1} / ${cards.length}',
                            style: const TextStyle(
                                color: AppColors.text500,
                                fontWeight: FontWeight.w600)),
                        Text(
                            '${(_known / (cards.length > 0 ? cards.length : 1) * 100).toStringAsFixed(0)}% known',
                            style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor:
                            const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              // Flip Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: GestureDetector(
                    onTap: _flip,
                    child: AnimatedBuilder(
                      animation: _flipAnim,
                      builder: (_, __) {
                        final angle = _flipAnim.value;
                        final showFront = angle < pi / 2;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          child: showFront
                              ? _CardFace(
                                  text: card.question,
                                  label: 'QUESTION',
                                  isPrimary: true)
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(pi),
                                  child: _CardFace(
                                      text: card.answer,
                                      label: 'ANSWER',
                                      isPrimary: false),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              if (!_showAnswer)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app_rounded,
                            color: AppColors.text300, size: 18),
                        SizedBox(width: 8),
                        Text('Tap card to reveal answer',
                            style: TextStyle(
                                color: AppColors.text500,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ).animate().fadeIn(),
                ),

              if (_showAnswer)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _next(cards, false),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: AppColors.errorSoft,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: const Column(
                              children: [
                                Text('😕', style: TextStyle(fontSize: 24)),
                                SizedBox(height: 4),
                                Text('Still learning',
                                    style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _next(cards, true),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: AppColors.successSoft,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.success.withOpacity(0.3)),
                            ),
                            child: const Column(
                              children: [
                                Text('✅', style: TextStyle(fontSize: 24)),
                                SizedBox(height: 4),
                                Text('Got it!',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideY(begin: 0.2),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String text, label;
  final bool isPrimary;
  const _CardFace(
      {required this.text, required this.label, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient:
            isPrimary ? AppColors.gradientSoft : AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: isPrimary ? AppColors.border : Colors.transparent),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: isPrimary
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.8))),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isPrimary ? AppColors.text900 : Colors.white,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ResultStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w800, fontSize: 24)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}