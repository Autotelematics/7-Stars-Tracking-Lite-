class PlayBackRoute {
  String? deviceId;
  String? latitude;
  String? longitude;
  String? course;
  String? rawTime;
  String? distance;
  dynamic speed;
  String? time;

  PlayBackRoute({
    this.deviceId,
    this.latitude,
    this.longitude,
    this.course,
    this.rawTime,
    this.distance,
    this.speed,
  });

  PlayBackRoute.fromJson(Map<String, dynamic> json) {
    deviceId = json["device_id"];
    latitude = json["latitude"];
    longitude = json["longitude"];
    course = json["course"];
    rawTime = json["raw_time"];
    distance = json["distance"];
    speed = json["speed"];
  }

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'latitude': latitude,
        'longitude': longitude,
        'course': course,
        'raw_time': rawTime,
        'distance': distance,
        'speed': speed
      };
}
