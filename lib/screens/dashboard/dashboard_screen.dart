import 'package:flutter_application_assignment/viewmodels/notice_viewmodel.dart';
import 'package:flutter_application_assignment/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../widgets/section_card.dart';
import '../widgets/event_tile.dart';
import '../widgets/order_tile.dart';
import '../widgets/tap_widget.dart';
import '../widgets/notif_panel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _showAllEvents = false;
  bool _showAllOrders = false;
  bool _showNotifPanel = false;

  late final AnimationController _notifAnimController;
  late final Animation<Offset> _notifSlideAnim;
  late final Animation<double> _notifFadeAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardData();
      context.read<NoticeViewModel>().loadNotices();
    });

    _notifAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _notifSlideAnim =
        Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _notifAnimController, curve: Curves.easeOut),
        );
    _notifFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _notifAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _notifAnimController.dispose();
    super.dispose();
  }

  void _toggleNotifPanel() {
    setState(() => _showNotifPanel = !_showNotifPanel);
    _showNotifPanel
        ? _notifAnimController.forward()
        : _notifAnimController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final notifVm = context.watch<NoticeViewModel>(); // ← add

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          SafeArea(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        // Pass notifVm to app bar
                        child: _buildAppBar(vm, notifVm),
                      ),
                      SliverToBoxAdapter(child: _buildGreeting()),

                      // Events card
                      SliverToBoxAdapter(
                        child: SectionCard(
                          title: AppStrings.registeredEvents,
                          trailing: _seeAllButton(
                            isExpanded: _showAllEvents,
                            onTap: () => setState(
                              () => _showAllEvents = !_showAllEvents,
                            ),
                          ),
                          child: vm.events.isEmpty
                              ? _emptyState(AppStrings.noEvents)
                              : Column(
                                  children:
                                      (_showAllEvents
                                              ? vm.events
                                              : vm.events.take(2).toList())
                                          .map((e) => EventTile(event: e))
                                          .toList(),
                                ),
                        ),
                      ),

                      // Orders card
                      SliverToBoxAdapter(
                        child: SectionCard(
                          title: AppStrings.ordered,
                          trailing: _seeAllButton(
                            isExpanded: _showAllOrders,
                            onTap: () => setState(
                              () => _showAllOrders = !_showAllOrders,
                            ),
                          ),
                          child: vm.orders.isEmpty
                              ? _emptyState(AppStrings.noOrders)
                              : Column(
                                  children:
                                      (_showAllOrders
                                              ? vm.orders
                                              : vm.orders.take(2).toList())
                                          .map((o) => OrderTile(order: o))
                                          .toList(),
                                ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
          ),

          // ── Notification overlay ──────────────
          if (_showNotifPanel) ...[
            GestureDetector(
              onTap: _toggleNotifPanel,
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: FadeTransition(
                  opacity: _notifFadeAnim,
                  child: SlideTransition(
                    position: _notifSlideAnim,
                    child: NotifPanel(
                      onClose: _toggleNotifPanel,
                      notices: notifVm
                          .filteredNotices // ← real data
                          .take(5)
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────
  Widget _buildAppBar(DashboardViewModel vm, NoticeViewModel notifVm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // ── Avatar — taps to Profile ──────────
          TapWidget(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            builder: (pressed) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: pressed
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: pressed ? AppColors.accent : Colors.transparent,
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
          ),
          const SizedBox(width: 10),

          // ── Username — also taps to Profile ───
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Text(
              vm.username,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textMain,
              ),
            ),
          ),
          const Spacer(),

          // ── Bell with real count ───────────────
          Stack(
            children: [
              TapWidget(
                onTap: _toggleNotifPanel,
                builder: (pressed) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _showNotifPanel || pressed
                        ? AppColors.accent.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    _showNotifPanel
                        ? Icons.notifications_rounded
                        : Icons.notifications_none_rounded,
                    size: 26,
                    color: _showNotifPanel
                        ? AppColors.accent
                        : AppColors.textMain,
                  ),
                ),
              ),

              // Badge — shows real count
              if (notifVm.unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.badge,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      notifVm.unreadCount > 9 ? '9+' : '${notifVm.unreadCount}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Greeting ──────────────────────────────────
  Widget _buildGreeting() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dashboard,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 2),
          Text(
            AppStrings.welcomeBack,
            style: TextStyle(fontSize: 13, color: AppColors.textSub),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── See All button ────────────────────────────
  Widget _seeAllButton({
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return TapWidget(
      onTap: onTap,
      builder: (pressed) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: pressed
              ? AppColors.accent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isExpanded ? 'See less' : AppStrings.seeAll,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          msg,
          style: const TextStyle(color: AppColors.textSub, fontSize: 13),
        ),
      ),
    );
  }
}
