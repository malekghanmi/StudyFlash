import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flashcard_model.dart';

final _db = FirebaseFirestore.instance;

final flashcardsProvider = StreamProvider.family<List<FlashcardModel>, String>((ref, deckId) {
  return _db
      .collection('flashcards')
      .where('deckId', isEqualTo: deckId)
      .orderBy('createdAt')
      .snapshots()
      .map((snap) => snap.docs.map(FlashcardModel.fromFirestore).toList());
});

class FlashcardService {
  final _db = FirebaseFirestore.instance;

  Future<void> addCard(FlashcardModel card) async {
    await _db.collection('flashcards').add(card.toFirestore());
    await _db.collection('decks').doc(card.deckId).update({
      'cardCount': FieldValue.increment(1),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateCard(FlashcardModel card) async {
    await _db.collection('flashcards').doc(card.id).update(card.toFirestore());
  }

  Future<void> deleteCard(String cardId, String deckId) async {
    await _db.collection('flashcards').doc(cardId).delete();
    await _db.collection('decks').doc(deckId).update({
      'cardCount': FieldValue.increment(-1),
    });
  }

  Future<void> markReviewed(String cardId) async {
    await _db.collection('flashcards').doc(cardId).update({
      'reviewCount': FieldValue.increment(1),
      'lastReviewed': Timestamp.now(),
    });
  }

  Future<void> addMultipleCards(List<FlashcardModel> cards) async {
    if (cards.isEmpty) return;
    final batch = _db.batch();
    for (final card in cards) {
      final ref = _db.collection('flashcards').doc();
      batch.set(ref, card.toFirestore());
    }
    await batch.commit();
    await _db.collection('decks').doc(cards.first.deckId).update({
      'cardCount': FieldValue.increment(cards.length),
      'updatedAt': Timestamp.now(),
    });
  }
}

final flashcardServiceProvider = Provider<FlashcardService>((ref) => FlashcardService());
