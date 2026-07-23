class BoothModel {
  final String id;
  final String eventId;
  final String sellerId;
  final String name;
  final String description;
  final String category;
  final String location;
  final String imageUrl;
  final double rating;
  final int totalRatings;
  final String status;

  BoothModel({
    required this.id,
    required this.eventId,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.totalRatings,
    required this.status,
  });

  factory BoothModel.fromJson(String id, Map<String, dynamic> json) {
    return BoothModel(
      id: id,
      eventId: json['eventId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] as num).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}
