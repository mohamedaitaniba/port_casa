import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  // Get notifications stream
  Stream<List<AppNotification>> getNotificationsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    });
  }

  // Get all notifications
  Stream<List<AppNotification>> getAllNotificationsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    });
  }

  // Get unread notifications count
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create notification
  Future<void> createNotification(AppNotification notification) async {
    try {
      await _firestore.collection(_collection).add(notification.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la création de la notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Erreur lors du marquage de la notification: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors du marquage des notifications: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la notification: $e');
    }
  }
}

