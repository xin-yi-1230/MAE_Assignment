import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice_model.dart';

class NoticeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<NoticeModel>> getNotices(String role) async {
    // Get notices targeted to this role OR 'all'
    final snap = await _db
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => NoticeModel.fromJson(d.id, d.data()))
        .where((n) => n.targetRole == 'all' || n.targetRole == role)
        .toList();
  }
}
