import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String anomalyId;
  final String text;
  final String createdBy;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.anomalyId,
    required this.text,
    required this.createdBy,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      anomalyId: data['anomalyId'] ?? '',
      text: data['text'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'anomalyId': anomalyId,
      'text': text,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

