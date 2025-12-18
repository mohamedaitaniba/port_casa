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
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
      // Sort by date descending on client side to avoid needing an index
      notifications.sort((a, b) => b.date.compareTo(a.date));
      return notifications;
    });
  }

  // Get all notifications
  Stream<List<AppNotification>> getAllNotificationsStream() {
    return _firestore
        .collection(_collection)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
      // Sort by date descending on client side
      notifications.sort((a, b) => b.date.compareTo(a.date));
      return notifications;
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

  // Create notification for all users
  Future<void> notifyAllUsers({
    required String title,
    required String description,
    required NotificationType type,
    String? anomalyId,
  }) async {
    try {
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();
      
      if (usersSnapshot.docs.isEmpty) {
        print('No users found to notify');
        return;
      }

      print('Notifying ${usersSnapshot.docs.length} users');

      // Create notification for each user
      final batch = _firestore.batch();
      final now = DateTime.now();

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final notificationRef = _firestore.collection(_collection).doc();
        
        final notificationData = {
          'title': title,
          'description': description,
          'type': type.value,
          'date': Timestamp.fromDate(now),
          'userId': userId,
          'isRead': false,
          if (anomalyId != null) 'anomalyId': anomalyId,
        };

        batch.set(notificationRef, notificationData);
      }

      await batch.commit();
      print('Notifications created successfully for all users');
    } catch (e, stackTrace) {
      print('Error notifying all users: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erreur lors de la création des notifications: $e');
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

