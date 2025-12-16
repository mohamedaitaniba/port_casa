import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'comments';

  // Get comments stream for an anomaly
  Stream<List<Comment>> getCommentsStream(String anomalyId) {
    return _firestore
        .collection(_collection)
        .where('anomalyId', isEqualTo: anomalyId)
        .snapshots()
        .map((snapshot) {
      final comments = snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
      // Sort by createdAt descending
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return comments;
    });
  }

  // Get all comments for an anomaly (non-stream)
  Future<List<Comment>> getComments(String anomalyId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('anomalyId', isEqualTo: anomalyId)
          .get();
      
      final comments = snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
      // Sort by createdAt descending
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return comments;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commentaires: $e');
    }
  }

  // Add a comment
  Future<void> addComment(Comment comment) async {
    try {
      await _firestore.collection(_collection).add(comment.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du commentaire: $e');
    }
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore.collection(_collection).doc(commentId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du commentaire: $e');
    }
  }

  // Update a comment
  Future<void> updateComment(String commentId, String newText) async {
    try {
      await _firestore.collection(_collection).doc(commentId).update({
        'text': newText,
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du commentaire: $e');
    }
  }
}

