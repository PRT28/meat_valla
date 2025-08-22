import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meat_delivery/models/cred_model.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      await _loadUserData(firebaseUser.uid);
    } else {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      print(uid);
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap({...doc.data()!, 'id': uid});
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userData = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
        );

        final credData = CredModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          password: password,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('credentials')
            .doc(credential.user!.uid)
            .set(credData.toMap());

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData.toMap());

        _user = userData;
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
    return false;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
    return false;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      _clearError();

      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
    return false;
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImage,
  }) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedUser = _user!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_user!.id)
          .update(updatedUser.toMap());

      _user = updatedUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
    return false;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}