import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../repository/fcmtoken_repository.dart';
import 'usersession.dart'; // adjust the import path as needed

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _isTokenSubmitted = false;
  Future<String?> _getFcmTokenWithRetry() async {
    for (int i = 0; i < 5; i++) {
      try {
        String? token = await _fcm.getToken();
        debugPrint('[PushNotificationService] Try $i: token=$token');
        if (token != null && token.isNotEmpty) return token;
      } catch (e) {
        debugPrint('[PushNotificationService] Error getting FCM token on try $i: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }

  /// Call this after login, and on splash if user is logged in.
  Future<void> submitFcmTokenIfLoggedIn() async {
    debugPrint('[PushNotificationService] Called submitFcmTokenIfLoggedIn');

    if (_isTokenSubmitted) {
      debugPrint(
          '[PushNotificationService] Token already submitted, skipping...');
      return;
    }

    String? userApiHash = await UserSessions.getUserApiHash();
    debugPrint('[PushNotificationService] userApiHash: $userApiHash');

    if (userApiHash == null) {
      debugPrint('[PushNotificationService] No userApiHash, not logged in.');
      return;
    }

    String? fcmToken = await _getFcmTokenWithRetry();
    debugPrint('[PushNotificationService] fcmToken: $fcmToken');

    if (fcmToken != null && fcmToken.isNotEmpty) {
      await FcmTokenRepository().fcmTokenSubmmissionApi(userApiHash, fcmToken);
      debugPrint('[PushNotificationService] ✅ FCM token submitted: $fcmToken');
      _isTokenSubmitted = true;
    } else {
      debugPrint(
          '[PushNotificationService] ❌ Could not obtain FCM token after retries');
    }
  }

  void reset() {
    _isTokenSubmitted = false;
  }
}
