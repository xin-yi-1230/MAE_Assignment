import 'package:flutter_application_assignment/models/review_model.dart';
import 'package:flutter_application_assignment/viewmodels/cart_viewmodel.dart';
import 'package:flutter_application_assignment/screens/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booth_model.dart';
import '../../viewmodels/booth_viewmodel.dart';
import '../widgets/product_card.dart';
import '../widgets/review_tile.dart';

class BoothDetailScreen extends StatefulWidget {
  final BoothModel booth;
  const BoothDetailScreen({super.key, required this.booth});

  @override
  State<BoothDetailScreen> createState() => _BoothDetailScreenState();
}

class _BoothDetailScreenState extends State<BoothDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BoothViewModel>().loadBoothDetail(widget.booth.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.booth.status) {
      case 'Available':
        return AppColors.tagGreen;
      case 'Low':
        return Colors.orange;
      case 'Sold Out':
        return AppColors.badge;
      default:
        return AppColors.textSub;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BoothViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, _) => [
                // ── Sliver App Bar ──────────────
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: AppColors.cardBg,
                  foregroundColor: AppColors.textMain,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: widget.booth.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.booth.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.store_rounded,
                              size: 80,
                              color: AppColors.accent.withValues(alpha: 0.3),
                            ),
                          ),
                  ),
                  // In SliverAppBar add actions
                  actions: [
                    Consumer<CartViewModel>(
                      builder: (context, cartVm, _) => Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart_outlined),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            ),
                          ),
                          if (cartVm.totalItemCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppColors.badge,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Center(
                                  child: Text(
                                    '${cartVm.totalItemCount}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Booth info header ───────────
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.cardBg,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + status badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.booth.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                widget.booth.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Category + location
                        Row(
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              size: 14,
                              color: AppColors.textSub,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.booth.category,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSub,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSub,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.booth.location,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSub,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Rating row
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.booth.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.booth.totalRatings} reviews)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSub,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Description
                        Text(
                          widget.booth.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSub,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Tab bar ─────────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.accent,
                      unselectedLabelColor: AppColors.textSub,
                      indicatorColor: AppColors.accent,
                      indicatorWeight: 3,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.restaurant_menu_rounded,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Menu (${vm.products.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star_outline_rounded, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Reviews (${vm.reviews.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Tab views ──────────────────────
              body: TabBarView(
                controller: _tabController,
                children: [
                  // ── Menu tab ───────────────────
                  vm.products.isEmpty
                      ? _emptyState(
                          Icons.restaurant_menu_rounded,
                          'No menu items available',
                        )
                      : Column(
                          children: [
                            // Filter bar sits above the list
                            const _MenuFilterBar(),
                            Expanded(
                              child: vm.filteredProducts.isEmpty
                                  ? _emptyState(
                                      Icons.search_off_rounded,
                                      'No items match your filter',
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        bottom: 20,
                                      ),
                                      itemCount: vm.filteredProducts.length,
                                      itemBuilder: (context, i) {
                                        final product = vm.filteredProducts[i];
                                        return ProductCard(
                                          product: product,
                                          onAddToOrder: () =>
                                              _showAddToOrderSheet(
                                                context,
                                                product,
                                              ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),

                  // ── Reviews tab ─────────────────
                  vm.reviews.isEmpty
                      ? _emptyState(
                          Icons.star_outline_rounded,
                          'No reviews yet',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          // +1 for the rating summary at the top
                          itemCount: vm.reviews.length + 1,
                          itemBuilder: (context, i) {
                            // First item is always the rating summary
                            if (i == 0) {
                              return _RatingSummary(reviews: vm.reviews);
                            }
                            return ReviewTile(review: vm.reviews[i - 1]);
                          },
                        ),
                ],
              ),
            ),
    );
  }

  void _showAddToOrderSheet(BuildContext context, product) {
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Product name
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 4),

              // Price
              Text(
                product.formattedPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),

              // Quantity selector
              Row(
                children: [
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  const Spacer(),

                  // Minus button
                  IconButton(
                    onPressed: quantity > 1
                        ? () => setSheetState(() => quantity--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: AppColors.accent,
                  ),

                  // Quantity number
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),

                  // Plus button
                  IconButton(
                    onPressed: quantity < product.stock
                        ? () => setSheetState(() => quantity++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Total price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 15, color: AppColors.textSub),
                  ),
                  Text(
                    'RM ${(product.price * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Wire to CartViewModel
                    context.read<CartViewModel>().addToCart(
                      product,
                      quantity,
                      widget.booth.name,
                      widget.booth.eventId,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${product.name} x$quantity added to cart',
                                maxLines: 2, // Optional safety net
                                overflow: TextOverflow
                                    .ellipsis, // Elegantly truncates with '...' if insanely long
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.tagGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add to Order  •  RM ${(product.price * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.navInactive.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 15, color: AppColors.textSub),
          ),
        ],
      ),
    );
  }
}

// ── Sticky tab bar delegate ───────────────────
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _StickyTabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.cardBg, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

class _MenuFilterBar extends StatelessWidget {
  const _MenuFilterBar();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BoothViewModel>();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          // ── Filter by status ─────────────────
          Expanded(
            child: _DropdownChip(
              icon: Icons.filter_list_rounded,
              label: vm.menuFilterStatus,
              options: const ['All', 'Available', 'Low', 'Sold Out'],
              onSelected: (val) =>
                  context.read<BoothViewModel>().onMenuFilterChanged(val),
            ),
          ),
          const SizedBox(width: 10),

          // ── Sort ────────────────────────────
          Expanded(
            child: _DropdownChip(
              icon: Icons.sort_rounded,
              label: vm.menuSortBy,
              options: const [
                'Default',
                'Price: Low to High',
                'Price: High to Low',
                'Name',
              ],
              onSelected: (val) =>
                  context.read<BoothViewModel>().onMenuSortChanged(val),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _DropdownChip({
    required this.icon,
    required this.label,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
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
              const SizedBox(height: 16),
              ...options.map(
                (opt) => ListTile(
                  title: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: opt == label
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: opt == label
                          ? AppColors.accent
                          : AppColors.textMain,
                    ),
                  ),
                  trailing: opt == label
                      ? Icon(Icons.check_rounded, color: AppColors.accent)
                      : null,
                  onTap: () => Navigator.pop(context, opt),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
        if (selected != null) onSelected(selected);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: AppColors.textSub),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textMain),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: AppColors.textSub,
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final List<ReviewModel> reviews;
  const _RatingSummary({required this.reviews});

  double get _average {
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.stars).reduce((a, b) => a + b) / reviews.length;
  }

  // Count how many reviews per star (5 down to 1)
  int _countForStar(int star) => reviews.where((r) => r.stars == star).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: big score ──────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _average.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              // Star icons
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < _average.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${reviews.length} Ratings',
                style: const TextStyle(fontSize: 12, color: AppColors.textSub),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // ── Right: bar breakdown ─────────────
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final star = 5 - i; // 5 down to 1
                final count = _countForStar(star);
                final ratio = reviews.isEmpty ? 0.0 : count / reviews.length;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      // Star number
                      Text(
                        '$star',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSub,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Progress bar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 8,
                            backgroundColor: AppColors.surface,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.amber,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Count
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSub,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
