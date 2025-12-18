import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String anomalyId;
  final String text;
  final String createdBy;
  final DateTime createdAt;
  final String? imageUrl;

  Comment({
    required this.id,
    required this.anomalyId,
    required this.text,
    required this.createdBy,
    required this.createdAt,
    this.imageUrl,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      anomalyId: data['anomalyId'] ?? '',
      text: data['text'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'anomalyId': anomalyId,
      'text': text,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  Comment copyWith({
    String? id,
    String? anomalyId,
    String? text,
    String? createdBy,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return Comment(
      id: id ?? this.id,
      anomalyId: anomalyId ?? this.anomalyId,
      text: text ?? this.text,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

