class GeofenceResponse {
  final GeofenceItems items;
  final int status;

  GeofenceResponse({required this.items, required this.status});

  factory GeofenceResponse.fromJson(Map<String, dynamic> json) {
    return GeofenceResponse(
      items: GeofenceItems.fromJson(json['items']),
      status: json['status'],
    );
  }
}

class GeofenceItems {
  final List<Geofence> geofences;

  GeofenceItems({required this.geofences});

  factory GeofenceItems.fromJson(Map<String, dynamic> json) {
    return GeofenceItems(
      geofences: List<Geofence>.from(
        json['geofences'].map((x) => Geofence.fromJson(x)),
      ),
    );
  }
}

class Geofence {
  final int id;
  final int userId;
  final int groupId;
  final int active;
  final String name;
  final String coordinates;
  final String polygonColor;
  final String createdAt;
  final String updatedAt;
  final String type;
  final int? radius;
  final GeofenceCenter? center;
  final int? deviceId;
  bool isSelected; // Added for selection state

  Geofence({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.active,
    required this.name,
    required this.coordinates,
    required this.polygonColor,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    this.radius,
    this.center,
    this.deviceId,
    this.isSelected = false, // Default to false
  });

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: json['id'],
      userId: json['user_id'],
      groupId: json['group_id'],
      active: json['active'],
      name: json['name'],
      coordinates: json['coordinates'],
      polygonColor: json['polygon_color'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      type: json['type'],
      radius: json['radius'],
      center: json['center'] != null
          ? GeofenceCenter.fromJson(json['center'])
          : null,
      deviceId: json['device_id'],
    );
  }
}

class GeofenceCenter {
  final String lat;
  final String lng;

  GeofenceCenter({required this.lat, required this.lng});

  factory GeofenceCenter.fromJson(Map<String, dynamic> json) {
    return GeofenceCenter(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}