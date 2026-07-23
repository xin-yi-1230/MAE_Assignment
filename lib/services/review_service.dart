import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Submit a review
  Future<void> submitReview({
    required String userId,
    required String boothId,
    required String eventId,
    required int stars,
    required String comment,
  }) async {
    // Save review document
    await _db.collection('reviews').add({
      'userId':    userId,
      'boothId':   boothId,
      'eventId':   eventId,
      'stars':     stars,
      'comment':   comment,
      'createdAt': DateTime.now().toString(),
    });

    // Update booth average rating
    await _updateBoothRating(boothId, stars);
  }

  // Recalculate booth rating after new review
  Future<void> _updateBoothRating(
      String boothId, int newStars) async {
    final boothRef = _db.collection('booths').doc(boothId);
    final boothDoc = await boothRef.get();
    final data     = boothDoc.data()!;

    final currentRating  = (data['rating'] as num).toDouble();
    final totalRatings   = (data['totalRatings'] as int);
    final newTotalRatings = totalRatings + 1;
    final newAvgRating   =
        ((currentRating * totalRatings) + newStars) /
            newTotalRatings;

    await boothRef.update({
      'rating':       double.parse(
          newAvgRating.toStringAsFixed(1)),
      'totalRatings': newTotalRatings,
    });
  }
}