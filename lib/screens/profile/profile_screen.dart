import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_assignment/screens/profile/change_password_screen.dart';
import 'package:flutter_application_assignment/screens/profile/edit_profile_screen.dart';
import 'package:flutter_application_assignment/screens/profile/notification_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/dashboard_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textMain,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Profile header ───────────────────
            Container(
              width: double.infinity,
              color: AppColors.cardBg,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: vm.photoUrl.isNotEmpty
                          ? Image.network(
                              vm.photoUrl,
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                              // Fallback icon if the network image fails to load
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.textSub,
                                size: 24,
                              ),
                            )
                          : const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.textSub,
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name
                  Text(
                    vm.username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vm.role,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Stats row ────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
              child: Row(
                children: [
                  _statItem(
                    '${vm.events.length}',
                    'Events',
                    Icons.event_rounded,
                  ),
                  _divider(),
                  _statItem(
                    '${vm.orders.length}',
                    'Orders',
                    Icons.receipt_long_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Info section ─────────────────────
            _sectionCard(
              children: [
                _infoTile(
                  Icons.person_outline_rounded,
                  'Username',
                  vm.username,
                ),
                const Divider(height: 1, color: AppColors.divider),
                _infoTile(Icons.email_outlined, 'Email', vm.email),
                const Divider(height: 1, color: AppColors.divider),
                _infoTile(Icons.school_outlined, 'Role', vm.role),
                const Divider(height: 1, color: AppColors.divider),
                _infoTile(Icons.badge_outlined, 'Student ID', vm.studentID),
              ],
            ),
            const SizedBox(height: 12),

            // ── Account actions ──────────────────
            _sectionCard(
              children: [
                _actionTile(
                  Icons.edit_outlined,
                  'Edit Profile',
                  AppColors.accent,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.divider),
                _actionTile(
                  Icons.lock_outline_rounded,
                  'Change Password',
                  AppColors.accent,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.divider),
                _actionTile(
                  Icons.notifications_outlined,
                  'Notification Settings',
                  AppColors.accent,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Logout ───────────────────────────
            _sectionCard(
              children: [
                _actionTile(
                  Icons.logout_rounded,
                  'Log Out',
                  AppColors.badge,
                  () {
                    // TODO: wire to AuthViewModel.logout()
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'Log Out',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'Are you sure you want to log out?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.textSub),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              // 1. Close the dialog pop-up
                              Navigator.of(context, rootNavigator: true).pop();
                              // 2. Sign out from Firebase Authentication
                              await FirebaseAuth.instance.signOut();
                            },
                            child: const Text(
                              'Log Out',
                              style: TextStyle(color: AppColors.badge),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSub),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: AppColors.divider);
  }

  Widget _sectionCard({required List<Widget> children}) {
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

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSub),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textSub),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 20, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: color.withValues(alpha: 0.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
