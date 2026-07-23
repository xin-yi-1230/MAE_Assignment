import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notice_model.dart';
import 'notif_item.dart';

class NotifPanel extends StatelessWidget {
  final VoidCallback onClose;
  // Changed from List<Map> to List<NoticeModel>
  final List<NoticeModel> notices;

  const NotifPanel({super.key, required this.onClose, required this.notices});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(fontSize: 12, color: AppColors.accent),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.textSub,
                  ),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // ── Empty state ──────────────────────
          if (notices.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 40,
                    color: AppColors.navInactive,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 13, color: AppColors.textSub),
                  ),
                ],
              ),
            )
          else
            // ── Notice items ─────────────────
            ...notices.map(
              (n) => NotifItem(
                icon: n.roleIcon,
                title: n.title,
                body: n.body,
                time: n.timeAgo,
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
