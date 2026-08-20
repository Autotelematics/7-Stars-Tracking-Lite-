class DevicesModel {
  dynamic id;
  String? title;
  List<dynamic>? items;

  DevicesModel({this.id, this.title, this.items});

  DevicesModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    title = json["title"];
    items = json["items"];
  }
}

class DeviceItem extends Object {
  int id;
  int alarm;
  String name;
  String online;
  String time;
  int timestamp;
  int acktimestamp;
  double lat;
  double lng;
  double course;
  double speed;
  double altitude;
  String stop_duration;
  String icon_type;
  String icon_color;
  late Map<String, dynamic> icon_colors;
  Map<String, dynamic> icon;
  String power;
  String address;
  String protocol;
  String driver;
  Map<String, dynamic> driver_data;
  List<dynamic> sensors;
  List<dynamic> services;
  List<dynamic> tail;
  String engine_on_at;
  String engine_off_at;

  DeviceItem(
      {required this.id,
      required this.alarm,
      required this.name,
      required this.online,
      required this.time,
      required this.timestamp,
      required this.acktimestamp,
      required this.lat,
      required this.lng,
      required this.course,
      required this.speed,
      required this.altitude,
      required this.stop_duration,
      required this.icon_type,
      required this.icon_color,
      required this.icon,
      required this.power,
      required this.address,
      required this.protocol,
      required this.driver,
      required this.driver_data,
      required this.sensors,
      required this.services,
      required this.tail,
      required this.engine_on_at,
      required this.engine_off_at});
}
