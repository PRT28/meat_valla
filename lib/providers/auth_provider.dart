import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../supabase_options.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = SupabaseConfig.client;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;
  Map<String, dynamic>? _tempRegistrationData;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null && _supabase.auth.currentSession != null;

  AuthProvider() {
    _supabase.auth.onAuthStateChange.listen(_onAuthStateChanged);
    _loadInitialUser();
  }

  void _onAuthStateChanged(AuthState state) async {
    if (state.event == AuthChangeEvent.signedIn && state.session != null) {
      await _loadUserData(state.session!.user.id);
    } else if (state.event == AuthChangeEvent.signedOut) {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> _loadInitialUser() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUserData(session.user.id);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', uid)
          .single();

      _user = UserModel.fromMap({...response, 'id': uid});
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Send OTP to phone number for registration
  Future<bool> sendOtpForRegistration({
    required String phoneNumber,
    required String name,
    String? email,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Format phone number to international format if needed
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Assuming Indian numbers, adjust as needed
      }

      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
      );

      // Store registration data temporarily for use after OTP verification
      _tempRegistrationData = {
        'phoneNumber': formattedPhone,
        'name': name,
        'email': email,
      };

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
    return false;
  }

  // Send OTP to phone number for login
  Future<bool> sendOtpForLogin({required String phoneNumber}) async {
    try {
      _setLoading(true);
      _clearError();

      // Format phone number to international format if needed
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Assuming Indian numbers, adjust as needed
      }

      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
    return false;
  }

  // Verify OTP for both login and registration
  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otp,
    bool isRegistration = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Format phone number to international format if needed
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Assuming Indian numbers, adjust as needed
      }

      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.session != null) {
        if (isRegistration && _tempRegistrationData != null) {
          // Create user profile for new registration
          await _createUserProfile(response.session!.user.id);
        }

        await _loadUserData(response.session!.user.id);
        _tempRegistrationData = null; // Clear temp data
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
    return false;
  }

  Future<void> _createUserProfile(String userId) async {
    if (_tempRegistrationData == null) return;

    try {
      final userData = UserModel(
        id: userId,
        email: _tempRegistrationData!['email'] ?? '',
        name: _tempRegistrationData!['name'],
        phoneNumber: _tempRegistrationData!['phoneNumber'],
        createdAt: DateTime.now(),
      );

      await _supabase
          .from('users')
          .insert(userData.toMap());
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _user = null;
    _tempRegistrationData = null;
    notifyListeners();
  }

  // For password reset, we'll use phone-based OTP since we're using phone auth
  Future<bool> sendPasswordResetOtp({required String phoneNumber}) async {
    try {
      _setLoading(true);
      _clearError();

      // Format phone number to international format if needed
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Assuming Indian numbers, adjust as needed
      }

      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
      );

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
    String? email,
  }) async {
    if (_user == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedUser = _user!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
        email: email,
        updatedAt: DateTime.now(),
      );

      await _supabase
          .from('users')
          .update(updatedUser.toMap())
          .eq('id', _user!.id);

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

  // Check if user exists with phone number
  Future<bool> checkUserExists(String phoneNumber) async {
    try {
      // Format phone number to international format if needed
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Assuming Indian numbers, adjust as needed
      }

      final response = await _supabase
          .from('users')
          .select('id')
          .eq('phoneNumber', formattedPhone)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }
}