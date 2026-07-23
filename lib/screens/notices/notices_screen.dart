import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/notice_viewmodel.dart';
import '../widgets/notice_card.dart';
import '../widgets/category_filter.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeViewModel>().loadNotices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NoticeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notices',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vm.filteredNotices.length} announcement${vm.filteredNotices.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSub,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Unread count badge
                  if (vm.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.campaign_outlined,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${vm.unreadCount}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Search bar ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) =>
                    context.read<NoticeViewModel>().onSearchChanged(val),
                decoration: InputDecoration(
                  hintText: 'Search announcements...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSub,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSub,
                    size: 20,
                  ),
                  suffixIcon: vm.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textSub,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<NoticeViewModel>().onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Filter chips ─────────────────────
            CategoryFilter(
              categories: vm.filters,
              selectedCategory: vm.selectedFilter,
              onSelected: (f) =>
                  context.read<NoticeViewModel>().onFilterChanged(f),
            ),
            const SizedBox(height: 12),

            // ── Sort row ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${vm.filteredNotices.length} result${vm.filteredNotices.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSub,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.sort_rounded,
                    size: 14,
                    color: AppColors.textSub,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Latest first',
                    style: TextStyle(fontSize: 12, color: AppColors.textSub),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Notice list ──────────────────────
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.errorMessage != null
                  ? _errorState(vm.errorMessage!)
                  : vm.filteredNotices.isEmpty
                  ? _emptyState()
                  : RefreshIndicator(
                      color: AppColors.accent,
                      onRefresh: () =>
                          context.read<NoticeViewModel>().loadNotices(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: vm.filteredNotices.length,
                        itemBuilder: (context, i) =>
                            NoticeCard(notice: vm.filteredNotices[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 64,
            color: AppColors.navInactive.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notices found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check back later for announcements',
            style: TextStyle(fontSize: 13, color: AppColors.textSub),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 64,
            color: AppColors.textSub,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 13, color: AppColors.textSub),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<NoticeViewModel>().loadNotices(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
