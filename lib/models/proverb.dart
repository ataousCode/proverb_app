import 'package:cloud_firestore/cloud_firestore.dart';

class Proverb {
  final String id;
  final String text;
  final String author;
  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Proverb({
    required this.id,
    required this.text,
    required this.author,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Proverb.fromFirestore(Map<String, dynamic> data, String id) {
    return Proverb(
      id: id,
      text: data['text'] ?? '',
      author: data['author'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'author': author,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
