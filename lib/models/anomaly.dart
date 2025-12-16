import 'package:cloud_firestore/cloud_firestore.dart';

enum AnomalyCategory {
  mecanique('Mécanique'),
  electrique('Électrique'),
  vente('Vente'),
  exploitation('Exploitation'),
  hse('HSE'),
  bureauDeMethode('Bureau de méthode');

  final String label;
  const AnomalyCategory(this.label);

  static AnomalyCategory fromString(String value) {
    return AnomalyCategory.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => AnomalyCategory.mecanique,
    );
  }
}

enum AnomalyPriority {
  high('High', 'Haute'),
  medium('Medium', 'Moyenne'),
  low('Low', 'Basse');

  final String value;
  final String labelFr;
  const AnomalyPriority(this.value, this.labelFr);

  static AnomalyPriority fromString(String value) {
    return AnomalyPriority.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => AnomalyPriority.medium,
    );
  }
}

enum AnomalyStatus {
  ouvert('Ouvert', 'Open'),
  enCours('En cours', 'In Progress'),
  resolu('Résolu', 'Resolved');

  final String labelFr;
  final String labelEn;
  const AnomalyStatus(this.labelFr, this.labelEn);

  static AnomalyStatus fromString(String value) {
    return AnomalyStatus.values.firstWhere(
      (e) => e.labelFr.toLowerCase() == value.toLowerCase() || 
             e.labelEn.toLowerCase() == value.toLowerCase(),
      orElse: () => AnomalyStatus.ouvert,
    );
  }
}

class Anomaly {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final AnomalyCategory category;
  final AnomalyPriority priority;
  final AnomalyStatus status;
  final String? assignedTo;
  final String? photoUrl;
  final String createdBy;
  final DateTime createdAt;
  final String? department;

  Anomaly({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.photoUrl,
    required this.createdBy,
    required this.createdAt,
    this.department,
  });

  factory Anomaly.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Anomaly(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      category: AnomalyCategory.fromString(data['category'] ?? ''),
      priority: AnomalyPriority.fromString(data['priority'] ?? ''),
      status: AnomalyStatus.fromString(data['status'] ?? ''),
      assignedTo: data['assignedTo'],
      photoUrl: data['photoUrl'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      department: data['department'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'category': category.label,
      'priority': priority.value,
      'status': status.labelFr,
      'assignedTo': assignedTo,
      'photoUrl': photoUrl,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'department': department,
    };
  }

  Anomaly copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    AnomalyCategory? category,
    AnomalyPriority? priority,
    AnomalyStatus? status,
    String? assignedTo,
    String? photoUrl,
    String? createdBy,
    DateTime? createdAt,
    String? department,
  }) {
    return Anomaly(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      photoUrl: photoUrl ?? this.photoUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      department: department ?? this.department,
    );
  }
}

