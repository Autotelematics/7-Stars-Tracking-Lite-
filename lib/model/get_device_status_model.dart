import 'dart:convert';
import 'dart:developer';

GetDeviceStatusModel getDeviceStatusModelFromJson(String str) {
  try {
    return GetDeviceStatusModel.fromJson(json.decode(str));
  } catch (e) {
    log('Error decoding JSON: $e');
    return GetDeviceStatusModel(
      totalCount: 0,
      ack: 0,
      online: 0,
      offline: 0,
      idle: 0,
      items: [],
    );
  }
}

String getDeviceStatusModelToJson(GetDeviceStatusModel data) => json.encode(data.toJson());

class GetDeviceStatusModel {
  final int totalCount;
  final int ack;
  final int online;
  final int offline;
  final int idle;
  final List<Item> items;

  GetDeviceStatusModel({
    required this.totalCount,
    required this.ack,
    required this.online,
    required this.offline,
    required this.idle,
    required this.items,
  });

  factory GetDeviceStatusModel.fromJson(Map<String, dynamic> json) {
    return GetDeviceStatusModel(
      totalCount: json["total_count"] as int? ?? 0,
      ack: json["ack"] as int? ?? 0,
      online: json["online"] as int? ?? 0,
      offline: json["offline"] as int? ?? 0,
      idle: json["idle"] as int? ?? 0,
      items: json["items"] != null && json["items"] is List
          ? List<Item>.from(
        (json["items"] as List).map((x) {
          try {
            return Item.fromJson(x);
          } catch (_) {
            return Item(
              id: 0,
              name: '',
              online: Online.OFFLINE,
              time: '',
              lat: null,
              lng: null,
              course: 0,
              speed: 0,
              icon: '',
            );
          }
        }),
      )
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "total_count": totalCount,
    "ack": ack,
    "online": online,
    "offline": offline,
    "idle": idle,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  final int id;
  final String name;
  final Online online;
  final String time;
  final double? lat;
  final double? lng;
  final int course;
  final int speed;
  final String icon;

  Item({
    required this.id,
    required this.name,
    required this.online,
    required this.time,
    required this.lat,
    required this.lng,
    required this.course,
    required this.speed,
    required this.icon,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Item(
      id: json["id"] as int? ?? 0,
      name: json["name"] as String? ?? '',
      online: onlineValues.map[json["online"] as String?] ?? Online.OFFLINE,
      time: json["time"] as String? ?? '',
      lat: parseDouble(json["lat"]),
      lng: parseDouble(json["lng"]),
      course: json["course"] as int? ?? 0,
      speed: json["speed"] as int? ?? 0,
      icon: json["icon"] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "online": onlineValues.reverse[online],
    "time": time,
    "lat": lat,
    "lng": lng,
    "course": course,
    "speed": speed,
    "icon": icon,
  };
}

enum Online {
  ACK,
  OFFLINE,
  ONLINE,
}

final onlineValues = EnumValues({
  "ack": Online.ACK,
  "offline": Online.OFFLINE,
  "online": Online.ONLINE,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
