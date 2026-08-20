class DeviceCommandResultModel {
  int? status;
  String? message;
  String? error;

  DeviceCommandResultModel({this.status, this.message});

  DeviceCommandResultModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> commadData = <String, dynamic>{};
    commadData['status'] = status;
    commadData['message'] = message;
    commadData['error'] = error;
    return commadData;
  }
}
