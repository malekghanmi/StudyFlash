import 'package:cloud_firestore/cloud_firestore.dart';

class DeckModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String color;
  final String ownerId;
  final int cardCount;
  final bool isPublic;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeckModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.ownerId,
    this.cardCount = 0,
    this.isPublic = false,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeckModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeckModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      emoji: data['emoji'] ?? '📚',
      color: data['color'] ?? '#6366F1',
      ownerId: data['ownerId'] ?? '',
      cardCount: data['cardCount'] ?? 0,
      isPublic: data['isPublic'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'description': description,
    'emoji': emoji,
    'color': color,
    'ownerId': ownerId,
    'cardCount': cardCount,
    'isPublic': isPublic,
    'tags': tags,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  DeckModel copyWith({int? cardCount, String? title, String? description}) => DeckModel(
    id: id, emoji: emoji, color: color, ownerId: ownerId, isPublic: isPublic, tags: tags,
    createdAt: createdAt, updatedAt: DateTime.now(),
    title: title ?? this.title,
    description: description ?? this.description,
    cardCount: cardCount ?? this.cardCount,
  );
}
