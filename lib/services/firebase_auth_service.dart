import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.inspecteur,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'role': role.value,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user data from Firestore by UID
  Future<AppUser?> getUserData(String uid) async {
    try {
      print('getUserData called for UID: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      print('Document exists: ${doc.exists}');
      if (doc.exists) {
        final data = doc.data();
        print('Document data: $data');
        if (data != null) {
          print('Role from Firestore: ${data['role']}');
          final appUser = AppUser.fromFirestore(doc);
          print('Parsed role: ${appUser.role.value}');
          return appUser;
        }
      }
      print('Document does not exist or has no data');
      return null;
    } catch (e, stackTrace) {
      print('Error in getUserData: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erreur lors de la récupération des données utilisateur: $e');
    }
  }

  // Get user data by email (fallback if document was created with wrong ID)
  Future<AppUser?> getUserDataByEmail(String email) async {
    try {
      print('getUserDataByEmail called for email: $email');
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        print('Found document with ID: ${doc.id}');
        final data = doc.data();
        print('Document data: $data');
        print('Role from Firestore: ${data['role']}');
        final appUser = AppUser.fromFirestore(doc);
        print('Parsed role: ${appUser.role.value}');
        return appUser;
      }
      print('No document found with email: $email');
      return null;
    } catch (e, stackTrace) {
      print('Error in getUserDataByEmail: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Migrate user document from old ID to correct UID
  Future<void> migrateUserDocument(String oldDocId, String correctUid, String email) async {
    try {
      print('Migrating user document from $oldDocId to $correctUid');
      
      // Get the old document
      final oldDoc = await _firestore.collection('users').doc(oldDocId).get();
      if (!oldDoc.exists) {
        print('Old document does not exist');
        return;
      }
      
      final oldData = oldDoc.data();
      if (oldData == null) {
        print('Old document has no data');
        return;
      }
      
      print('Old document data: $oldData');
      
      // Create document with correct UID
      await _firestore.collection('users').doc(correctUid).set(oldData);
      print('Document created with correct UID');
      
      // Delete old document
      await _firestore.collection('users').doc(oldDocId).delete();
      print('Old document deleted');
      
    } catch (e, stackTrace) {
      print('Error migrating user document: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erreur lors de la migration du document utilisateur: $e');
    }
  }

  // Update user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des données utilisateur: $e');
    }
  }

  // Create or update user document in Firestore (useful for users created directly in Firebase Auth)
  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String name,
    UserRole role = UserRole.inspecteur,
  }) async {
    try {
      print('createUserDocument called: uid=$uid, email=$email, name=$name, role=${role.value}');
      
      final userDoc = _firestore.collection('users').doc(uid);
      final docSnapshot = await userDoc.get();
      
      print('Document exists: ${docSnapshot.exists}');
      
      if (!docSnapshot.exists) {
        // Create new document
        final data = {
          'name': name,
          'email': email,
          'role': role.value,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        print('Creating document with data: $data');
        
        await userDoc.set(data);
        
        print('Document created successfully');
      } else {
        print('Document already exists, updating...');
        // Update existing document (merge)
        await userDoc.set({
          'name': name,
          'email': email,
          'role': role.value,
        }, SetOptions(merge: true));
        
        print('Document updated successfully');
      }
    } catch (e, stackTrace) {
      print('Error in createUserDocument: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erreur lors de la création du document utilisateur: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Format d\'email invalide.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      default:
        return 'Une erreur s\'est produite: ${e.message}';
    }
  }
}

