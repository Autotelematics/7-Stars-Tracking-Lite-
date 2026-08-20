class ReportTypeModel {
  final int? status;
  final List<Items>? items;
  const ReportTypeModel({this.status, this.items});
  ReportTypeModel copyWith({int? status, List<Items>? items}) {
    return ReportTypeModel(
        status: status ?? this.status, items: items ?? this.items);
  }

  Map<String, Object?> toJson() {
    return {
      'status': status,
      'items':
          items?.map<Map<String, dynamic>>((data) => data.toJson()).toList()
    };
  }

  static ReportTypeModel fromJson(Map<String, Object?> json) {
    return ReportTypeModel(
        status: json['status'] == null ? null : json['status'] as int,
        items: json['items'] == null
            ? null
            : (json['items'] as List)
                .map<Items>(
                    (data) => Items.fromJson(data as Map<String, Object?>))
                .toList());
  }

  @override
  String toString() {
    return '''ReportTypeModel(
                status:$status,
items:${items.toString()}
    ) ''';
  }

  @override
  bool operator ==(Object other) {
    return other is ReportTypeModel &&
        other.runtimeType == runtimeType &&
        other.status == status &&
        other.items == items;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, status, items);
  }
}

class Items {
  final int? type;
  final String? name;
  final List<dynamic>? formats;
  final List<dynamic>? fields;
  const Items({this.type, this.name, this.formats, this.fields});
  Items copyWith(
      {int? type,
      String? name,
      List<dynamic>? formats,
      List<dynamic>? fields}) {
    return Items(
        type: type ?? this.type,
        name: name ?? this.name,
        formats: formats ?? this.formats,
        fields: fields ?? this.fields);
  }

  Map<String, Object?> toJson() {
    return {'type': type, 'name': name, 'formats': formats, 'fields': fields};
  }

  static Items fromJson(Map<String, Object?> json) {
    return Items(
        type: json['type'] == null
            ? null
            : int.tryParse(json['type'].toString()),
        name: json['name'] == null ? null : json['name'] as String,
        formats:
            json['formats'] == null ? null : json['formats'] as List<dynamic>,
        fields:
            json['fields'] == null ? null : json['fields'] as List<dynamic>);
  }

  @override
  String toString() {
    return '''Items(
                type:$type,
name:$name,
formats:$formats,
fields:$fields
    ) ''';
  }

  @override
  bool operator ==(Object other) {
    return other is Items &&
        other.runtimeType == runtimeType &&
        other.type == type &&
        other.name == name &&
        other.formats == formats &&
        other.fields == fields;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, type, name, formats, fields);
  }
}
