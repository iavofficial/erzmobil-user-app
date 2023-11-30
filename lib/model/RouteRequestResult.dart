class RouteRequestResult {
  final bool result;
  final int reasonCode;
  final String reasonText;
  final List<DateTime>? alternativeTimes;
  final List<DateTime>? timeSlot;

  RouteRequestResult(this.result, this.reasonCode, this.reasonText,
      this.alternativeTimes, this.timeSlot);

  factory RouteRequestResult.fromJson(Map<String, dynamic> json) {
    return RouteRequestResult(
        json['result'] as bool,
        json['reasonCode'] as int,
        json['reasonText'],
        json['alternativeTimes'] != null
            ? getTimes(json['alternativeTimes'].cast<String>())
            : getTimes(null),
        json['timeSlot'] != null
            ? getTimes(json['timeSlot'].cast<String>())
            : getTimes(null));
  }

  static List<DateTime>? getTimes(List<String>? times) {
    List<DateTime> dateTimes = [];
    if (times != null && times.isNotEmpty) {
      times.forEach((element) {
        dateTimes.add(DateTime.parse(element));
      });
    }
    return dateTimes;
  }
}
