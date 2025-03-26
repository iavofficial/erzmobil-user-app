import 'package:erzmobil/model/VehicleType.dart';

class Bus {
  final int busId;
  final String? licenseplate;
  final VehicleType vehicletype;

  Bus(this.busId, this.licenseplate, this.vehicletype);

  factory Bus.fromJsonDirectus(Map<String, dynamic> json) {
    return Bus(json['id'] as int, json['licensePlate'] as String,
        json['vehicletype'] as VehicleType);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.busId;
    data['licensePlate'] = this.licenseplate;
    data['vehicletype'] = this.vehicletype;

    return data;
  }
}
