import 'package:autotelematic_new_app/cubit/get_device_status_cubit.dart';
import 'package:autotelematic_new_app/cubit/get_device_status_state.dart';
import 'package:autotelematic_new_app/cubit/home_cubit.dart';
import 'package:autotelematic_new_app/model/get_device_status_model.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {

  String _language = 'URDU';
  final List<Color> sfgPaletteColor = [
    Colors.green,
    Colors.red,
    Colors.yellow,
    Colors.blue,
    Colors.grey,
    const Color.fromARGB(255, 138, 13, 4),
  ];

  @override
  void initState() {
    super.initState();

    // Always fetch fresh data on screen open
    context.read<GetDeviceStatusCubit>().fetchDeviceStatus(isRefresh: true,context: context);
    context.read<GetDeviceStatusCubit>().startPeriodicUpdates(context: context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop(context) async =>
      await showDialog(
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
      ) ??
          false;

  @override
  Widget build(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return WillPopScope(
          onWillPop: () => _onWillPop(context),
          child: SafeArea(
            child: Scaffold(
              body: BlocListener<HomeCubit, HomeState>(
                listener: (context, homeState) {
                  if (homeState is HomeNavigateToDeviceTracking) {
                    Navigator.pushNamed(context, RoutesName.vehicleLiveTracking,
                        arguments: {
                          'groupID': homeState.groupID,
                          'deviceID': homeState.deviceID
                        });
                  }
                },
                child: BlocBuilder<GetDeviceStatusCubit, GetDeviceStatusState>(
                  builder: (context, state) {
                    // Check if there's valid data
                    final bool hasValidData = state.model != null &&
                        (state.model!.totalCount > 0 || state.model!.items.isNotEmpty);

                    // Create ChartData if model is available
                    List<ChartData>? chartData;
                    if (state.model != null) {
                      chartData = [
                        ChartData('Running', state.model!.online.toDouble(), Colors.green),
                        ChartData('Stopped', state.model!.ack.toDouble(), Colors.red),
                        ChartData('Offline', state.model!.offline.toDouble(), Colors.blue),
                        ChartData('Idle', state.model!.idle.toDouble(), const Color(0xffFBB117)),
                      ];
                    }

                    // Show error if present
                    if (state is GetDeviceStatusError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${state.errorMessage}',
                                style: TextStyle(fontSize: 16.sp)),
                            SizedBox(height: 2.h),
                            ElevatedButton(
                              onPressed: () => context.read<GetDeviceStatusCubit>().fetchDeviceStatus(context: context),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show data UI if valid data is available
                    if (hasValidData && chartData != null) {
                      return RefreshIndicator(
                        onRefresh: () => context.read<GetDeviceStatusCubit>().fetchDeviceStatus(isRefresh: true,context: context),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(height: 2.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: _buildVehicleStatusCard(
                                    context, state.model!, chartData),
                              ),
                              SizedBox(height: 1.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: _buildNavigationCards(context, homeCubit),
                              ),
                              SizedBox(height: 0.7.h),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: _buildWarningCard(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Show loading only if showLoading is true and no valid data
                    if (state.isLoading && state.showLoading && !hasValidData) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppTheme.loadingImage,
                            SizedBox(height: 0.5.h),
                            Text('Loading...', style: TextStyle(fontSize: 16.sp)),
                          ],
                        ),
                      );
                    }

                    // Default: show empty state
                    // Professional empty state
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp)),
                          child: Container(
                            padding: EdgeInsets.all(5.w),
                            width: 80.w,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 30.sp,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No Data Available',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'It looks like there’s no device data to display at the moment. Please try again.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                ElevatedButton(
                                  onPressed: () => context.read<GetDeviceStatusCubit>().fetchDeviceStatus(context: context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.sp),
                                    ),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleStatusCard(
      BuildContext context, GetDeviceStatusModel deviceStatus, List<ChartData> vehicleStatusCountdata) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(1.sp, 1.sp),
            spreadRadius: 0,
            blurRadius: 3.sp,
          ),
        ],
      ),
      width: 100.w,
      height: 40.h,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final gaugeSize = constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight;
              return Center(
                child: SizedBox(
                  width: gaugeSize * 0.8,
                  height: gaugeSize * 0.8,
                  child: AnimatedGauge(
                    vehicleStatusCountdata: vehicleStatusCountdata,
                    totalDevices: deviceStatus.totalCount,
                    gaugeSize: gaugeSize,
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 2.w,
            top: 2.h,
            child: Text(
              "Running: ${vehicleStatusCountdata.firstWhere((data) => data.x == 'Running', orElse: () => ChartData('Running', 0, Colors.green)).y.toInt()}",
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp),
            ),
          ),
          Positioned(
            right: 2.w,
            top: 2.h,
            child: Text(
              "Stopped: ${vehicleStatusCountdata.firstWhere((data) => data.x == 'Stopped', orElse: () => ChartData('Stopped', 0, Colors.red)).y.toInt()}",
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp),
            ),
          ),
          Positioned(
            bottom: 2.h,
            left: 2.w,
            child: Text(
              "Offline: ${vehicleStatusCountdata.firstWhere((data) => data.x == 'Offline', orElse: () => ChartData('Offline', 0, Colors.blue)).y.toInt()}",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp),
            ),
          ),
          Positioned(
            bottom: 2.h,
            right: 2.w,
            child: Text(
              "Idle: ${vehicleStatusCountdata.firstWhere((data) => data.x == 'Idle', orElse: () => ChartData('Idle', 0, const Color(0xffFBB117))).y.toInt()}",
              style: TextStyle(
                  color: const Color(0xffFBB117),
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Totals",
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                Text(
                  deviceStatus.totalCount.toString(),
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCards(BuildContext context, HomeCubit homeCubit) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCard(
              context: context,
              title: 'Reports',
              image: 'assets/images/ComboChart_48px.png',
              height: 10.h,
              width: 20.w,
              onTap: () =>
                  Navigator.pushNamed(context, RoutesName.deviceListForReports),
            ),
            SizedBox(width: 1.75.w),
            _buildCard(
              context: context,
              title: 'History',
              image: 'assets/images/TimeMachine_50px.png',
              height: 7.5.h,
              width: 15.w,
              onTap: () =>
                  Navigator.pushNamed(context, RoutesName.deviceListForHistory),
            ),
          ],
        ),
        SizedBox(height: 0.7.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCard(
              context: context,
              title: 'Map',
              image: 'assets/images/TrackOrder_48px.png',
              height: 7.5.h,
              width: 19.5.w,
              onTap: () => homeCubit.setHomeIndex(1),
            ),
            SizedBox(width: 1.75.w),
            _buildCard(
              context: context,
              title: 'Alerts',
              image: 'assets/images/notification-96.png',
              height: 6.875.h,
              width: 13.75.w,
              onTap: () => homeCubit.setHomeIndex(3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String image,
    required double height,
    required double width,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 18.75.h,
        child: InkWell(
          onTap: onTap,
          child: Card(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16.sp)),
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Image.asset(image, height: height, width: width),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildWarningCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 2.5.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 12.5.w),
                const Expanded(child: SizedBox()),
                Text(
                  _language == 'ENGLISH' ? 'Warning!' : '!انتباہ',
                  style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                      letterSpacing: 0.5),
                ),
                const Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () => setState(() =>
                  _language = _language == 'ENGLISH' ? 'URDU' : 'ENGLISH'),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: _language == 'ENGLISH' ? 'URDU' : 'ENGLISH',
                        fillColor: const WidgetStatePropertyAll(Colors.green),
                        groupValue: _language,
                        onChanged: (value) =>
                            setState(() => _language = value!),
                        activeColor: _language == 'ENGLISH'
                            ? Colors.blueGrey[700]
                            : const Color(0xffFBB117),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(
                            horizontal: VisualDensity.minimumDensity,
                            vertical: VisualDensity.minimumDensity),
                      ),
                      Text(
                        _language == 'ENGLISH' ? 'URDU' : 'ENGLISH',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: _language == 'ENGLISH'
                              ? Colors.grey[900]
                              : Colors.blueGrey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.3.h),
            Divider(
                color: Colors.grey[300],
                thickness: 1,
                indent: 5.w,
                endIndent: 5.w),
            SizedBox(height: 0.8.h),
            Text(
              _language == 'ENGLISH'
                  ? 'The tracker device is not a substitute for vehicle insurance and is not a theft prevention tool. The company will not be responsible in case of vehicle theft.'
                  : 'ٹریکر ڈیوائس موٹر انشورنس کے متبادل نہیں ہے اور نا ہی چوری کو روکنے کا آلہ ہے، کمپنی گاڑی چوری کی صورت میں زمہ دار نہیں ہوگی۔',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: _language == 'ENGLISH'
                    ? FontWeight.w400
                    : FontWeight.normal,
                fontSize: _language == 'ENGLISH' ? 16.sp : 14.sp,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedGauge extends StatefulWidget {
  final List<ChartData> vehicleStatusCountdata;
  final int totalDevices;
  final double gaugeSize;

  const AnimatedGauge({
    super.key,
    required this.vehicleStatusCountdata,
    required this.totalDevices,
    required this.gaugeSize,
  });

  @override
  AnimatedGaugeState createState() => AnimatedGaugeState();
}

class AnimatedGaugeState extends State<AnimatedGauge>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getStatusValue(String status) => widget.vehicleStatusCountdata
      .firstWhere((data) => data.x == status,
      orElse: () => ChartData(status, 0, Colors.grey))
      .y
      .toDouble();

  @override
  Widget build(BuildContext context) {
    if (widget.totalDevices == 0) {
      return Center(
          child: Text("Loading vehicles", style: TextStyle(fontSize: 16.sp)));
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SfRadialGauge(
          axes: [
            _buildAxis(
                widget.totalDevices.toDouble(),
                _getStatusValue('Running') * _animation.value,
                Colors.green,
                1.0),
            _buildAxis(
                widget.totalDevices.toDouble(),
                _getStatusValue('Stopped') * _animation.value,
                Colors.red,
                0.85),
            _buildAxis(
                widget.totalDevices.toDouble(),
                _getStatusValue('Offline') * _animation.value,
                Colors.blue,
                0.7),
            _buildAxis(
                widget.totalDevices.toDouble(),
                _getStatusValue('Idle') * _animation.value,
                const Color(0xffFBB117),
                0.55),
          ],
        );
      },
    );
  }

  RadialAxis _buildAxis(
      double max, double value, Color color, double radiusFactor) =>
      RadialAxis(
        minimum: 0,
        maximum: max,
        startAngle: 270,
        endAngle: 270,
        showLabels: false,
        showTicks: false,
        radiusFactor: radiusFactor,
        axisLineStyle: AxisLineStyle(
          thickness: widget.gaugeSize * 0.03,
          color: Colors.grey[50],
        ),
        pointers: [
          RangePointer(
            value: value,
            color: color,
            width: widget.gaugeSize * 0.03,
          ),
        ],
      );
}