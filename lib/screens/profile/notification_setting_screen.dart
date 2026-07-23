import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Settings state
  bool _orderUpdates = true;
  bool _boothAlerts = true;
  bool _eventReminders = true;
  bool _newBooths = false;
  bool _promotions = false;
  bool _generalNotices = true;
  bool _pushEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textMain,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Master toggle ────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _pushEnabled
                    ? AppColors.accent.withValues(alpha: 0.08)
                    : AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _pushEnabled
                      ? AppColors.accent.withValues(alpha: 0.3)
                      : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _pushEnabled
                          ? AppColors.accent.withValues(alpha: 0.15)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      color: _pushEnabled
                          ? AppColors.accent
                          : AppColors.textSub,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Push Notifications',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          _pushEnabled
                              ? 'Notifications are enabled'
                              : 'All notifications disabled',
                          style: TextStyle(
                            fontSize: 12,
                            color: _pushEnabled
                                ? AppColors.tagGreen
                                : AppColors.textSub,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _pushEnabled,
                    onChanged: (val) => setState(() {
                      _pushEnabled = val;
                      // Disable all when master is off
                      if (!val) {
                        _orderUpdates = false;
                        _boothAlerts = false;
                        _eventReminders = false;
                        _newBooths = false;
                        _promotions = false;
                        _generalNotices = false;
                      }
                    }),
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ),

            // ── Order notifications ──────────────
            _sectionHeader('Orders'),
            _settingsCard(
              children: [
                _toggleTile(
                  icon: Icons.receipt_long_rounded,
                  iconColor: AppColors.accent,
                  title: 'Order Status Updates',
                  subtitle: 'Confirmed, Ready, Collected',
                  value: _orderUpdates,
                  onChanged: _pushEnabled
                      ? (val) => setState(() => _orderUpdates = val)
                      : null,
                ),
              ],
            ),

            // ── Booth notifications ──────────────
            _sectionHeader('Booths'),
            _settingsCard(
              children: [
                _toggleTile(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.orange,
                  title: 'Stock Alerts',
                  subtitle: 'Low stock and sold out items',
                  value: _boothAlerts,
                  onChanged: _pushEnabled
                      ? (val) => setState(() => _boothAlerts = val)
                      : null,
                ),
                const Divider(height: 1, color: AppColors.divider),
                _toggleTile(
                  icon: Icons.store_rounded,
                  iconColor: AppColors.tagGreen,
                  title: 'New Booths',
                  subtitle: 'When new booths join an event',
                  value: _newBooths,
                  onChanged: _pushEnabled
                      ? (val) => setState(() => _newBooths = val)
                      : null,
                ),
                const Divider(height: 1, color: AppColors.divider),
                _toggleTile(
                  icon: Icons.local_offer_rounded,
                  iconColor: Colors.purple,
                  title: 'Promotions & Deals',
                  subtitle: 'Special offers from booths',
                  value: _promotions,
                  onChanged: _pushEnabled
                      ? (val) => setState(() => _promotions = val)
                      : null,
                ),
              ],
            ),

            // ── Event notifications ──────────────
            _sectionHeader('Events'),
            _settingsCard(
              children: [
                _toggleTile(
                  icon: Icons.event_rounded,
                  iconColor: AppColors.accent,
                  title: 'Event Reminders',
                  subtitle: 'Upcoming events you registered for',
                  value: _eventReminders,
                  onChanged: _pushEnabled
                      ? (val) => setState(() => _eventReminders = val)
                      : null,
                ),
                const Divider(height: 1, color: AppColors.divider),
                _toggleTile(
                  icon: Icons.campaign_rounded,
                  iconColor: Colors.orange,
                  title: 'General Notices',
                  subtitle: 'Announcements from organisers',
                  value: _generalNotices,
                  onChanged: _pushEnabled
                      ? (val) => setState(() => _generalNotices = val)
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Save button ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _save(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    // TODO: persist to Firestore under users/{userId}/settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Notification settings saved'),
          ],
        ),
        backgroundColor: AppColors.tagGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSub,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    void Function(bool)? onChanged,
  }) {
    final disabled = onChanged == null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: disabled
                  ? AppColors.surface
                  : iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: disabled ? AppColors.navInactive : iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: disabled
                        ? AppColors.navInactive
                        : AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
