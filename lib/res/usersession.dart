import 'package:autotelematic_new_app/cubit/get_devices_list_cubit.dart';
import 'package:autotelematic_new_app/model/user_signin_model.dart';
import 'package:autotelematic_new_app/res/push_notification_service.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter_device_info_plus/flutter_device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isRunningOnSimulator() async {
  const deviceInfo = FlutterDeviceInfoPlus();
  try {
    final info = await deviceInfo.getDeviceInfo();
    final os = info.operatingSystem.toLowerCase();
    final model = info.model.toLowerCase();
    final brand = info.brand.toLowerCase();
    final manufacturer = info.manufacturer.toLowerCase();

    if (os == 'ios') {
      return model.contains('simulator') || info.deviceName.toLowerCase().contains('simulator');
    } else if (os == 'android') {
      return brand.contains('google') && (model.contains('sdk') || model.contains('emulator')) ||
          manufacturer.contains('genymotion') ||
          model.contains('google_sdk');
    }
  } catch (e) {
    print("Error checking simulator: $e");
  }
  return false;
}

class UserSessions {
  Future<void> saveUserSession(
      UserLoginData userLogindata, String userID) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('status', userLogindata.status.toString());
    await sp.setString('userid', userID);
    await sp.setBool('notifications', true);
    await sp.setString('userApiHash', userLogindata.userApiHash.toString());
  }

  Future<void> checkUserSession(BuildContext context) async {
    try {
      print('Checking user session...');
      if (await isRunningOnSimulator()) {
        print('Running on simulator/emulator: skipping FCM token logic.');
        _navigateToHome(context);
        return;
      }
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String? userAPIHashKey = sp.getString('userApiHash');

      if (userAPIHashKey == null || userAPIHashKey.isEmpty) {
        print('No user API hash, going to login');
        _navigateToLogin(context);
        return;
      }

      // Centralized FCM submission!
      // We don't want FCM failures to log the user out, so we wrap it in a try-catch.
      try {
        await PushNotificationService().submitFcmTokenIfLoggedIn();
      } catch (e) {
        print("PushNotificationService Error: $e");
      }

      if (!context.mounted) return;

      await context.read<GetDevicesListCubit>().fetchDevicesList(
            isRefresh: true,
            context: context,
          );

      print('Navigating to home');
      _navigateToHome(context);
    } catch (e, st) {
      print("❌ Error in checkUserSession: $e\n$st");
      if (!context.mounted) return;
      _navigateToLogin(context); // fallback if anything fails
    }
  }

  static Future<void> removeSession() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await FirebaseMessaging.instance.deleteToken();
    await sp.remove('userApiHash');
    await sp.clear();
    PushNotificationService().reset();
  }

  static Future<String?> getUserApiHash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userApiHash');
  }

  // Private methods for navigation
  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, RoutesName.login);
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, RoutesName.home);
  }
}
