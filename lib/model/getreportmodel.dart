class GetReportModel {
  int? status;
  String? url;
  GetReportModel({this.status, this.url});

  GetReportModel.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    url = json["url"];
  }
}
