import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studymate/features/auth/providers/auth_provider.dart';
import 'package:studymate/features/decks/models/deck_model.dart';

// Mes decks (nécessite l'index: ownerId ASC + updatedAt DESC)
final decksProvider = StreamProvider<List<DeckModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('decks')
      .where('ownerId', isEqualTo: user.uid)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(DeckModel.fromFirestore).toList());
});

// Decks publics — tri côté client pour éviter le besoin d'index composite
final publicDecksProvider = StreamProvider<List<DeckModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider);

  return FirebaseFirestore.instance
      .collection('decks')
      .where('isPublic', isEqualTo: true)
      .limit(30)
      .snapshots()
      .map((snap) {
        final all = snap.docs.map(DeckModel.fromFirestore).toList();
        // Exclure ses propres decks des decks publics
        final others = currentUser != null
            ? all.where((d) => d.ownerId != currentUser.uid).toList()
            : all;
        // Tri par date décroissante côté client
        others.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return others;
      });
});

final deckByIdProvider =
    FutureProvider.family<DeckModel?, String>((ref, deckId) async {
  final doc = await FirebaseFirestore.instance
      .collection('decks')
      .doc(deckId)
      .get();
  if (!doc.exists) return null;
  return DeckModel.fromFirestore(doc);
});

class DeckService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createDeck(DeckModel deck) async {
    final doc = await _db.collection('decks').add(deck.toFirestore());
    return doc.id;
  }

  Future<void> updateDeck(DeckModel deck) async {
    await _db.collection('decks').doc(deck.id).update(deck.toFirestore());
  }

  Future<void> deleteDeck(String deckId) async {
    final batch = _db.batch();
    final cards = await _db
        .collection('flashcards')
        .where('deckId', isEqualTo: deckId)
        .get();
    for (final card in cards.docs) {
      batch.delete(card.reference);
    }
    batch.delete(_db.collection('decks').doc(deckId));
    await batch.commit();
  }
}

final deckServiceProvider = Provider<DeckService>((ref) => DeckService());