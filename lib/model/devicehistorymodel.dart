// devicehistorymodel.dart (updated)

class DeviceHistoryModel {
  List<Items>? items;
  Device? device;
  dynamic distanceSum;
  dynamic topSpeed;
  dynamic moveDuration;
  dynamic stopDuration;
  dynamic fuelConsumption;
  List<Sensors>? sensors;
  List<dynamic>? fuelConsumptionArr;
  List<ItemClass>? itemClass;
  List<Images>? images;
  dynamic status;

  DeviceHistoryModel({
    this.items,
    this.device,
    this.distanceSum,
    this.topSpeed,
    this.moveDuration,
    this.stopDuration,
    this.fuelConsumption,
    this.sensors,
    this.fuelConsumptionArr,
    this.itemClass,
    this.images,
    this.status,
  });

  DeviceHistoryModel.fromJson(Map<dynamic, dynamic> json) {
    // items (required by your UI)
    final rawItems = json['items'];
    items = (rawItems is List)
        ? rawItems.map((e) => Items.fromJson(e as Map)).toList()
        : <Items>[];

    // Optional blocks (not always present in the sample you shared)
    device = (json['device'] != null) ? Device.fromJson(json['device']) : null;
    sensors = (json['sensors'] is List)
        ? (json['sensors'] as List).map((e) => Sensors.fromJson(e)).toList()
        : null;
    images = (json['images'] is List)
        ? (json['images'] as List).map((e) => Images.fromJson(e)).toList()
        : null;

    fuelConsumptionArr = (json['fuel_consumption_arr'] is List)
        ? List<dynamic>.from(json['fuel_consumption_arr'])
        : null;

    itemClass = (json['item_class'] is List)
        ? (json['item_class'] as List)
            .map((e) => ItemClass.fromJson(e))
            .toList()
        : null;

    distanceSum = json['distance_sum'];
    topSpeed = json['top_speed'];
    moveDuration = json['move_duration'];
    stopDuration = json['stop_duration'];
    fuelConsumption = json['fuel_consumption'];
    status = json['status'];
  }

  Map<dynamic, dynamic> toJson() {
    final data = <dynamic, dynamic>{};
    data['items'] = items?.map((e) => e.toJson()).toList();
    data['device'] = device?.toJson();
    data['distance_sum'] = distanceSum;
    data['top_speed'] = topSpeed;
    data['move_duration'] = moveDuration;
    data['stop_duration'] = stopDuration;
    data['fuel_consumption'] = fuelConsumption;
    data['sensors'] = sensors?.map((e) => e.toJson()).toList();
    data['fuel_consumption_arr'] = fuelConsumptionArr;
    data['item_class'] = itemClass?.map((e) => e.toJson()).toList();
    data['images'] = images?.map((e) => e.toJson()).toList();
    data['status'] = status;
    return data;
  }

  // Get messages for items with status == 5 (alerts)
  List<String> getMessagesForStatus5() {
    final out = <String>[];
    if (items == null) return out;
    for (final item in items!) {
      if (item.status == 5 && item.message != null) {
        out.add(item.message!);
      }
    }
    return out;
  }

  /// Sort by a real timestamp:
  /// - Prefer top-level `raw_time`
  /// - Fallback to the first child point's `raw_time`
  List<Items> getSortedItemsByTime() {
    if (items == null) return [];
    final copy = List<Items>.from(items!);
    DateTime? _parse(String? s) {
      if (s == null) return null;
      try {
        // Accepts "yyyy-MM-dd HH:mm:ss"
        return DateTime.parse(s.replaceFirst(' ', 'T'));
      } catch (_) {
        return null;
      }
    }

    copy.sort((a, b) {
      final aRaw = a.rawTime?.toString();
      final bRaw = b.rawTime?.toString();
      final aChild = a.itemsFirstRawTime;
      final bChild = b.itemsFirstRawTime;
      final adt = _parse(aRaw) ??
          _parse(aChild) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bdt = _parse(bRaw) ??
          _parse(bChild) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return adt.compareTo(bdt);
    });
    return copy;
  }
}

