import 'package:autotelematic_new_app/model/devicedatamodalforhistoryandreport.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CustomeHistoryDateTimePicker extends StatefulWidget {
  final int deviceID;
  final String screenRout;
  final String deviceName;
  const CustomeHistoryDateTimePicker(
      this.deviceName, this.deviceID, this.screenRout,
      {super.key});

  @override
  State<CustomeHistoryDateTimePicker> createState() =>
      _CustomeHistoryDateTimePickerState();
}

class _CustomeHistoryDateTimePickerState
    extends State<CustomeHistoryDateTimePicker> {
  late String buttonText;
  DateTime currentDateTime = DateTime.now();
  // DateTime initialDateTime = DateTime(2023, 01, 19, 5, 30);
  DateFormat dateFormat = DateFormat("yy-MM-dd");
  DateFormat timeFormat = DateFormat("HH:mm:ss");
  DateTime initialDateTimeFrom = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day, 00, 01, 00);
  DateTime initialDateTimeTo = DateTime(DateTime.now().year,
      DateTime.now().month, DateTime.now().day, 23, 59, 00);

  Future<DateTime?> pickDate() {
    return showDatePicker(
      context: context,
      initialDate: initialDateTimeFrom,
      firstDate: DateTime(1900),
      lastDate: DateTime(2030),
    );
  }

  Future<TimeOfDay?> pickTime() {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: initialDateTimeFrom.hour, minute: initialDateTimeFrom.minute),
    );
  }

  void navigate() {
    if (widget.screenRout == 'playroutonmap') {
      Navigator.pushNamed(
        context,
        RoutesName.viewHistory,
        arguments: DeviceDataForReportsAndHistory(
          deviceTitle: widget.deviceName,
          deviceId: widget.deviceID,
          fromDate: dateFormat.format(initialDateTimeFrom),
          toDate: dateFormat.format(initialDateTimeTo),
          fromTime: timeFormat.format(initialDateTimeFrom),
          toTime: timeFormat.format(initialDateTimeTo),
        ),
      );
    } else if (widget.screenRout == 'reporttype') {
      Navigator.pushNamed(
        context,
        RoutesName.reportTypes,
        arguments: DeviceDataForReportsAndHistory(
          deviceTitle: widget.deviceName,
          deviceId: widget.deviceID,
          fromDate: dateFormat.format(initialDateTimeFrom),
          toDate: dateFormat.format(initialDateTimeTo),
          fromTime: timeFormat.format(initialDateTimeFrom),
          toTime: timeFormat.format(initialDateTimeTo),
        ),
      );
    }
  }

  @override
  void initState() {
    if (widget.screenRout == 'playroutonmap') {
      buttonText = 'View History';
    } else if (widget.screenRout == 'reporttype') {
      buttonText = 'View Report';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, value, child) {
        final hoursFrom = initialDateTimeFrom.hour.toString().padLeft(2, '0');
        final minutesFrom =
        initialDateTimeFrom.minute.toString().padLeft(2, '0');
        final hoursTo = initialDateTimeTo.hour.toString().padLeft(2, '0');
        final minutesTo = initialDateTimeTo.minute.toString().padLeft(2, '0');
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Select Date and Time range  ',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
            const Divider(),
            const Text(
              'From:',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final date = await pickDate();
                    if (date == null) {
                      return;
                    }
                    final newDatetime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      initialDateTimeFrom.hour,
                      initialDateTimeFrom.minute,
                    );
                    initialDateTimeFrom = newDatetime;
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.date_range),
                      Text(
                          '${initialDateTimeFrom.day}/${initialDateTimeFrom.month}/${initialDateTimeFrom.year}'),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final selTime = await pickTime();
                    if (selTime == null) {
                      return;
                    }
                    final newDatetime = DateTime(
                      initialDateTimeFrom.year,
                      initialDateTimeFrom.month,
                      initialDateTimeFrom.day,
                      selTime.hour,
                      selTime.minute,
                    );
                    initialDateTimeFrom = newDatetime;
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined),
                      Text('$hoursFrom:$minutesFrom'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            const Text(
              'To:',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final date = await pickDate();
                    if (date == null) {
                      return;
                    }
                    final newDatetime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      initialDateTimeTo.hour,
                      initialDateTimeTo.minute,
                    );
                    initialDateTimeTo = newDatetime;
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.date_range),
                      Text(
                          '${initialDateTimeTo.day}/${initialDateTimeTo.month}/${initialDateTimeTo.year}'),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final selTime = await pickTime();
                    if (selTime == null) {
                      return;
                    }
                    final newDatetime = DateTime(
                      initialDateTimeTo.year,
                      initialDateTimeTo.month,
                      initialDateTimeTo.day,
                      selTime.hour,
                      selTime.minute,
                    );
                    initialDateTimeTo = newDatetime;
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined),
                      Text('$hoursTo:$minutesTo'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => navigate(),
                  child: Text(buttonText,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}