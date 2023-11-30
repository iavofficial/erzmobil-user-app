class Location {
  final double lat;
  final double lng;

  Location(this.lat, this.lng);

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(json['lat'] as double, json['lng'] as double);
  }

  factory Location.fromJsonDirectus(Map<String, dynamic> json) {
    return Location(
        json['coordinates'][1] as double, json['coordinates'][0] as double);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}
