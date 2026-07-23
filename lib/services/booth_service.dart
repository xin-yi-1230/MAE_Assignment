import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booth_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

class BoothService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all booths for a specific event
  Future<List<BoothModel>> getBoothsByEvent(String eventId) async {
    final snap = await _db
        .collection('booths')
        .where('eventId', isEqualTo: eventId)
        .get();
    return snap.docs.map((d) => BoothModel.fromJson(d.id, d.data())).toList();
  }

  // Get single booth by ID
  Future<BoothModel?> getBoothById(String boothId) async {
    final doc = await _db.collection('booths').doc(boothId).get();
    if (!doc.exists) return null;
    return BoothModel.fromJson(doc.id, doc.data()!);
  }

  // Get products for a specific booth
  Future<List<ProductModel>> getProductsByBooth(String boothId) async {
    final snap = await _db
        .collection('products')
        .where('boothId', isEqualTo: boothId)
        .get();
    return snap.docs.map((d) => ProductModel.fromJson(d.id, d.data())).toList();
  }

  // Get reviews for a specific booth
  Future<List<ReviewModel>> getReviewsByBooth(String boothId) async {
    final snap = await _db
        .collection('reviews')
        .where('boothId', isEqualTo: boothId)
        .get();
    return snap.docs.map((d) => ReviewModel.fromJson(d.id, d.data())).toList();
  }
}
