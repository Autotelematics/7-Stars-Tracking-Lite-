class ViewReportIntialData {
  String? fromDate;
  String? toDate;
  int? deviceID;
  String? reportFormat;
  String? reportName;
  int? reportType;
  int? speed_limit;
  int? ignition_off;
  List? geofences;
  final String fromTime; // Add this
  final String toTime;

  ViewReportIntialData(
    this.fromDate,
    this.toDate,
    this.deviceID,
    this.reportFormat,
    this.reportType,
    this.speed_limit,
    this.geofences,
    this.ignition_off,
    this.reportName,
    this.fromTime,
    this.toTime,
  );
}
