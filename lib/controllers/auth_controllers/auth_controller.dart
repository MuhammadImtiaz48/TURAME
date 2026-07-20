// ============================================================
// FILE: lib/controllers/auth_controller.dart
// ============================================================

import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../models/user_model.dart';
import '../provider_controller/provider_controller.dart';
import '../../routes/app_routes.dart';
import '../../constants/app_colors.dart';
import '../../services/firebase_service.dart';
import '../../services/zego_service.dart';
import '../../services/user_storage_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _auth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser == null) {
        user.value = null;
      } else {
        _loadUserData();
        if (Get.isRegistered<ProviderController>()) {
          Get.find<ProviderController>().refresh();
        }
      }
    });

    // Keep the stored FCM token fresh when it rotates.
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      if (user.value != null) {
        FirebaseService.updateFcmToken(user.value!.id, token);
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadUserData() async {
    final storedUser = await UserStorageService.loadUser();
    if (storedUser != null) {
      user.value = storedUser;
      try {
        final zego = Get.find<ZegoService>();
        await zego.init(userID: storedUser.id, userName: storedUser.name);
      } catch (e) {
        print('Zego init error: $e');
      }
    } else if (_auth.currentUser != null) {
      final userData = await FirebaseService.getUserData(_auth.currentUser!.uid);
      if (userData != null) {
        user.value = userData;
        await UserStorageService.saveUser(userData);
        try {
          final zego = Get.find<ZegoService>();
          await zego.init(userID: userData.id, userName: userData.name);
        } catch (e) {
          print('Zego init error: $e');
        }
      }
    }
  }

  // Subscribe the signed-in user to topics used for broadcast notifications.
  Future<void> _subscribeToTopics() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('all_users');
    } catch (_) {
      // Topic subscription is best-effort.
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        final userData = await FirebaseService.getUserData(credential.user!.uid);
        user.value = userData ?? UserModel(
          id: credential.user!.uid,
          name: credential.user!.displayName ?? '',
          email: credential.user!.email ?? email,
          phone: credential.user!.phoneNumber ?? '',
          role: UserRole.patient,
        );
        await UserStorageService.saveUser(user.value!);
        await FirebaseService.saveFcmTokenForUser(user.value!.id);
        await _subscribeToTopics();
        try {
          final zego = Get.find<ZegoService>();
          await zego.init(userID: user.value!.id, userName: user.value!.name);
        } catch (e) {
          print('Zego init error: $e');
        }
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleAuthError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print("SIGNUP_DEBUG: Starting Firebase Auth createUserWithEmailAndPassword...");
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      print("SIGNUP_DEBUG: Firebase Auth user created. UID: ${credential.user?.uid}");

      if (credential.user != null) {
        print("SIGNUP_DEBUG: Updating display name to '$name'...");
        await credential.user!.updateDisplayName(name).catchError((err) {
          print("SIGNUP_DEBUG: Display name update failed, continuing: $err");
        });
        print("SIGNUP_DEBUG: Display name updated.");
        
        final fcmToken = await FirebaseService.getFcmToken();
        final newUser = UserModel(
          id: credential.user!.uid,
          name: name,
          email: email.trim(),
          phone: phone,
          role: role,
          fcmToken: fcmToken,
          createdAt: DateTime.now(),
        );
        
        print("SIGNUP_DEBUG: Storing user info in Cloud Firestore...");
        try {
          await FirebaseService.createUser(newUser).timeout(const Duration(seconds: 4));
          print("SIGNUP_DEBUG: Storing in Cloud Firestore completed.");
        } catch (dbError) {
          print("SIGNUP_DEBUG: Cloud Firestore store failed or timed out, skipping: $dbError");
        }
        
        user.value = newUser;
        print("SIGNUP_DEBUG: Saving user to local storage...");
        await UserStorageService.saveUser(user.value!);
        print("SIGNUP_DEBUG: Local storage save completed.");
        await _subscribeToTopics();
        try {
          final zego = Get.find<ZegoService>();
          await zego.init(userID: newUser.id, userName: newUser.name);
        } catch (e) {
          print('Zego init error: $e');
        }
        return true;
      }
      print("SIGNUP_DEBUG: Credential user was null.");
      return false;
    } on FirebaseAuthException catch (e) {
      print("SIGNUP_DEBUG: FirebaseAuthException caught: ${e.code} - ${e.message}");
      errorMessage.value = _handleAuthError(e);
      return false;
    } catch (e) {
      print("SIGNUP_DEBUG: General exception caught: $e");
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyPhone({required String phone, required String otp}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final storedPhone = await UserStorageService.loadPhone();
      if (storedPhone != null) {
        await FirebaseService.verifyOtp(storedPhone, otp);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp({required String phone}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await UserStorageService.savePhone(phone);
      await FirebaseService.sendOtp(phone);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendPasswordReset({required String email}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://ramma-d8d30.firebaseapp.com',
        handleCodeInApp: true,
        androidPackageName: 'com.example.rammaa',
        androidInstallApp: true,
      );
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
        actionCodeSettings: actionCodeSettings,
      );
      Get.snackbar(
        'Success',
        'Password reset email sent. Check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.textOnDark,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _handleAuthError(e);
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: AppColors.textOnDark,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserRole(UserRole role) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      if (user.value != null) {
        final updated = user.value!.copyWith(role: role);
        print("SIGNUP_DEBUG: Updating user role in Cloud Firestore...");
        try {
          await FirebaseService.updateUser(updated).timeout(const Duration(seconds: 4));
          print("SIGNUP_DEBUG: Cloud Firestore role update completed.");
        } catch (dbError) {
          print("SIGNUP_DEBUG: Cloud Firestore role update failed or timed out, skipping: $dbError");
        }
        user.value = updated;
        await UserStorageService.saveUser(updated);
        await FirebaseService.saveFcmTokenForUser(updated.id);
        print("SIGNUP_DEBUG: Local user role storage completed.");
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUserData() async {
    if (_auth.currentUser != null) {
      final userData = await FirebaseService.getUserData(_auth.currentUser!.uid);
      if (userData != null) {
        user.value = userData;
        await UserStorageService.saveUser(userData);
        try {
          final zego = Get.find<ZegoService>();
          await zego.updateUser(userData.id, userData.name);
        } catch (e) {
          print('Zego update error: $e');
        }
      }
    }
  }

  Future<void> signOut() async {
    try {
      final zego = Get.find<ZegoService>();
      await zego.logout();
    } catch (e) {
      print('Zego logout error: $e');
    }
    await _auth.signOut();
    user.value = null;
    await UserStorageService.clear();
    Get.offAllNamed(AppRoutes.welcome);
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email format';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  bool get isLoggedIn => user.value != null;
}