class Items {
  dynamic status; // 1=drive, 2=stop, 3=start, 4=end, 5=event
  dynamic time; // e.g. "4h 32min 14s"
  dynamic show; // (may be null in your sample)
  dynamic topSpeed; // per-block numeric or string
  dynamic avgSpeed; // per-block numeric or string
  dynamic left; // e.g. "01-09-2025 04:49:18 AM"
  dynamic rawTime; // e.g. "2025-09-01 00:17:04"
  dynamic distance; // numeric or string
  dynamic driver;
  String? message;
  // IMPORTANT: Use Map<String, dynamic> for each point
  List<Map<String, dynamic>> statusItems;

  Items({
    this.status,
    this.time,
    this.show,
    this.topSpeed,
    this.avgSpeed,
    this.left,
    this.rawTime,
    this.distance,
    this.driver,
    this.message,
    List<Map<String, dynamic>>? statusItems,
  }) : statusItems = statusItems ?? <Map<String, dynamic>>[];

  /// First child raw_time (fallback for sorting)
  String? get itemsFirstRawTime =>
      statusItems.isNotEmpty ? statusItems.first['raw_time']?.toString() : null;

  Items.fromJson(Map<dynamic, dynamic> json)
      : statusItems = <Map<String, dynamic>>[] {
    status = json['status'];
    time = json['time'];
    show = json['show'];
    left = json['left'];
    topSpeed = json['top_speed'];
    avgSpeed = json['average_speed'];
    rawTime = json['raw_time'];
    distance = json['distance'];
    driver = json['driver'];
    message = json['message'];

    // Normalize child points ("items" list)
    final rawList =
        (json['items'] is List) ? List<Map>.from(json['items']) : <Map>[];
    for (final m0 in rawList) {
      final m = Map<String, dynamic>.from(m0);

      // Map lat/lng -> latitude/longitude for your Cubit
      final lat = m['lat'] ?? m['latitude'];
      final lng = m['lng'] ?? m['longitude'];
      if (m['latitude'] == null && lat != null) m['latitude'] = lat;
      if (m['longitude'] == null && lng != null) m['longitude'] = lng;

      // Ensure point has a 'time' (fallback to raw_time)
      if (m['time'] == null && m['raw_time'] != null) {
        m['time'] = m['raw_time'];
      }

      statusItems.add(m);
    }
  }

  Map<dynamic, dynamic> toJson() {
    final data = <dynamic, dynamic>{};
    data['status'] = status;
    data['time'] = time;
    data['show'] = show;
    data['left'] = left;
    data['top_speed'] = topSpeed;
    data['average_speed'] = avgSpeed;
    data['raw_time'] = rawTime;
    data['distance'] = distance;
    data['driver'] = driver;
    data['items'] = statusItems;
    data['message'] = message;
    return data;
  }
}

class Device {
  Device({
    this.id,
    this.userId,
    this.currentDriverId,
    this.timezoneId,
    this.traccarDeviceId,
    this.iconId,
    required this.iconColors,
    this.active,
    this.deleted,
    this.name,
    this.imei,
    this.fuelMeasurementId,
    this.fuelQuantity,
    this.fuelPrice,
    this.fuelPerKm,
    this.simNumber,
    this.msisdn,
    this.deviceModel,
    this.plateNumber,
    this.vin,
    this.registrationNumber,
    this.objectOwner,
    this.additionalNotes,
    this.expirationDate,
    this.simExpirationDate,
    this.simActivationDate,
    this.installationDate,
    this.tailColor,
    this.tailLength,
    this.engineHours,
    this.detectEngine,
    this.minMovingSpeed,
    this.minFuelFillings,
    this.minFuelThefts,
    this.snapToRoad,
    this.gprsTemplatesOnly,
    this.validByAvgSpeed,
    this.parameters,
    this.currents,
    this.createdAt,
    this.updatedAt,
    this.forward,
    this.deviceTypeId,
    this.vrn,
    this.make,
    this.model,
    this.colour,
    this.engine,
    this.chasisNo,
    this.type,
    this.customerName,
    this.mobile_1,
    this.mobile_2,
    this.secondaryMobileNo,
    this.emergency1MobileNo,
    this.emergency2MobileNo,
    this.nicNo,
    this.address,
    this.normalPassword,
    this.emergencyPassword,
    this.motherName,
    this.dateOfBirth,
    this.instructions,
    this.ownerName,
    this.corporateName,
    this.bankName,
    this.insuranceName,
    this.province,
    this.city,
    this.geofence,
    this.valueAddedServices,
    this.salesPerson,
    this.installer,
    this.stopDuration,
    this.sensors,
    required this.traccar,
  });

