import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studymate/core/theme/app_theme.dart';
import 'package:studymate/features/flashcards/models/flashcard_model.dart';
import 'package:studymate/features/flashcards/providers/flashcard_provider.dart';

class CreateFlashcardScreen extends ConsumerStatefulWidget {
  final String deckId;
  const CreateFlashcardScreen({super.key, required this.deckId});

  @override
  ConsumerState<CreateFlashcardScreen> createState() => _CreateFlashcardScreenState();
}

class _CreateFlashcardScreenState extends ConsumerState<CreateFlashcardScreen> {
  final _questionCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();
  final _hintCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  int _difficulty = 3;

  @override
  void dispose() {
    _questionCtrl.dispose();
    _answerCtrl.dispose();
    _hintCtrl.dispose();
    super.dispose();
  }

  Future<void> _save({bool addAnother = false}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final card = FlashcardModel(
        id: '',
        deckId: widget.deckId,
        question: _questionCtrl.text.trim(),
        answer: _answerCtrl.text.trim(),
        hint: _hintCtrl.text.trim().isEmpty ? null : _hintCtrl.text.trim(),
        difficulty: _difficulty,
        createdAt: DateTime.now(),
      );
      await ref.read(flashcardServiceProvider).addCard(card);
      if (!mounted) return;
      if (addAnother) {
        _questionCtrl.clear();
        _answerCtrl.clear();
        _hintCtrl.clear();
        setState(() => _difficulty = 3);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Card added! Add another.'),
              backgroundColor: AppColors.success));
      } else {
        context.go('/decks/${widget.deckId}');
      }
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
        title: const Text('Add Flashcard'),
        leading: BackButton(onPressed: () => context.go('/decks/${widget.deckId}')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Question'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _questionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Enter your question here...'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a question' : null,
              ).animate().fadeIn(delay: 50.ms),
              const SizedBox(height: 20),

              const _Label('Answer'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _answerCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Enter the answer here...'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter an answer' : null,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 20),

              const _Label('Hint (Optional)'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _hintCtrl,
                decoration: const InputDecoration(hintText: 'Add a helpful hint...'),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 24),

              const _Label('Difficulty'),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (i) {
                  final level = i + 1;
                  final selected = level == _difficulty;
                  return GestureDetector(
                    onTap: () => setState(() => _difficulty = level),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.only(right: 10),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('$level',
                            style: TextStyle(
                                color: selected ? Colors.white : AppColors.text500,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  );
                }),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 36),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => _save(addAnother: true),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('+ Add Another',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(14)),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('Save Card',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.text700));
}