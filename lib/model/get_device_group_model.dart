
import 'dart:convert';

GetDeviceGroupModel getDeviceGroupModelFromJson(String str) => GetDeviceGroupModel.fromJson(json.decode(str));

String getDeviceGroupModelToJson(GetDeviceGroupModel data) => json.encode(data.toJson());

class GetDeviceGroupModel {
  final int? status;
  final List<GetDeviceGroupModelItem>? items;

  GetDeviceGroupModel({
    this.status,
    this.items,
  });

  factory GetDeviceGroupModel.fromJson(Map<String, dynamic> json) => GetDeviceGroupModel(
    status: json["status"] as int?,
    items: json["items"] != null
        ? List<GetDeviceGroupModelItem>.from(json["items"].map((x) => GetDeviceGroupModelItem.fromJson(x)))
        : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "items": items != null ? List<dynamic>.from(items!.map((x) => x.toJson())) : null,
  };

  GetDeviceGroupModel copyWith({
    int? status,
    List<GetDeviceGroupModelItem>? items,
  }) => GetDeviceGroupModel(
    status: status ?? this.status,
    items: items ?? this.items,
  );
}

class GetDeviceGroupModelItem {
  final int? id;
  final String? title;
  final List<ItemItem>? items;

  GetDeviceGroupModelItem({
    this.id,
    this.title,
    this.items,
  });

  factory GetDeviceGroupModelItem.fromJson(Map<String, dynamic> json) => GetDeviceGroupModelItem(
    id: json["id"] as int?,
    title: json["title"] as String?,
    items: json["items"] != null
        ? List<ItemItem>.from(json["items"].map((x) => ItemItem.fromJson(x)))
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "items": items != null ? List<dynamic>.from(items!.map((x) => x.toJson())) : null,
  };
}

class ItemItem {
  final int? id;
  final String? name;

  ItemItem({
    this.id,
    this.name,
  });

  factory ItemItem.fromJson(Map<String, dynamic> json) => ItemItem(
    id: json["id"] as int?,
    name: json["name"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}