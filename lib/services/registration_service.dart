import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/registration_model.dart';

class RegistrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Check if user is registered for an event
  Future<bool> isRegistered(String userId, String eventId) async {
    final snap = await _db
        .collection('registrations')
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'Approved')
        .get();
    return snap.docs.isNotEmpty;
  }

  // Register user for an event
  Future<void> registerForEvent(String userId, String eventId) async {
    await _db.collection('registrations').add({
      'userId': userId,
      'eventId': eventId,
      'registeredAt': DateTime.now().toString(),
      'status': 'Approved',
      'ticketQr': 'REG_${userId}_${eventId}',
    });
  }
}
