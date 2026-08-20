import 'package:autotelematic_new_app/cubit/home_cubit.dart';
import 'package:autotelematic_new_app/cubit/setting_cubit.dart'; // Add this import
import 'package:autotelematic_new_app/utils/app_constants.dart';
import 'package:autotelematic_new_app/utils/localnotification.dart';
import 'package:autotelematic_new_app/view/dashboard.dart';
import 'package:autotelematic_new_app/view/events.dart';
import 'package:autotelematic_new_app/view/map_for_all_vehicles.dart';
import 'package:autotelematic_new_app/view/settings.dart';
import 'package:autotelematic_new_app/view/vehicle_list_dashboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomeScreen extends StatefulWidget {
  final int? initialIndex; // Add parameter for initial index
  const HomeScreen({super.key, this.initialIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _screens = const [
    VehicleListDashBoardScreen(),
    MapForAllVehiclesScreen(),
    DashBoardScreen(),
    VehicleEventsScreen(),
    AppSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
    // Set initial index in HomeCubit if provided
    if (widget.initialIndex != null) {
      context.read<HomeCubit>().setHomeIndex(widget.initialIndex!);
    }
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.instance.getInitialMessage().then(_handleMessage);
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((_) {});
  }

  Future<void> _handleMessage(RemoteMessage? event) async {
    if (event?.notification == null) return;
    LocalNotificationServices.showNotifiationForground(event!);
  }

  Future<bool> _onWillPop() async => (await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text('Do you want to exit the App'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Yes'),
        ),
      ],
    ),
  )) ??
      false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: BlocProvider<SettingCubit>(
            create: (context) => SettingCubit(), // Provide SettingCubit
            child: BlocConsumer<HomeCubit, HomeState>(
              listener: (context, state) {
                if (state is HomeLoadingComplete) {
                  context.read<HomeCubit>();
                }
              },
              builder: (context, state) {
                final homeCubit = context.read<HomeCubit>();
                return SafeArea(
                  top: false,
                  child: Scaffold(
                    extendBody: true,
                    body: _screens[homeCubit.homeCurrentIndex],
                    floatingActionButton: SizedBox(
                      height: 14.h,
                      width: 14.w,
                      child: FloatingActionButton(
                        shape: const CircleBorder(),
                        onPressed: () {
                          if (homeCubit.homeCurrentIndex != 2) {
                            homeCubit.setHomeIndex(2);
                          }
                        },
                        backgroundColor: homeCubit.homeCurrentIndex != 2
                            ? Colors.grey
                            : AppColors.primaryColor,
                        child: const Icon(Icons.dashboard, color: Colors.white),
                      ),
                    ),
                    floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                    bottomNavigationBar: BottomNavigationBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      currentIndex: homeCubit.homeCurrentIndex,
                      onTap: homeCubit.setHomeIndex,
                      type: BottomNavigationBarType.fixed,
                      items: [
                        BottomNavigationBarItem(
                          icon: const Icon(
                            Icons.map_outlined,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black54)
                            ],
                          ),
                          label: 'Status',
                          activeIcon:  Icon(
                            Icons.map,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black54)
                            ],
                            color:AppColors.primaryColor,
                          ),
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(
                            Icons.location_on_outlined,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black54)
                            ],
                          ),
                          label: 'Map',
                          activeIcon:  Icon(
                            Icons.location_on,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black54)
                            ],
                            color:AppColors.primaryColor,
                          ),
                        ),
                        const BottomNavigationBarItem(
                          icon: SizedBox.shrink(),
                          label: '',
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black54)
                            ],
                          ),
                          label: 'Alerts',
                          activeIcon:  Icon(
                            Icons.notifications,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black54)
                            ],
                            color: AppColors.primaryColor,
                          ),
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(
                            Icons.settings_outlined,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black54)
                            ],
                          ),
                          label: 'Settings',
                          activeIcon:  Icon(
                            Icons.settings,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black54)
                            ],
                            color:AppColors.primaryColor,
                          ),
                        ),
                      ],
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      selectedItemColor: AppColors.primaryColor,
                      unselectedItemColor: Colors.grey,
                      selectedLabelStyle: const TextStyle(fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontSize: 12),
                      iconSize: 7.w,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}