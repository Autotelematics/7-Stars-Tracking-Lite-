class DeviceCommandsListsModel {
  String? type;
  String? title;
  List<Attributes>? attributes;

  DeviceCommandsListsModel({this.type, this.title, this.attributes});

  DeviceCommandsListsModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    title = json['title'];
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      json['attributes'].forEach((v) {
        attributes!.add(Attributes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['title'] = title;
    if (attributes != null) {
      data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attributes {
  String? title;
  String? name;
  String? type;
  String? validation;
  String? description;
  String? realCommand;

  Attributes(
      {this.title, this.name, this.type, this.validation, this.description});

  Attributes.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    name = json['name'];
    type = json['type'];
    validation = json['validation'];
    description = json['description'];
    realCommand = json['default'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['name'] = name;
    data['type'] = type;
    data['validation'] = validation;
    data['description'] = description;
    return data;
  }
}
