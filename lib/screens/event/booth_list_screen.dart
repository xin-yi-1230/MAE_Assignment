import 'package:flutter_application_assignment/models/booth_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/event_model.dart';
import '../../viewmodels/booth_viewmodel.dart';
import '../widgets/booth_card.dart';
import '../widgets/category_filter.dart';
import '../booth/booth_detail_screen.dart';

class BoothListScreen extends StatefulWidget {
  final EventModel event;
  const BoothListScreen({super.key, required this.event});

  @override
  State<BoothListScreen> createState() => _BoothListScreenState();
}

class _BoothListScreenState extends State<BoothListScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _sortBy = 'Default';

  final List<String> _sortOptions = [
    'Default',
    'Rating: High to Low',
    'Rating: Low to High',
    'Name: A to Z',
    'Status: Available First',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BoothViewModel>().loadBooths(widget.event.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BoothModel> _sortBooths(List<BoothModel> booths) {
    final list = List<BoothModel>.from(booths);
    switch (_sortBy) {
      case 'Rating: High to Low':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Rating: Low to High':
        list.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'Name: A to Z':
        list.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case 'Status: Available First':
        const order = {'Available': 0, 'Low': 1, 'Sold Out': 2};
        list.sort(
          (a, b) => (order[a.status] ?? 3).compareTo(order[b.status] ?? 3),
        );
        break;
      default:
        break;
    }
    return list;
  }

  @override
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BoothViewModel>();
    final sorted = _sortBooths(vm.filteredBooths);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          widget.event.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textMain,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ── Header ──────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Browse Booths',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${sorted.length} booth${sorted.length != 1 ? 's' : ''} available',
              style: const TextStyle(fontSize: 13, color: AppColors.textSub),
            ),
          ),
          const SizedBox(height: 16),

          // ── Search bar ───────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  context.read<BoothViewModel>().onSearchChanged(val),
              decoration: InputDecoration(
                hintText: 'Search booths...',
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
                          context.read<BoothViewModel>().onSearchChanged('');
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

          // ── Category filter ──────────────────
          CategoryFilter(
            categories: vm.categories,
            selectedCategory: vm.selectedCategory,
            onSelected: (cat) =>
                context.read<BoothViewModel>().onCategorySelected(cat),
          ),
          const SizedBox(height: 8),

          // ── Sort row ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${sorted.length} result${sorted.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSub,
                  ),
                ),
                const Spacer(),
                // Sort button
                GestureDetector(
                  onTap: () => _showSortSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _sortBy != 'Default'
                          ? AppColors.accent.withValues(alpha: 0.1)
                          : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _sortBy != 'Default'
                            ? AppColors.accent
                            : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          size: 14,
                          color: _sortBy != 'Default'
                              ? AppColors.accent
                              : AppColors.textSub,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _sortBy == 'Default' ? 'Sort' : _sortBy,
                          style: TextStyle(
                            fontSize: 12,
                            color: _sortBy != 'Default'
                                ? AppColors.accent
                                : AppColors.textSub,
                            fontWeight: _sortBy != 'Default'
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 14,
                          color: _sortBy != 'Default'
                              ? AppColors.accent
                              : AppColors.textSub,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Booth list ───────────────────────
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                ? _errorState(vm.errorMessage!)
                : sorted.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: sorted.length,
                    itemBuilder: (context, i) {
                      final booth = sorted[i];
                      return BoothCard(
                        booth: booth,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BoothDetailScreen(booth: booth),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: AppColors.navInactive.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No booths found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try a different search or category',
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
            onPressed: () =>
                context.read<BoothViewModel>().loadBooths(widget.event.id),
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

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          ..._sortOptions.map(
            (opt) => ListTile(
              leading: Icon(
                _sortIcon(opt),
                size: 20,
                color: opt == _sortBy ? AppColors.accent : AppColors.textSub,
              ),
              title: Text(
                opt,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: opt == _sortBy
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: opt == _sortBy ? AppColors.accent : AppColors.textMain,
                ),
              ),
              trailing: opt == _sortBy
                  ? const Icon(Icons.check_rounded, color: AppColors.accent)
                  : null,
              onTap: () {
                setState(() => _sortBy = opt);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _sortIcon(String sort) {
    switch (sort) {
      case 'Rating: High to Low':
      case 'Rating: Low to High':
        return Icons.star_rounded;
      case 'Name: A to Z':
        return Icons.sort_by_alpha_rounded;
      case 'Status: Available First':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }
}
