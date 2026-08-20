class EventsModel {
  int? status;
  Items? items;

  EventsModel({this.status, this.items});

  EventsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    items = json['items'] != null ? Items.fromJson(json['items']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (items != null) {
      data['items'] = items!.toJson();
    }
    return data;
  }
}

class Items {
  int? currentPage;
  List<Data>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  Items(
      {this.currentPage,
      this.data,
      this.firstPageUrl,
      this.from,
      this.lastPage,
      this.lastPageUrl,
      this.nextPageUrl,
      this.path,
      this.perPage,
      this.prevPageUrl,
      this.to,
      this.total});

  Items.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  int? deviceId;
  dynamic geofenceId;
  dynamic poiId;
  int? positionId;
  int? alertId;
  String? type;
  String? message;
  dynamic address;
  int? altitude;
  int? course;
  dynamic latitude;
  dynamic longitude;
  dynamic power;
  int? speed;
  String? time;
  int? deleted;
  String? createdAt;
  String? updatedAt;
  Additional? additional;
  dynamic description;
  dynamic driver;
  dynamic violation;
  int? hideEvents;
  dynamic notificationDetails;
  String? name;
  String? detail;
  dynamic geofence;
  String? deviceName;

  Data(
      {this.id,
      this.userId,
      this.deviceId,
      this.geofenceId,
      this.poiId,
      this.positionId,
      this.alertId,
      this.type,
      this.message,
      this.address,
      this.altitude,
      this.course,
      this.latitude,
      this.longitude,
      this.power,
      this.speed,
      this.time,
      this.deleted,
      this.createdAt,
      this.updatedAt,
      this.additional,
      this.description,
      this.driver,
      this.violation,
      this.hideEvents,
      this.notificationDetails,
      this.name,
      this.detail,
      this.geofence,
      this.deviceName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    deviceId = json['device_id'];
    geofenceId = json['geofence_id'];
    poiId = json['poi_id'];
    positionId = json['position_id'];
    alertId = json['alert_id'];
    type = json['type'];
    message = json['message'];
    address = json['address'];
    altitude = json['altitude'];
    course = json['course'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    power = json['power'];
    speed = json['speed'];
    time = json['time'];
    deleted = json['deleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    additional = json['additional'] != null
        ? Additional.fromJson(json['additional'])
        : null;
    description = json['description'];
    driver = json['driver'];
    violation = json['violation'];
    hideEvents = json['hide_events'];
    notificationDetails = json['notification_details'];
    name = json['name'];
    detail = json['detail'];
    geofence = json['geofence'];
    deviceName = json['device_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['device_id'] = deviceId;
    data['geofence_id'] = geofenceId;
    data['poi_id'] = poiId;
    data['position_id'] = positionId;
    data['alert_id'] = alertId;
    data['type'] = type;
    data['message'] = message;
    data['address'] = address;
    data['altitude'] = altitude;
    data['course'] = course;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['power'] = power;
    data['speed'] = speed;
    data['time'] = time;
    data['deleted'] = deleted;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (additional != null) {
      data['additional'] = additional!.toJson();
    }
    data['description'] = description;
    data['driver'] = driver;
    data['violation'] = violation;
    data['hide_events'] = hideEvents;
    data['notification_details'] = notificationDetails;
    data['name'] = name;
    data['detail'] = detail;
    data['geofence'] = geofence;
    data['device_name'] = deviceName;
    return data;
  }
}

class Additional {
  int? stopDuration;
  String? movedAt;
  int? overspeedSpeed;

  Additional({this.stopDuration, this.movedAt, this.overspeedSpeed});

  Additional.fromJson(Map<String, dynamic> json) {
    stopDuration = json['stop_duration'];
    movedAt = json['moved_at'];
    overspeedSpeed = json['overspeed_speed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stop_duration'] = stopDuration;
    data['moved_at'] = movedAt;
    data['overspeed_speed'] = overspeedSpeed;
    return data;
  }
}
