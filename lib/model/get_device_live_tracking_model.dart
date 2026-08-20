import 'dart:convert';

GetDeviceLiveTrackingModel getDeviceLiveTrackingModelFromJson(String str) => GetDeviceLiveTrackingModel.fromJson(json.decode(str));

String getDeviceLiveTrackingModelToJson(GetDeviceLiveTrackingModel data) => json.encode(data.toJson());

class GetDeviceLiveTrackingModel {
  final int? status;
  final Item? item;

  GetDeviceLiveTrackingModel({
    this.status,
    this.item,
  });

  factory GetDeviceLiveTrackingModel.fromJson(Map<String, dynamic> json) => GetDeviceLiveTrackingModel(
    status: json["status"] as int?,
    item: json["item"] != null ? Item.fromJson(json["item"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "item": item?.toJson(),
  };
}

class Item {
  final int? id;
  final String? name;
  final String? online;
  final String? time;
  final int? timestamp;
  final int? acktimestamp;
  final String? lat;
  final String? lng;
  final String? addr;
  final int? course;
  final int? speed;
  final String? path;
  final List<Sensor>? sensors;
  final String? stopDuration;
  final DateTime? movedAt;
  final double? odometer;
  final List<Tail>? tail;

  Item({
    this.id,
    this.name,
    this.online,
    this.time,
    this.timestamp,
    this.acktimestamp,
    this.lat,
    this.lng,
    this.addr,
    this.course,
    this.speed,
    this.path,
    this.sensors,
    this.stopDuration,
    this.movedAt,
    this.odometer,
    this.tail,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] as int?,
    name: json["name"] as String?,
    online: json["online"] as String?,
    time: json["time"] as String?,
    timestamp: _toInt(json["timestamp"]),
    acktimestamp: _toInt(json["acktimestamp"]),
    lat: _toString(json["lat"]),
    lng: _toString(json["lng"]),
    addr: json["addr"] as String?,
    course: json["course"] as int?,
    speed: json["speed"] as int?,
    path: json["path"] as String?,
    sensors: json["sensors"] != null
        ? List<Sensor>.from(json["sensors"].map((x) => Sensor.fromJson(x)))
        : null,
    stopDuration: json["stop_duration"] as String?,
    movedAt: json["moved_at"] != null
        ? _parseDateTime(json["moved_at"])
        : null,
    odometer: json["odometer"]?.toDouble(),
    tail: json["tail"] != null
        ? List<Tail>.from(json["tail"].map((x) => Tail.fromJson(x)))
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "online": online,
    "time": time,
    "timestamp": timestamp,
    "acktimestamp": acktimestamp,
    "lat": lat,
    "lng": lng,
    "addr": addr,
    "course": course,
    "speed": speed,
    "path": path,
    "sensors": sensors != null
        ? List<dynamic>.from(sensors!.map((x) => x.toJson()))
        : null,
    "stop_duration": stopDuration,
    "moved_at": movedAt?.toIso8601String(),
    "odometer": odometer,
    "tail": tail != null
        ? List<dynamic>.from(tail!.map((x) => x.toJson()))
        : null,
  };

  static String? _toString(dynamic value) {
    if (value == null) return null;
    return value.toString(); // Converts double, int, or other types to String
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null; // Handle unexpected types
  }

  static DateTime? _parseDateTime(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}
class Sensor {
  final int? id;
  final String? type;
  final String? name;
  final int? showInPopup;
  final String? value;
  final dynamic val;
  final int? scaleValue;

  Sensor({
    this.id,
    this.type,
    this.name,
    this.showInPopup,
    this.value,
    this.val,
    this.scaleValue,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) => Sensor(
    id: json["id"] as int?,
    type: json["type"] as String?,
    name: json["name"] as String?,
    showInPopup: json["show_in_popup"] as int?,
    value: json["value"] as String?,
    val: json["val"],
    scaleValue: json["scale_value"] as int?,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "name": name,
    "show_in_popup": showInPopup,
    "value": value,
    "val": val,
    "scale_value": scaleValue,
  };
}

class Tail {
  final String? lat;
  final String? lng;

  Tail({this.lat, this.lng});

  factory Tail.fromJson(Map<String, dynamic> json) => Tail(
    lat: json["lat"] as String?,
    lng: json["lng"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
  };
}