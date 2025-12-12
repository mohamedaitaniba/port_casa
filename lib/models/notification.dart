import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  newAnomaly('new', 'Nouvelle anomalie'),
  assign('assign', 'Assignation'),
  resolved('resolved', 'Résolu'),
  update('update', 'Mise à jour');

  final String value;
  final String label;
  const NotificationType(this.value, this.label);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => NotificationType.newAnomaly,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String description;
  final NotificationType type;
  final DateTime date;
  final bool isRead;
  final String? anomalyId;

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    this.isRead = false,
    this.anomalyId,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: NotificationType.fromString(data['type'] ?? ''),
      date: (data['date'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      anomalyId: data['anomalyId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.value,
      'date': Timestamp.fromDate(date),
      'isRead': isRead,
      'anomalyId': anomalyId,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? description,
    NotificationType? type,
    DateTime? date,
    bool? isRead,
    String? anomalyId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      anomalyId: anomalyId ?? this.anomalyId,
    );
  }
}

