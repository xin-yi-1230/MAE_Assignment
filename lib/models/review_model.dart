class ReviewModel {
  final String id;
  final String userId;
  final String boothId;
  final String eventId;
  final int stars;
  final String comment;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.boothId,
    required this.eventId,
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(String id, Map<String, dynamic> json) {
    return ReviewModel(
      id: id,
      userId: json['userId'] ?? '',
      boothId: json['boothId'] ?? '',
      eventId: json['eventId'] ?? '',
      stars: json['stars'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'userId':    userId,
    'boothId':   boothId,
    'eventId':   eventId,
    'stars':     stars,
    'comment':   comment,
    'createdAt': createdAt,
  };
}
