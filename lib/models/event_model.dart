import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String location;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String imageUrl;
  final int boothCount;
  final String organiserId;
  final String status;
  final bool isRegistered; // computed in viewmodel, not from Firestore

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    required this.startDateTime,
    required this.endDateTime,
    required this.imageUrl,
    required this.boothCount,
    required this.organiserId,
    required this.status,
    this.isRegistered = false,
  });

  // ── Formatting getters ────────────────────────

  // "1 June 2026"
  String get formattedDate => DateFormat('d MMMM yyyy').format(startDateTime);

  // "10:00 AM - 6:00 PM"
  String get formattedTimeRange {
    final start = DateFormat('h:mm a').format(startDateTime);
    final end = DateFormat('h:mm a').format(endDateTime);
    return '$start - $end';
  }

  // "1 June 2026  •  10:00 AM - 6:00 PM"
  String get formattedSchedule => '$formattedDate  •  $formattedTimeRange';

  factory EventModel.fromJson(String id, Map<String, dynamic> json) {
    // Helper to safely parse either a Timestamp, a String, or null
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now(); // Fallback if null or empty
    }

    return EventModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      startDateTime: parseDateTime(json['startDateTime']),
      endDateTime: parseDateTime(json['endDateTime']),
      imageUrl: json['imageUrl'] ?? '',
      boothCount: json['boothCount'] ?? 0,
      organiserId: json['organiserId'] ?? '',
      status: json['status'] ?? '',
    );
  }

  // copyWith lets viewmodel add isRegistered without touching Firestore
  EventModel copyWith({bool? isRegistered}) {
    return EventModel(
      id: id,
      name: name,
      description: description,
      category: category,
      location: location,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      imageUrl: imageUrl,
      boothCount: boothCount,
      organiserId: organiserId,
      status: status,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
