class NoticeModel {
  final String id;
  final String eventId;
  final String organiserId;
  final String title;
  final String body;
  final String targetRole;
  final String createdAt;

  NoticeModel({
    required this.id,
    required this.eventId,
    required this.organiserId,
    required this.title,
    required this.body,
    required this.targetRole,
    required this.createdAt,
  });

  // ── Formatting getters ────────────────────────

  // "30 May 2026"
  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  // "2 days ago" / "Just now" etc
  String get timeAgo {
    try {
      final dt = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return formattedDate;
    } catch (_) {
      return '';
    }
  }

  // Icon per target role
  String get roleIcon {
    switch (targetRole) {
      case 'student':
        return '🎓';
      case 'seller':
        return '🏪';
      default:
        return '📢';
    }
  }

  factory NoticeModel.fromJson(String id, Map<String, dynamic> json) {
    return NoticeModel(
      id: id,
      eventId: json['eventId'] ?? '',
      organiserId: json['organiserId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      targetRole: json['targetRole'] ?? 'all',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
