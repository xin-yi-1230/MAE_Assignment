import 'package:flutter/material.dart';
import 'package:flutter_application_assignment/viewmodels/dashboard_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/event_model.dart';
import '../../viewmodels/event_detail_viewmodel.dart';
import 'booth_list_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventDetailViewModel>().checkRegistration(widget.event.id);
    });
  }

  Color get _statusColor {
    switch (widget.event.status) {
      case 'Ongoing':
        return AppColors.tagGreen;
      case 'Upcoming':
        return AppColors.accent;
      case 'Completed':
        return AppColors.textSub;
      default:
        return AppColors.textSub;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventDetailViewModel>();

    // Show success snackbar when registered
    if (vm.registerSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Successfully registered!'),
              ],
            ),
            backgroundColor: AppColors.tagGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar with image ─────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.cardBg,
            foregroundColor: AppColors.textMain,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.event.imageUrl.isNotEmpty
                  ? Image.network(widget.event.imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.event_rounded,
                        size: 80,
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
            ),
          ),

          // ── Content ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Badges ───────────────────
                  Row(
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.event.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Registered badge
                      if (vm.isRegistered)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.tagGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 12,
                                color: AppColors.tagGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Registered',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.tagGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Event name ───────────────
                  Text(
                    widget.event.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Info rows ────────────────
                  _infoRow(
                    Icons.calendar_today_outlined,
                    '${widget.event.formattedDate}  •  ${widget.event.formattedTimeRange}',
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.location_on_outlined, widget.event.location),
                  const SizedBox(height: 8),
                  _infoRow(
                    Icons.store_outlined,
                    '${widget.event.boothCount} Booths',
                  ),
                  const SizedBox(height: 20),

                  // ── About ────────────────────
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSub,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Action buttons ────────────
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Browse Booths button
                  _actionButton(
                    icon: Icons.store_rounded,
                    label: 'Browse Booths',
                    color: AppColors.accent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BoothListScreen(event: widget.event),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // View on Map button
                  _actionButton(
                    icon: Icons.map_outlined,
                    label: 'View on Map',
                    color: AppColors.tagGreen,
                    onTap: () {
                      // TODO: open map screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Location: ${widget.event.location}'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // ── Register button ───────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: vm.isRegistered
                        // Already registered
                        ? OutlinedButton.icon(
                            onPressed: null,
                            icon: Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.tagGreen,
                            ),
                            label: Text(
                              'You are registered',
                              style: TextStyle(
                                color: AppColors.tagGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.tagGreen),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          )
                        // Not yet registered
                        : ElevatedButton(
                            onPressed: vm.isLoading
                                ? null
                                : () async {
                                    await context
                                        .read<EventDetailViewModel>()
                                        .registerForEvent(widget.event.id);

                                    if (context.mounted) {
                                      await context
                                          .read<DashboardViewModel>()
                                          .loadDashboardData();
                                      // ...
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: vm.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Register for this Event',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info row helper ───────────────────────────
  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSub),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textSub),
          ),
        ),
      ],
    );
  }

  // ── Action button helper ──────────────────────
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
