import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:autotelematic_new_app/cubit/change_password_cubit.dart';
import 'package:autotelematic_new_app/cubit/geofencing_state.dart';
import 'package:autotelematic_new_app/cubit/get_alert_list_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_device_group_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_device_live_tracking_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_device_status_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_devices_list_cubit.dart';
import 'package:autotelematic_new_app/cubit/home_cubit.dart';
import 'package:autotelematic_new_app/cubit/reportstype_cubit.dart';
import 'package:autotelematic_new_app/repository/delete_alert_repository.dart';
import 'package:autotelematic_new_app/repository/get_alert_list_repository.dart';
import 'package:autotelematic_new_app/repository/get_device_group_repository.dart';
import 'package:autotelematic_new_app/repository/get_device_live_tracking_repository.dart';
import 'package:autotelematic_new_app/repository/get_device_status_repository.dart';
import 'package:autotelematic_new_app/repository/get_devices_list_repository.dart';
import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:autotelematic_new_app/utils/localnotification.dart';
import 'package:autotelematic_new_app/utils/routes/routes.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> backGroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final SharedPreferences sp = await SharedPreferences.getInstance();

  if (message.notification != null) {
    CommonUtils.toastMessage(message.notification!.title.toString());
    log('Notification status is ${sp.getBool('notifications') ?? true}');
    LocalNotificationServices.showNotifiationForground(message);
  }
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FirebaseOptions firebaseOptions;
    if (Platform.isAndroid) {
      firebaseOptions = const FirebaseOptions(
        apiKey: "AIzaSyCWuav43fwGc-QBiorhLhGOrX5uLFKtV_s",
        appId: "1:459424890335:android:9106643f6dc0d7b08a186a",
        messagingSenderId: "45942489033",
        projectId: "platform-autotel",
        storageBucket: "hpl-newserver.firebasestorage.app",
      );
    } else if (Platform.isIOS) {
      firebaseOptions = const FirebaseOptions(
        apiKey: "AIzaSyB8IfqySiS4N0l4CYkvO-OcG0oPj0i-VKs",
        appId: "1:459424890335:ios:82386f5f724b72f18a186a",
        messagingSenderId: "45942489033",
        projectId: "platform-autotel",
        storageBucket: "hpl-newserver.firebasestorage.app",
        iosBundleId: "com.7stars.ios",
      );
    } else {
      firebaseOptions = const FirebaseOptions(
        apiKey: '',
        appId: '',
        messagingSenderId: '',
        projectId: '',
      );
    }

    await Firebase.initializeApp(options: firebaseOptions);

    FirebaseMessaging.onBackgroundMessage(backGroundHandler);

    final settings = await FirebaseMessaging.instance.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('Notification permission granted');
    } else {
      log('Notification permission denied');
    }

    FirebaseMessaging.instance.getToken().then((token) {
      log('FCM token at startup: $token');
    }).catchError((e) {
      log('Error getting FCM token at startup: $e');
    });

    runApp(const MyApp());
  }, (error, stackTrace) {
    log("Uncaught error: $error");
  });
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ReportstypeCubit>(
          create: (context) => ReportstypeCubit(),
        ),
        BlocProvider<GeofencingCubit>(
          create: (context) => GeofencingCubit(),
        ),
        BlocProvider<HomeCubit>(
          create: (context) => HomeCubit(HomeInitial()),
        ),
        BlocProvider<ChangePasswordCubit>(
          create: (context) => ChangePasswordCubit(),
        ),
        BlocProvider<GetDeviceStatusCubit>(
          create: (context) =>
              GetDeviceStatusCubit(GetDeviceStatusRepository(), context),
        ),
        BlocProvider<GetDevicesListCubit>(
          create: (context) =>
              GetDevicesListCubit(GetDevicesListRepository(), context),
        ),
        BlocProvider<GetDeviceGroupCubit>(
          create: (context) =>
              GetDeviceGroupCubit(getRepository: GetDeviceGroupRepository()),
        ),
        BlocProvider<GetDeviceLiveTrackingCubit>(
          create: (context) => GetDeviceLiveTrackingCubit(
              repository: GetDeviceLiveTrackingRepository()),
        ),
        BlocProvider<GetAlertsListCubit>(
          create: (context) => GetAlertsListCubit(
            getRepository: GetAlertListRepository(),
            deleteRepository: DeleteAlertRepository(),
          ),
        ),
      ],
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: '7 Stars Tracking',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 0, 103, 206),
                brightness: Brightness.light,
              ),
              primarySwatch: Colors.red,
            ),
            initialRoute: RoutesName.splashSceen,
            onGenerateRoute: Routes.generateRoute,
          );
        },
      ),
    );
  }
}
