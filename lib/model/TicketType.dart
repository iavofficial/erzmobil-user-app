class TicketType {
  final String name;

  const TicketType(this.name);

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(json['Name']);
  }
}
