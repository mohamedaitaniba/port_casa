import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/anomaly.dart';

class FirebaseAnomalyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'anomalies';

  // Get all anomalies stream
  Stream<List<Anomaly>> getAnomaliesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Anomaly.fromFirestore(doc)).toList();
    });
  }

  // Get anomalies by status
  Stream<List<Anomaly>> getAnomaliesByStatus(AnomalyStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.labelFr)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Anomaly.fromFirestore(doc)).toList();
    });
  }

  // Get anomalies by priority
  Stream<List<Anomaly>> getAnomaliesByPriority(AnomalyPriority priority) {
    return _firestore
        .collection(_collection)
        .where('priority', isEqualTo: priority.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Anomaly.fromFirestore(doc)).toList();
    });
  }

  // Get anomalies by category
  Stream<List<Anomaly>> getAnomaliesByCategory(AnomalyCategory category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category.label)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Anomaly.fromFirestore(doc)).toList();
    });
  }

  // Get single anomaly
  Future<Anomaly?> getAnomaly(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Anomaly.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'anomalie: $e');
    }
  }

  // Create anomaly
  Future<String> createAnomaly(Anomaly anomaly) async {
    try {
      final docRef = await _firestore.collection(_collection).add(anomaly.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'anomalie: $e');
    }
  }

  // Update anomaly
  Future<void> updateAnomaly(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'anomalie: $e');
    }
  }

  // Update anomaly status
  Future<void> updateAnomalyStatus(String id, AnomalyStatus status) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'status': status.labelFr,
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Delete anomaly
  Future<void> deleteAnomaly(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'anomalie: $e');
    }
  }

  // Get anomaly count by status
  Future<Map<String, int>> getAnomalyCountByStatus() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final Map<String, int> counts = {
        'total': snapshot.docs.length,
        'ouvert': 0,
        'en_cours': 0,
        'resolu': 0,
      };

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String?;
        if (status != null) {
          final statusLower = status.toLowerCase();
          if (statusLower == 'ouvert') {
            counts['ouvert'] = (counts['ouvert'] ?? 0) + 1;
          } else if (statusLower == 'en cours') {
            counts['en_cours'] = (counts['en_cours'] ?? 0) + 1;
          } else if (statusLower == 'résolu') {
            counts['resolu'] = (counts['resolu'] ?? 0) + 1;
          }
        }
      }

      return counts;
    } catch (e) {
      throw Exception('Erreur lors du comptage des anomalies: $e');
    }
  }

  // Get high priority anomalies
  Future<List<Anomaly>> getHighPriorityAnomalies() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('priority', isEqualTo: 'High')
          .where('status', whereIn: ['Ouvert', 'En cours'])
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) => Anomaly.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des alertes: $e');
    }
  }

  // Search anomalies
  Future<List<Anomaly>> searchAnomalies(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // For production, consider using Algolia or similar
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('title')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .get();

      return snapshot.docs.map((doc) => Anomaly.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }
}

