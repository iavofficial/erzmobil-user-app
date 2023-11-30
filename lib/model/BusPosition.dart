import 'package:erzmobil/model/Location.dart';

class BusPosition {
  final int? id;
  final Location? position;
  final String? updatedAt;

  const BusPosition(this.id, this.position, this.updatedAt);

  factory BusPosition.fromJson(Map<String, dynamic> json) {
    return BusPosition(
        json['id'] as int,
        json['position'] != null
            ? new Location.fromJson(json['position'])
            : null,
        json['updatedAt']);
  }

  factory BusPosition.fromJsonDirectus(Map<String, dynamic> json) {
    return BusPosition(
        json['id'] as int,
        json['last_position'] != null
            ? new Location.fromJsonDirectus(json['last_position'])
            : null,
        json['last_position_updated_at']);
  }
}
