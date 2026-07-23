class RegistrationModel {
  final String id;
  final String userId;
  final String eventId;
  final String registeredAt;
  final String status;
  final String ticketQr;

  RegistrationModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.registeredAt,
    required this.status,
    required this.ticketQr,
  });

  factory RegistrationModel.fromJson(String id, Map<String, dynamic> json) {
    return RegistrationModel(
      id: id,
      userId: json['userId'] ?? '',
      eventId: json['eventId'] ?? '',
      registeredAt: json['registeredAt'] ?? '',
      status: json['status'] ?? '',
      ticketQr: json['ticketQr'] ?? '',
    );
  }
}
