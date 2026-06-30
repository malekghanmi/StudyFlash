import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardModel {
  final String id;
  final String deckId;
  final String question;
  final String answer;
  final String? hint;
  final int difficulty;
  final bool isFavorite;
  final DateTime createdAt;
  final int reviewCount;
  final DateTime? lastReviewed;

  FlashcardModel({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.hint,
    this.difficulty = 3,
    this.isFavorite = false,
    required this.createdAt,
    this.reviewCount = 0,
    this.lastReviewed,
  });

  factory FlashcardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FlashcardModel(
      id: doc.id,
      deckId: data['deckId'] ?? '',
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      hint: data['hint'],
      difficulty: data['difficulty'] ?? 3,
      isFavorite: data['isFavorite'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewCount: data['reviewCount'] ?? 0,
      lastReviewed: (data['lastReviewed'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'deckId': deckId,
    'question': question,
    'answer': answer,
    'hint': hint,
    'difficulty': difficulty,
    'isFavorite': isFavorite,
    'createdAt': Timestamp.fromDate(createdAt),
    'reviewCount': reviewCount,
    'lastReviewed': lastReviewed != null ? Timestamp.fromDate(lastReviewed!) : null,
  };
}
