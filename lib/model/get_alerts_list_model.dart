import 'dart:convert';

// JSON helpers
GetAlertsModel getAlertsModelFromJson(String str) =>
    GetAlertsModel.fromJson(json.decode(str));

String getAlertsModelToJson(GetAlertsModel data) => json.encode(data.toJson());

// Main model
class GetAlertsModel {
  final int status;
  final int page;
  final int perPage;
  final int total;
  final Map<String, int> counts;
  final List<Item> items;
  final dynamic message;

  GetAlertsModel({
    required this.status,
    required this.page,
    required this.perPage,
    required this.total,
    required this.counts,
    required this.items,
    required this.message,
  });

  factory GetAlertsModel.fromJson(Map<String, dynamic> json) => GetAlertsModel(
    status: json["status"] ?? 0,
    page: json["page"] ?? 1,
    perPage: json["per_page"] ?? 10,
    total: json["total"] ?? 0,
    counts: json["counts"] is Map
        ? (json["counts"] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toInt()))
        : {},
    items: json["items"] != null
        ? List<Item>.from(
        (json["items"] as List).map((x) => Item.fromJson(x)))
        : [],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "page": page,
    "per_page": perPage,
    "total": total,
    "counts": counts, // Directly output the map
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "message": message,
  };

  // Optionally, a copyWith method
  GetAlertsModel copyWith({
    int? status,
    int? page,
    int? perPage,
    int? total,
    Map<String, int>? counts,
    List<Item>? items,
    dynamic message,
  }) =>
      GetAlertsModel(
        status: status ?? this.status,
        page: page ?? this.page,
        perPage: perPage ?? this.perPage,
        total: total ?? this.total,
        counts: counts ?? this.counts,
        items: items ?? this.items,
        message: message ?? this.message,
      );
}

// Counts model
class Counts {
  final int offlineDuration;
  final int ignitionDuration;
  final int idleDuration;
  final int moveStart;
  final int overParking;
  final int overSpeed;

  Counts({
    required this.offlineDuration,
    required this.ignitionDuration,
    required this.idleDuration,
    required this.moveStart,
    required this.overParking,
    required this.overSpeed,
  });

  factory Counts.fromJson(Map<String, dynamic> json) => Counts(
    offlineDuration: json["Offline duration"] ?? 0,
    ignitionDuration: json["Ignition duration"] ?? 0,
    idleDuration: json["Idle Duration"] ?? 0,
    moveStart: json["Move Start"] ?? 0,
    overParking: json["Over Parking"] ?? 0,
    overSpeed: json["Over Speed"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "Offline duration": offlineDuration,
    "Ignition duration": ignitionDuration,
    "Idle Duration": idleDuration,
    "Move Start": moveStart,
    "Over Parking": overParking,
    "Over Speed": overSpeed,
  };
}

// Main alert/item model (NO enum for device name!)
class Item {
  final int id;
  final String type; // Use String instead of enum
  final DateTime? time;
  final String message;
  final String address;
  final int course;
  final double latitude;
  final double longitude;
  final int speed;
  final String detail;
  final dynamic geofence;
  final String deviceName; // String, not enum!
  final int deviceId;

  Item({
    required this.id,
    required this.type,
    required this.time,
    required this.message,
    required this.address,
    required this.course,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.detail,
    required this.geofence,
    required this.deviceName,
    required this.deviceId,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] ?? 0,
    type: json["type"] ?? "", // Use string directly
    time: json["time"] != null ? DateTime.tryParse(json["time"]) : null,
    message: json["message"] ?? "",
    address: json["address"] ?? "",
    course: json["course"] ?? 0,
    latitude: (json["latitude"] as num?)?.toDouble() ?? 0.0,
    longitude: (json["longitude"] as num?)?.toDouble() ?? 0.0,
    speed: json["speed"] ?? 0,
    detail: json["detail"] ?? "",
    geofence: json["geofence"],
    deviceName: json['device_name'] ?? '', // Direct string mapping
    deviceId: json["device_id"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type, // Output as string
    "time": time?.toIso8601String(),
    "message": message,
    "address": address,
    "course": course,
    "latitude": latitude,
    "longitude": longitude,
    "speed": speed,
    "detail": detail,
    "geofence": geofence,
    "device_name": deviceName, // Output as string
    "device_id": deviceId,
  };
}