  dynamic id;
  dynamic userId;
  dynamic currentDriverId;
  dynamic timezoneId;
  dynamic traccarDeviceId;
  dynamic iconId;
  IconColors iconColors =
      IconColors(moving: null, stopped: null, offline: null, engine: null);
  dynamic active;
  dynamic deleted;
  dynamic name;
  dynamic imei;
  dynamic fuelMeasurementId;
  dynamic fuelQuantity;
  dynamic fuelPrice;
  dynamic fuelPerKm;
  dynamic simNumber;
  dynamic msisdn;
  dynamic deviceModel;
  dynamic plateNumber;
  dynamic vin;
  dynamic registrationNumber;
  dynamic objectOwner;
  dynamic additionalNotes;
  dynamic expirationDate;
  dynamic simExpirationDate;
  dynamic simActivationDate;
  dynamic installationDate;
  dynamic tailColor;
  dynamic tailLength;
  dynamic engineHours;
  dynamic detectEngine;
  dynamic minMovingSpeed;
  dynamic minFuelFillings;
  dynamic minFuelThefts;
  dynamic snapToRoad;
  dynamic gprsTemplatesOnly;
  dynamic validByAvgSpeed;
  dynamic parameters;
  dynamic currents;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic forward;
  dynamic deviceTypeId;
  dynamic vrn;
  dynamic make;
  dynamic model;
  dynamic colour;
  dynamic engine;
  dynamic chasisNo;
  dynamic type;
  dynamic customerName;
  dynamic mobile_1;
  dynamic mobile_2;
  dynamic secondaryMobileNo;
  dynamic emergency1MobileNo;
  dynamic emergency2MobileNo;
  dynamic nicNo;
  dynamic address;
  dynamic normalPassword;
  dynamic emergencyPassword;
  dynamic motherName;
  dynamic dateOfBirth;
  dynamic instructions;
  dynamic ownerName;
  dynamic corporateName;
  dynamic bankName;
  dynamic insuranceName;
  dynamic province;
  dynamic city;
  dynamic geofence;
  dynamic valueAddedServices;
  dynamic salesPerson;
  dynamic installer;
  dynamic stopDuration;
  List<Sensors>? sensors;
  Traccar traccar = Traccar.fromJson({});

  factory Device.fromJson(Map<dynamic, dynamic> json) => Device(
        id: json['id'],
        traccarDeviceId: json['traccar_device_id'],
        iconId: json['icon_id'],
        iconColors: (json['icon_colors'] != null)
            ? IconColors.fromJson(json['icon_colors'])
            : IconColors(
                moving: null, stopped: null, offline: null, engine: null),
        active: json['active'],
        deleted: json['deleted'],
        name: json['name'],
        imei: json['imei'],
        fuelMeasurementId: json['fuel_measurement_id'],
        fuelQuantity: json['fuel_quantity'],
        fuelPrice: json['fuel_price'],
        fuelPerKm: json['fuel_per_km'],
        simNumber: json['sim_number'],
        msisdn: json['msisdn'],
        deviceModel: json['device_model'],
        plateNumber: json['plate_number'],
        vin: json['vin'],
        registrationNumber: json['registration_number'],
        objectOwner: json['object_owner'],
        additionalNotes: json['additional_notes'],
        simExpirationDate: json['sim_expiration_date'],
        simActivationDate: json['sim_activation_date'],
        installationDate: json['installation_date'],
        tailColor: json['tail_color'],
        tailLength: json['tail_length'],
        engineHours: json['engine_hours'],
        detectEngine: json['detect_engine'],
        minMovingSpeed: json['min_moving_speed'],
        minFuelFillings: json['min_fuel_fillings'],
        minFuelThefts: json['min_fuel_thefts'],
        snapToRoad: json['snap_to_road'],
        gprsTemplatesOnly: json['gprs_templates_only'],
        validByAvgSpeed: json['valid_by_avg_speed'],
        parameters: json['parameters'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        vrn: json['vrn'],
        make: json['make'],
        model: json['model'],
        colour: json['colour'],
        engine: json['engine'],
        chasisNo: json['chasis_no'],
        type: json['type'],
        customerName: json['customer_name'],
        mobile_1: json['mobile_1'],
        mobile_2: json['mobile_2'],
        secondaryMobileNo: json['secondary_mobile_no'],
        emergency1MobileNo: json['emergency1_mobile_no'],
        emergency2MobileNo: json['emergency2_mobile_no'],
        nicNo: json['nic_no'],
        address: json['address'],
        normalPassword: json['normal_password'],
        emergencyPassword: json['emergency_password'],
        motherName: json['mother_name'],
        dateOfBirth: json['date_of_birth'],
        instructions: json['instructions'],
        ownerName: json['owner_name'],
        corporateName: json['corporate_name'],
        bankName: json['bank_name'],
        insuranceName: json['insurance_name'],
        province: json['province'],
        city: json['city'],
        geofence: json['geofence'],
        valueAddedServices: json['value_added_services'],
        salesPerson: json['sales_person'],
        installer: json['installer'],
        stopDuration: json['stop_duration'],
        sensors: (json['sensors'] is List)
            ? (json['sensors'] as List).map((e) => Sensors.fromJson(e)).toList()
            : null,
        traccar: (json['traccar'] != null)
            ? Traccar.fromJson(json['traccar'])
            : Traccar.fromJson({}),
      );

  Map<dynamic, dynamic> toJson() {
    final data = <dynamic, dynamic>{};
    data['id'] = id;
    data['traccar_device_id'] = traccarDeviceId;
    data['icon_id'] = iconId;
    data['icon_colors'] = iconColors.toJson();
    data['active'] = active;
    data['deleted'] = deleted;
    data['name'] = name;
    data['imei'] = imei;
    // (trimmed for brevity) — keep your previous toJson if you need all fields serialized
    data['sensors'] = sensors?.map((e) => e.toJson()).toList();
    data['traccar'] = traccar.toJson();
    return data;
  }
}

class IconColors {
  IconColors({this.moving, this.stopped, this.offline, this.engine});
  dynamic moving;
  dynamic stopped;
  dynamic offline;
  dynamic engine;

