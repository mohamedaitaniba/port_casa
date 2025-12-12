import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  inspecteur('inspecteur', 'Inspecteur'),
  superviseur('superviseur', 'Superviseur'),
  admin('admin', 'Administrateur');

  final String value;
  final String label;
  const UserRole(this.value, this.label);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.inspecteur,
    );
  }
}

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? photoUrl;
  final String? department;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.department,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.fromString(data['role'] ?? ''),
      photoUrl: data['photoUrl'],
      department: data['department'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role.value,
      'photoUrl': photoUrl,
      'department': department,
    };
  }

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    String? photoUrl,
    String? department,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      department: department ?? this.department,
    );
  }
}

