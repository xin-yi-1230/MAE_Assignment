import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../widgets/cart_item_tile.dart';
import 'order_confirmation_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _selectedPickupTime = '12:00 PM';

  final List<String> _pickupTimes = [
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CartViewModel>();

    // Navigate to confirmation when order placed
    if (vm.orderPlaced && vm.lastOrderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.resetOrderPlaced();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderConfirmationScreen(orderId: vm.lastOrderId!),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textMain,
        elevation: 0,
        actions: [
          // Clear all button
          if (!vm.isEmpty)
            TextButton(
              onPressed: () => _showClearCartDialog(context, vm),
              child: const Text(
                'Clear all',
                style: TextStyle(color: AppColors.badge, fontSize: 13),
              ),
            ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.isEmpty
          ? _emptyCart()
          : Column(
              children: [
                // ── Cart items ───────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    children: [
                      // Group by booth
                      ...vm.itemsByBooth.entries.map((entry) {
                        final boothName = entry.key;
                        final boothItems = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Booth name header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.store_rounded,
                                    size: 14,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    boothName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Items in this booth
                            ...boothItems.map(
                              (item) => CartItemTile(
                                item: item,
                                onIncrease: () => context
                                    .read<CartViewModel>()
                                    .updateQuantity(item.id, item.quantity + 1),
                                onDecrease: () => context
                                    .read<CartViewModel>()
                                    .updateQuantity(item.id, item.quantity - 1),
                                onRemove: () => context
                                    .read<CartViewModel>()
                                    .removeItem(item.id),
                              ),
                            ),
                          ],
                        );
                      }),

                      // ── Pickup time selector ──
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Pickup Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMain,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Time chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _pickupTimes.map((time) {
                                final selected = time == _selectedPickupTime;
                                return GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedPickupTime = time,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.accent
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.accent
                                            : AppColors.divider,
                                      ),
                                    ),
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: selected
                                            ? Colors.white
                                            : AppColors.textSub,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Order summary + place order ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Item count + total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${vm.totalItemCount} item${vm.totalItemCount > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSub,
                            ),
                          ),
                          Text(
                            vm.formattedTotal,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Place order button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: vm.isLoading
                              ? null
                              : () => _placeOrder(context, vm),
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
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Place Order  •  ${vm.formattedTotal}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── Place order ───────────────────────────────
  void _placeOrder(BuildContext context, CartViewModel vm) {
    if (vm.items.isEmpty) return;

    // Get booth and event from first item
    // (all items in cart assumed same event for now)
    final firstItem = vm.items.first;

    context.read<CartViewModel>().placeOrder(
      boothId: firstItem.boothId,
      boothName: firstItem.boothName,
      eventId: firstItem.eventId,
      eventName: 'Food Fair 2026', // TODO: pass real event name
      pickupTime: _selectedPickupTime,
    );
  }

  // ── Clear cart dialog ─────────────────────────
  void _showClearCartDialog(BuildContext context, CartViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSub),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final userId = 'student_001';
              vm.removeItem(''); // triggers reload
              // TODO: wire proper clear all
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.badge),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty cart ────────────────────────────────
  Widget _emptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.navInactive.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSub,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse booths and add items to order',
            style: TextStyle(fontSize: 13, color: AppColors.textSub),
          ),
        ],
      ),
    );
  }
}