  factory IconColors.fromJson(Map<dynamic, dynamic> json) => IconColors(
        moving: json['moving'],
        stopped: json['stopped'],
        offline: json['offline'],
        engine: json['engine'],
      );

  Map<dynamic, dynamic> toJson() => {
        'moving': moving,
        'stopped': stopped,
        'offline': offline,
        'engine': engine,
      };
}

class Sensors {
  Sensors({
    this.id,
    this.userId,
    this.deviceId,
    this.name,
    this.type,
    this.tagName,
    this.addToHistory,
    this.onValue,
    this.offValue,
    this.shownValueBy,
    this.fuelTankName,
    this.fullTank,
    this.fullTankValue,
    this.minValue,
    this.maxValue,
    this.formula,
    this.odometerValueBy,
    this.odometerValue,
    this.odometerValueUnit,
    this.temperatureMax,
    this.temperatureMaxValue,
    this.temperatureMin,
    this.temperatureMinValue,
    this.value,
    this.valueFormula,
    this.showInPopup,
    this.unitOfMeasurement,
    this.onTagValue,
    this.offTagValue,
    this.onType,
    this.offType,
    this.calibrations,
    this.skipCalibration,
    this.skipEmpty,
    this.decbin,
    this.hexbin,
  });

  dynamic id;
  dynamic userId;
  dynamic deviceId;
  dynamic name;
  dynamic type;
  dynamic tagName;
  dynamic addToHistory;
  dynamic onValue;
  dynamic offValue;
  dynamic shownValueBy;
  dynamic fuelTankName;
  dynamic fullTank;
  dynamic fullTankValue;
  dynamic minValue;
  dynamic maxValue;
  dynamic formula;
  dynamic odometerValueBy;
  dynamic odometerValue;
  dynamic odometerValueUnit;
  dynamic temperatureMax;
  dynamic temperatureMaxValue;
  dynamic temperatureMin;
  dynamic temperatureMinValue;
  dynamic value;
  dynamic valueFormula;
  dynamic showInPopup;
  dynamic unitOfMeasurement;
  dynamic onTagValue;
  dynamic offTagValue;
  dynamic onType;
  dynamic offType;
  dynamic calibrations;
  dynamic skipCalibration;
  dynamic skipEmpty;
  dynamic decbin;
  dynamic hexbin;

  factory Sensors.fromJson(Map<dynamic, dynamic> json) => Sensors(
        id: json['id'],
        userId: json['user_id'],
        deviceId: json['device_id'],
        name: json['name'],
        type: json['type'],
        tagName: json['tag_name'],
        addToHistory: json['add_to_history'],
        odometerValueUnit: json['odometer_value_unit'],
        value: json['value'],
        valueFormula: json['value_formula'],
        showInPopup: json['show_in_popup'],
        unitOfMeasurement: json['unit_of_measurement'],
      );

