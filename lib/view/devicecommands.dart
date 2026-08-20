import 'package:autotelematic_new_app/cubit/device_command_list_cubit.dart';
import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DeviceCommandsScreen extends StatefulWidget {
  final int deviceID;
  const DeviceCommandsScreen({super.key, required this.deviceID});

  @override
  State<DeviceCommandsScreen> createState() => _DeviceCommandsScreenState();
}

class _DeviceCommandsScreenState extends State<DeviceCommandsScreen> {
  DeviceCommandListCubit deviceCommandListCubit = DeviceCommandListCubit();
  int? groupValue;
  String deviceCommand = 'No Command';

  @override
  void initState() {
    deviceCommandListCubit.fetchCommandsList(widget.deviceID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider.value(
        value: deviceCommandListCubit,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'IMOBILIZER',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            BlocBuilder<DeviceCommandListCubit, DeviceCommandListState>(
              builder: (context, state) {
                if (state is DeviceCommandListLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppTheme.loadingImage,
                        const SizedBox(height: 5),
                        const Text('Loading...'),
                      ],
                    ),
                  );
                }
                if (state is DeviceCommandListError) {
                  return Center(
                    child: Text("Failed to send command."),
                  );
                }
                if (state is DeviceCommandsendComplete) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [Text('Command has been sent to device.')],
                  );
                }
                if (state is DeviceCommandListLoadingComplete) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: state.deviceCommandsList.length,
                      itemBuilder: (context, index) {
                        if (state.deviceCommandsList[index].type.toString() ==
                                'custom' ||
                            state.deviceCommandsList[index].type.toString() ==
                                'engineResume' ||
                            state.deviceCommandsList[index].type.toString() ==
                                'engineStop') {
                          return Container();
                        }
                        return RadioListTile(
                          title: Text(
                            state.deviceCommandsList[index].title.toString(),
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          value: index,
                          groupValue: groupValue,
                          onChanged: (value) {
                            setState(() {
                              groupValue = value;
                              deviceCommand = state
                                  .deviceCommandsList[index].type
                                  .toString();
                              print(
                                  "deviceCommand: ${state.deviceCommandsList[index].title.toString()}");
                            });
                          },
                        );
                      },
                    ),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [Text('Loading....')],
                );
              },
            ),
            BlocBuilder<DeviceCommandListCubit, DeviceCommandListState>(
              builder: (context, state) {
                bool isComplete = state is DeviceCommandsendComplete ||
                    state is DeviceCommandListError;
                bool isLoading = state is DeviceCommandListLoading;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isComplete && !isLoading)
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    const VerticalDivider(),
                    ElevatedButton(
                      onPressed: () {
                        isComplete || isLoading
                            ? Navigator.pop(context)
                            : context
                                .read<DeviceCommandListCubit>()
                                .sendDeviceCommandtoAPI(
                                  deviceCommand,
                                  widget.deviceID.toString(),
                                );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 0.5.h),
                      ),
                      child: Text(
                        isLoading
                            ? 'Sending...'
                            : isComplete
                                ? 'Ok'
                                : 'Send',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
