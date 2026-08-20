import 'dart:convert';
import 'dart:developer';

GetDevicesListModel getDevicesListModelFromJson(String str) =>
    GetDevicesListModel.fromJson(json.decode(str));

String getDevicesListModelToJson(GetDevicesListModel data) =>
    json.encode(data.toJson());

class GetDevicesListModel {
  final int? status;
  final List<Item>? items;

  GetDevicesListModel({
    this.status,
    this.items,
  });

  factory GetDevicesListModel.fromJson(Map<String, dynamic> json) {
    // log("Parsing GetDevicesListModel: ${json.keys}");
    return GetDevicesListModel(
      status: json["status"] as int?,
      items: json["items"] != null && json["items"] is List
          ? List<Item>.from((json["items"] as List<dynamic>).map((x) {
              if (x is Map<String, dynamic>) {
                return Item.fromJson(x);
              } else {
                log("Invalid item type: ${x.runtimeType}");
                throw Exception(
                    'Expected Map<String, dynamic> for item, got ${x.runtimeType}');
              }
            }))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "items": items != null
            ? List<dynamic>.from(items!.map((x) => x.toJson()))
            : null,
      };
}

class Item {
  final int? id;
  final String? name;
  final String? vehicleType;
  final String? online;
  final String? time;
  final int? timestamp;
  final int? acktimestamp;
  final dynamic lat;
  final dynamic lng;
  final String? addr;
  final int? course;
  final int? speed;
  final String? path;
  final List<Sensor>? sensors;
  final String? stopDuration;
  final DateTime? movedAt;
  final Param? param;