  Map<dynamic, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'device_id': deviceId,
        'name': name,
        'type': type,
        'tag_name': tagName,
        'add_to_history': addToHistory,
        'odometer_value_unit': odometerValueUnit,
        'value': value,
        'value_formula': valueFormula,
        'show_in_popup': showInPopup,
        'unit_of_measurement': unitOfMeasurement,
      };
}

class Traccar {
  Traccar({
    this.id,
    this.name,
    this.uniqueId,
    this.latestPositionId,
    this.lastValidLatitude,
    this.lastValidLongitude,
    this.other,
    this.speed,
    this.time,
    this.deviceTime,
    this.serverTime,
    this.ackTime,
    this.altitude,
    this.course,
    this.power,
    this.address,
    this.protocol,
    this.latestPositions,
    this.movedAt,
    this.stopedAt,
    this.engineOnAt,
    this.engineOffAt,
    this.engineChangedAt,
    this.databaseId,
  });

  dynamic id;
  dynamic name;
  dynamic uniqueId;
  dynamic latestPositionId;
  dynamic lastValidLatitude;
  dynamic lastValidLongitude;
  dynamic other;
  dynamic speed;
  dynamic time;
  dynamic deviceTime;
  dynamic serverTime;
  dynamic ackTime;
  dynamic altitude;
  dynamic course;
  dynamic power;
  dynamic address;
  dynamic protocol;
  dynamic latestPositions;
  dynamic movedAt;
  dynamic stopedAt;
  dynamic engineOnAt;
  dynamic engineOffAt;
  dynamic engineChangedAt;
  dynamic databaseId;

  factory Traccar.fromJson(Map<dynamic, dynamic> json) => Traccar(
        id: json['id'],
        name: json['name'],
        uniqueId: json['uniqueId'],
        latestPositionId: json['latestPosition_id'],
        lastValidLatitude: json['lastValidLatitude'],
        lastValidLongitude: json['lastValidLongitude'],
        other: json['other'],
        speed: json['speed'],
        time: json['time'],
        deviceTime: json['device_time'],
        serverTime: json['server_time'],
        ackTime: json['ack_time'],
        altitude: json['altitude'],
        course: json['course'],
        power: json['power'],
        address: json['address'],
        protocol: json['protocol'],
        latestPositions: json['latest_positions'],
        movedAt: json['moved_at'],
        stopedAt: json['stoped_at'],
        engineOnAt: json['engine_on_at'],
        engineOffAt: json['engine_off_at'],
        engineChangedAt: json['engine_changed_at'],
        databaseId: json['database_id'],
      );

  Map<dynamic, dynamic> toJson() => {
        'id': id,
        'name': name,
        'uniqueId': uniqueId,
        'latestPosition_id': latestPositionId,
        'lastValidLatitude': lastValidLatitude,
        'lastValidLongitude': lastValidLongitude,
        'other': other,
        'speed': speed,
        'time': time,
        'device_time': deviceTime,
        'server_time': serverTime,
        'ack_time': ackTime,
        'altitude': altitude,
        'course': course,
        'power': power,
        'address': address,
        'protocol': protocol,
        'latest_positions': latestPositions,
        'moved_at': movedAt,
        'stoped_at': stopedAt,
        'engine_on_at': engineOnAt,
        'engine_off_at': engineOffAt,
        'engine_changed_at': engineChangedAt,
        'database_id': databaseId,
      };
}

class ItemClass {
  ItemClass({this.id, this.value, this.title});
  dynamic id;
  dynamic value;
  dynamic title;

  factory ItemClass.fromJson(Map<dynamic, dynamic> json) => ItemClass(
        id: json['id'],
        value: json['value'],
        title: json['title'],
      );

  Map<dynamic, dynamic> toJson() => {'id': id, 'value': value, 'title': title};
}

class Images {
  Images({this.id, this.value, this.title});
  dynamic id;
  dynamic value;
  dynamic title;

  factory Images.fromJson(Map<dynamic, dynamic> json) => Images(
        id: json['id'],
        value: json['value'],
        title: json['title'],
      );

  Map<dynamic, dynamic> toJson() => {'id': id, 'value': value, 'title': title};
}
