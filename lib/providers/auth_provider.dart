import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  
  User? _firebaseUser;
  AppUser? _appUser;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        print('Auth state changed, user UID: ${user.uid}, email: ${user.email}');
        _appUser = await _authService.getUserData(user.uid);
        print('AppUser loaded by UID: ${_appUser != null ? "Yes" : "No"}');
        
        // If not found by UID, try to find by email (in case document was created with wrong ID)
        if (_appUser == null && user.email != null) {
          print('Trying to find user document by email: ${user.email}');
          _appUser = await _authService.getUserDataByEmail(user.email!);
          print('AppUser loaded by email: ${_appUser != null ? "Yes" : "No"}');
          
          // If found by email but with wrong ID, migrate it
          if (_appUser != null && _appUser!.uid != user.uid) {
            print('Found document with wrong ID (${_appUser!.uid}), migrating to correct UID (${user.uid})');
            try {
              await _authService.migrateUserDocument(_appUser!.uid, user.uid, user.email!);
              // Reload with correct UID
              _appUser = await _authService.getUserData(user.uid);
              print('Migration successful, AppUser reloaded: ${_appUser != null ? "Yes" : "No"}');
            } catch (e) {
              print('Error during migration: $e');
              // Continue with the found user even if migration fails
            }
          }
        }
        
        if (_appUser != null) {
          print('AppUser role: ${_appUser!.role.value}');
        }
        
        // If user document doesn't exist in Firestore, create it
        // This handles users created directly in Firebase Auth console
        if (_appUser == null && user.email != null) {
          try {
            print('User document not found, creating it for UID: ${user.uid}');
            
            // Extract name from email (before @) or use displayName
            String name;
            if (user.displayName != null && user.displayName!.isNotEmpty) {
              name = user.displayName!;
            } else {
              // Generate name from email: "john.doe@example.com" -> "John Doe"
              final emailPart = user.email!.split('@')[0];
              name = emailPart
                  .replaceAll('.', ' ')
                  .split(' ')
                  .map((word) => word.isEmpty 
                      ? '' 
                      : word[0].toUpperCase() + word.substring(1))
                  .where((word) => word.isNotEmpty)
                  .join(' ');
              
              if (name.isEmpty) {
                name = 'Utilisateur';
              }
            }
            
            print('Creating user document with name: $name, email: ${user.email}');
            
            await _authService.createUserDocument(
              uid: user.uid,
              email: user.email!,
              name: name,
              role: UserRole.inspecteur, // Default role
            );
            
            print('User document created successfully');
            
            // Reload user data
            _appUser = await _authService.getUserData(user.uid);
            print('User data reloaded: ${_appUser != null ? "Success" : "Failed"}');
          } catch (e, stackTrace) {
            print('Error creating user document: $e');
            print('Stack trace: $stackTrace');
            // Continue without user document - user can still use the app
          }
        }
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.inspecteur,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _firebaseUser = null;
    _appUser = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

