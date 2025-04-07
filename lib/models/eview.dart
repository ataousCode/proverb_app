import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String text;
  final int rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromFirestore(Map<String, dynamic> data, String id) {
    return Review(
      id: id,
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      rating: data['rating'] ?? 5,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'text': text,
      'rating': rating,
      'createdAt': createdAt,
    };
  }
}
