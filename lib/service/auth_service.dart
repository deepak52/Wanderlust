import 'dart:developer' as developer;

import '../helper/app_message.dart';
import '../helper/app_string.dart';
import '../helper/core/base/app_base_service.dart';
import '../helper/enum.dart';
import '../helper/firebase_messaging_service.dart';
import '../model/login_model.dart';
import '../model/change_password_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends AppBaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseMessagingService get _firebaseMessagingService =>
      Get.find<FirebaseMessagingService>();

  // Login with email and password (using userCode as email)
  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('User not found.');
      }

      developer.log('=== AUTH LOGIN DEBUG ===');
      developer.log('Firebase UID: ${user.uid}');
      developer.log('Email: ${user.email}');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      developer.log('User doc exists: ${userDoc.exists}');
      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};
        developer.log('User doc data: $userData');
        developer.log('All fields: ${userData.keys.toList()}');
        developer.log('isAdmin field value: ${userData['isAdmin']}');
        developer.log('IsAdmin field value: ${userData['IsAdmin']}');
        developer.log('role field value: ${userData['role']}');
        developer.log('Role field value: ${userData['Role']}');
        developer.log('userType field value: ${userData['userType']}');
        developer.log('admin field value: ${userData['admin']}');
      }

      if (!userDoc.exists) {
        throw Exception('User not found in database.');
      }

      final userData = userDoc.data() ?? {};

      // Check for admin field with multiple possible names (case-insensitive)
      bool isAdmin = false;
      final possibleAdminFields = [
        'isAdmin',
        'IsAdmin',
        'isadmin',
        'ISADMIN',
        'admin',
        'Admin',
        'role',
        'Role',
        'userType',
        'UserType',
        'user_role',
        'userRole',
      ];
      for (final field in possibleAdminFields) {
        final value = userData[field];
        developer.log(
          'Checking field "$field": $value (type: ${value.runtimeType})',
        );
        if (value == true ||
            value == 'true' ||
            value == 'admin' ||
            value == 'ADMIN') {
          isAdmin = true;
          developer.log('Found admin=true via field: $field');
          break;
        }
      }

      developer.log('Computed isAdmin: $isAdmin');

      // Save user credentials and FCM token
      final idToken = await user.getIdToken() ?? '';
      await _saveUserCredentials(
        idToken,
        user.uid,
        user.email ?? email,
        isAdmin,
        true,
      );
      await _saveFcmToken(user.uid);

      return isAdmin;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase auth exceptions
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          throw Exception('Invalid email or password');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'user-disabled':
          throw Exception('User account has been disabled');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register new user
  Future<LoginResponse?> register(LoginRequest request) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: request.userCode ?? '',
        password: request.password ?? '',
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Save token and user data
      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get ID token');
      }
      await _saveUserCredentials(
        idToken,
        user.uid,
        user.email ?? '',
        false,
        false, // rememberMe not in LoginRequest, default to false
      );

      // Save FCM token if available
      await _saveFcmToken(user.uid);

      return LoginResponse(
        data: 'Registration successful', // Basic success message
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase auth exceptions
      switch (e.code) {
        case 'weak-password':
          throw Exception('Password provided is too weak');
        case 'email-already-in-use':
          throw Exception('An account already exists for that email');
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Login with LoginRequest (for compatibility with existing LoginController)
  Future<bool> loginWithRequest(LoginRequest request) async {
    return await login(request.userCode ?? '', request.password ?? '');
  }

  // Logout user
  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      // Clear preferences
      _clearUserCredentials();
      return true;
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Get current user from Firebase
  Future<LoginResponse?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data() ?? {};
      final isAdmin = userData['isAdmin'] ?? false;
      final email = userData['email'] ?? user.email ?? '';

      return LoginResponse(
        data: 'User retrieved successfully', // Basic success message
      );
    } catch (e) {
      // Return null if any error occurs (user not authenticated, etc.)
      return null;
    }
  }

  // Check authentication state
  Future<bool> isAuthenticated() async {
    try {
      final user = _firebaseAuth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Get user role (admin or regular user)
  Future<bool> isAdmin() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return false;

      final userData = userDoc.data() ?? {};

      // Check for admin field with multiple possible names (case-insensitive)
      final possibleAdminFields = [
        'isAdmin',
        'IsAdmin',
        'isadmin',
        'ISADMIN',
        'admin',
        'Admin',
        'role',
        'Role',
        'userType',
        'UserType',
        'user_role',
        'userRole',
      ];
      for (final field in possibleAdminFields) {
        final value = userData[field];
        if (value == true ||
            value == 'true' ||
            value == 'admin' ||
            value == 'ADMIN') {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Remember me - check if we should auto-login
  Future<bool> shouldRememberMe() async {
    try {
      final rememberMe =
          myApplication.preferenceHelper!.getBool(rememberMeKey) ?? false;
      final hasToken =
          myApplication.preferenceHelper!.getString(accessTokenKey) != null;
      final hasUserId =
          myApplication.preferenceHelper!.getString(userIdKey) != null;

      return rememberMe && hasToken && hasUserId;
    } catch (e) {
      return false;
    }
  }

  // Auto-login with remember me
  Future<LoginResponse?> autoLogin() async {
    try {
      final shouldRemember = await shouldRememberMe();
      if (!shouldRemember) return null;

      final userId = myApplication.preferenceHelper!.getString(userIdKey);
      final email = myApplication.preferenceHelper!.getString(emailKey);
      final isAdmin =
          myApplication.preferenceHelper!.getBool(isAdminKey) ?? false;

      if (email == null) return null;

      // Verify token is still valid by getting current user
      final currentUser = await getCurrentUser();
      if (currentUser != null && currentUser.data?.isNotEmpty == true) {
        return currentUser;
      }

      // Token might be expired, clear and return null
      await logout();
      return null;
    } catch (e) {
      await logout();
      return null;
    }
  }

  // User login with UserLoginRequest (for compatibility with existing LoginController)
  Future<UserLoginResponse?> userLogin(UserLoginRequest request) async {
    try {
      // For compatibility, we'll delegate to login with email/password
      // In a real implementation, this might use a different auth method
      final loginRequest = LoginRequest(
        userCode: request.userCode, // Assuming userCode is email/username
        password: request.password,
      );

      final loginSuccess = await loginWithRequest(loginRequest);
      if (!loginSuccess) return null; // If login failed

      // Get fresh user data to build UserLoginResponse
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      final isAdminUser = userData['isAdmin'] ?? false;

      return UserLoginResponse(
        userId: int.tryParse(user.uid.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        userCode: user.email ?? '',
        userName: userData['userName'] ?? user.email?.split('@')[0] ?? 'User',
        defaultCompCode: userData['defaultCompCode'] ?? 'DEFAULT_COMP',
        defaultBranchCode: userData['defaultBranchCode'] ?? 'DEFAULT_BRANCH',
        defaultLocationId: userData['defaultLocationId'] ?? 0,
        designation: userData['designation'] ?? 'USER',
      );
    } catch (e) {
      return null;
    }
  }

  // Get mail/email (for compatibility with existing LoginController)
  Future<EmailResponse?> getMail(List<dynamic> requestList) async {
    try {
      // Extract userCode from request list
      String? userCode;
      for (var request in requestList) {
        if (request is Map &&
            request['attribute'] == 'userCode' &&
            request['value'] != null) {
          userCode = request['value'].toString();
          break;
        }
      }

      if (userCode == null) return null;

      // In a real implementation, this would fetch email from a user service/database
      // For now, return a placeholder response
      return EmailResponse(
        message: 'Email retrieved successfully',
        emailId: '$userCode@example.com', // Placeholder email
      );
    } catch (e) {
      return null;
    }
  }

  // Get OTP (for compatibility with existing LoginController)
  Future<OtpResponse?> getOtp(List<dynamic> requestList) async {
    try {
      // In a real implementation, this would generate/send an OTP
      // For now, return a placeholder response
      return OtpResponse(
        verificationCode: '123456', // Placeholder OTP
      );
    } catch (e) {
      return null;
    }
  }

  // Verify OTP (for compatibility with existing LoginController)
  Future<bool> verifyOtp(List<dynamic> requestList) async {
    try {
      // Extract OTP from request list
      String? otpCode;
      for (var request in requestList) {
        if (request is Map &&
            request['attribute'] == 'verificationCode' &&
            request['value'] != null) {
          otpCode = request['value'].toString();
          break;
        }
      }

      if (otpCode == null) return false;

      // In a real implementation, this would verify the OTP against stored value
      // For now, return true for any 6-digit code (placeholder logic)
      return otpCode.length == 6 && int.tryParse(otpCode) != null;
    } catch (e) {
      return false;
    }
  }

  // Private helper to get or create user document and return its data
  Future<Map<String, dynamic>> _getOrCreateUserDocument(
    String userId,
    String email,
  ) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      // Create user document if it doesn't exist
      await _firestore.collection('users').doc(userId).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return {'email': email, 'isAdmin': false};
    } else {
      // Update last login and return existing data
      await _firestore.collection('users').doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return userDoc.data() ?? {};
    }
  }

  // Private helper to save user credentials to preferences
  Future<void> _saveUserCredentials(
    String accessToken,
    String userId,
    String email,
    bool isAdmin,
    bool rememberMe,
  ) async {
    myApplication.preferenceHelper!.setString(accessTokenKey, accessToken);
    myApplication.preferenceHelper!.setString(userIdKey, userId);
    myApplication.preferenceHelper!.setString(emailKey, email);
    myApplication.preferenceHelper!.setBool(isAdminKey, isAdmin);
    myApplication.preferenceHelper!.setBool(rememberMeKey, rememberMe);
  }

  // Private helper to clear user credentials from preferences
  void _clearUserCredentials() {
    myApplication.preferenceHelper!.remove(accessTokenKey);
    myApplication.preferenceHelper!.remove(rememberMeKey);
    myApplication.preferenceHelper!.remove(userIdKey);
    myApplication.preferenceHelper!.remove(emailKey);
    myApplication.preferenceHelper!.remove(isAdminKey);
  }

  // Private helper to save FCM token to Firestore
  Future<void> _saveFcmToken(String userId) async {
    try {
      final fcmToken = await _firebaseMessagingService.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': fcmToken,
        });
      }
    } catch (e) {
      // Don't fail login if FCM token saving fails
      developer.log('Failed to save FCM token: $e');
    }
  }

  // Change password via backend API
  Future<bool> changePassword(ChangePasswordRequest request) async {
    try {
      final token = myApplication.preferenceHelper!.getString(accessTokenKey);
      if (token.isEmpty) {
        throw Exception('No access token available');
      }

      final response = await httpService.postService<bool>(
        endpoint: getChangePasswordApiEndpoint(token: token),
        headers: await getHeaders(),
        data: request.toJson(),
        fromJsonT: (json) => json as bool,
        ignoreError: false,
      );

      if (response != null && response.data != null) {
        return response.data!;
      }
      return false;
    } catch (e) {
      appLog('Change password failed: $e', logging: Logging.error);
      rethrow;
    }
  }

  // Save FCM token to Firestore (public method for LoginController compatibility)
  Future<void> saveFcmToken(String userId) async {
    await _saveFcmToken(userId);
  }
}
