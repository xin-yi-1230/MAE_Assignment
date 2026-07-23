import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/booth_model.dart';
import '../models/product_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all events
  Future<List<EventModel>> getAllEvents() async {
    final snap = await _db.collection('events').get();
    return snap.docs.map((d) => EventModel.fromJson(d.id, d.data())).toList();
  }

  // Get events by category
  Future<List<EventModel>> getEventsByCategory(String category) async {
    final snap = await _db
        .collection('events')
        .where('category', isEqualTo: category)
        .get();
    return snap.docs.map((d) => EventModel.fromJson(d.id, d.data())).toList();
  }

  // Get booths for a specific event
  Future<List<BoothModel>> getBoothsByEvent(String eventId) async {
    final snap = await _db
        .collection('booths')
        .where('eventId', isEqualTo: eventId)
        .get();
    return snap.docs.map((d) => BoothModel.fromJson(d.id, d.data())).toList();
  }

  // Get products for a specific booth
  Future<List<ProductModel>> getProductsByBooth(String boothId) async {
    final snap = await _db
        .collection('products')
        .where('boothId', isEqualTo: boothId)
        .get();
    return snap.docs.map((d) => ProductModel.fromJson(d.id, d.data())).toList();
  }
}