  Item({
    this.id,
    this.name,
    this.vehicleType,
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
    this.param,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    log("Parsing Item ID: ${json["id"]}");
    return Item(
      id: json["id"] as int?,
      name: json["name"] as String?,
      vehicleType: json["vehicle_type"] as String?,
      online: json["online"] as String?,
      time: json["time"] as String?,
      timestamp: json["timestamp"] as int?,
      acktimestamp: json["acktimestamp"] as int?,
      lat: json["lat"],
      lng: json["lng"],
      addr: json["addr"] as String?,
      course: json["course"] as int?,
      speed: json["speed"] as int?,
      path: json["path"] as String?,
      sensors: json["sensors"] != null && json["sensors"] is List
          ? List<Sensor>.from((json["sensors"] as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map((x) {
              return Sensor.fromJson(x);
            }))
          : null,
      stopDuration: json["stop_duration"] as String?,
      movedAt: json["moved_at"] != null
          ? DateTime.tryParse(json["moved_at"] as String)
          : null,
      param: json["param"] != null && json["param"] is Map<String, dynamic>
          ? Param.fromJson(json["param"] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "vehicle_type": vehicleType,
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
        "param": param?.toJson(),
      };
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

class Param {
  final String? status;
  final String? ignition;
  final String? charge;
  final String? blocked;
  final String? batterylevel;
  final String? rssi;
  final String? sequence;
  final String? distance;
  final String? totaldistance;
  final String? motion;
  final String? valid;
  final String? enginehours;
  final String? power;
  final String? adc1;
  final String? iccid;
  final String? mcc;
  final String? mnc;
  final String? lac;
  final String? cid;
  final String? event;
  final String? archive;
  final String? odometer;
  final String? sat;
  final String? priority;
  final String? workmode;
  final String? gpsstatus;
  final String? di1;
  final String? out1;
  final String? io251;
  final String? io246;
  final String? io252;
  final String? io249;
  final String? pdop;
  final String? hdop;
  final String? battery;
  final String? io68;
  final String? axisx;
  final String? axisy;
  final String? axisz;
  final String? operator;
  final String? io199;
  final String? io16;
  final String? io12;
  final String? combinedfuel;
  final Map<String, dynamic>? extraParams; // For any unforeseen fields

  Param({
    this.status,
    this.ignition,
    this.charge,
    this.blocked,
    this.batterylevel,
    this.rssi,
    this.sequence,
    this.distance,
    this.totaldistance,
    this.motion,
    this.valid,
    this.enginehours,
    this.power,
    this.adc1,
    this.iccid,
    this.mcc,
    this.mnc,
    this.lac,
    this.cid,
    this.event,
    this.archive,
    this.odometer,
    this.sat,
    this.priority,
    this.workmode,
    this.gpsstatus,
    this.di1,
    this.out1,
    this.io251,
    this.io246,
    this.io252,
    this.io249,
    this.pdop,
    this.hdop,
    this.battery,
    this.io68,
    this.axisx,
    this.axisy,
    this.axisz,
    this.operator,
    this.io199,
    this.io16,
    this.io12,
    this.combinedfuel,
    this.extraParams,
  });

  factory Param.fromJson(Map<String, dynamic> json) => Param(
        status: json["status"] as String?,
        ignition: json["ignition"] as String?,
        charge: json["charge"] as String?,
        blocked: json["blocked"] as String?,
        batterylevel: json["batterylevel"] as String?,
        rssi: json["rssi"] as String?,
        sequence: json["sequence"] as String?,
        distance: json["distance"] as String?,
        totaldistance: json["totaldistance"] as String?,
        motion: json["motion"] as String?,
        valid: json["valid"] as String?,
        enginehours: json["enginehours"] as String?,
        power: json["power"] as String?,
        adc1: json["adc1"] as String?,
        iccid: json["iccid"] as String?,
        mcc: json["mcc"] as String?,
        mnc: json["mnc"] as String?,
        lac: json["lac"] as String?,
        cid: json["cid"] as String?,
        event: json["event"] as String?,
        archive: json["archive"] as String?,
        odometer: json["odometer"] as String?,
        sat: json["sat"] as String?,
        priority: json["priority"] as String?,
        workmode: json["workmode"] as String?,
        gpsstatus: json["gpsstatus"] as String?,
        di1: json["di1"] as String?,
        out1: json["out1"] as String?,
        io251: json["io251"] as String?,
        io246: json["io246"] as String?,
        io252: json["io252"] as String?,
        io249: json["io249"] as String?,
        pdop: json["pdop"] as String?,
        hdop: json["hdop"] as String?,
        battery: json["battery"] as String?,
        io68: json["io68"] as String?,
        axisx: json["axisx"] as String?,
        axisy: json["axisy"] as String?,
        axisz: json["axisz"] as String?,
        operator: json["operator"] as String?,
        io199: json["io199"] as String?,
        io16: json["io16"] as String?,
        io12: json["io12"] as String?,
        combinedfuel: json["combinedfuel"] as String?,
        extraParams: json
          ..removeWhere((key, value) => [
                "status",
                "ignition",
                "charge",
                "blocked",
                "batterylevel",
                "rssi",
                "sequence",
                "distance",
                "totaldistance",
                "motion",
                "valid",
                "enginehours",
                "power",
                "adc1",
                "iccid",
                "mcc",
                "mnc",
                "lac",
                "cid",
                "event",
                "archive",
                "odometer",
                "sat",
                "priority",
                "workmode",
                "gpsstatus",
                "di1",
                "out1",
                "io251",
                "io246",
                "io252",
                "io249",
                "pdop",
                "hdop",
                "battery",
                "io68",
                "axisx",
                "axisy",
                "axisz",
                "operator",
                "io199",
                "io16",
                "io12",
                "combinedfuel",
              ].contains(key)),
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "status": status,
      "ignition": ignition,
      "charge": charge,
      "blocked": blocked,
      "batterylevel": batterylevel,
      "rssi": rssi,
      "sequence": sequence,
      "distance": distance,
      "totaldistance": totaldistance,
      "motion": motion,
      "valid": valid,
      "enginehours": enginehours,
      "power": power,
      "adc1": adc1,
      "iccid": iccid,
      "mcc": mcc,
      "mnc": mnc,
      "lac": lac,
      "cid": cid,
      "event": event,
      "archive": archive,
      "odometer": odometer,
      "sat": sat,
      "priority": priority,
      "workmode": workmode,
      "gpsstatus": gpsstatus,
      "di1": di1,
      "out1": out1,
      "io251": io251,
      "io246": io246,
      "io252": io252,
      "io249": io249,
      "pdop": pdop,
      "hdop": hdop,
      "battery": battery,
      "io68": io68,
      "axisx": axisx,
      "axisy": axisy,
      "axisz": axisz,
      "operator": operator,
      "io199": io199,
      "io16": io16,
      "io12": io12,
      "combinedfuel": combinedfuel,
    };
    if (extraParams != null) {
      map.addAll(extraParams!);
    }
    return map;
  }
}
