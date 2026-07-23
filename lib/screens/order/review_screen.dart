import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../viewmodels/review_viewmodel.dart';

class ReviewScreen extends StatefulWidget {
  final OrderModel order;
  const ReviewScreen({super.key, required this.order});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _commentController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset viewmodel when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewViewModel>().reset();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();

    // Navigate back after successful submission
    if (vm.isSubmitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Review submitted successfully!'),
            ]),
            backgroundColor: AppColors.tagGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Rate Booth',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textMain,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Booth info card ──────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.store_rounded,
                      color: AppColors.accent, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(widget.order.boothName,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain)),
                      const SizedBox(height: 2),
                      Text(widget.order.eventName,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSub)),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Star rating ──────────────────────
            const Text('Your Rating',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain)),
            const SizedBox(height: 4),
            const Text('Tap a star to rate',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSub)),
            const SizedBox(height: 16),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final starValue = i + 1;
                return GestureDetector(
                  onTap: () => context
                      .read<ReviewViewModel>()
                      .onStarTapped(starValue),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6),
                    child: AnimatedScale(
                      scale: vm.selectedStars >= starValue
                          ? 1.2
                          : 1.0,
                      duration:
                          const Duration(milliseconds: 150),
                      child: Icon(
                        vm.selectedStars >= starValue
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 48,
                        color: vm.selectedStars >= starValue
                            ? Colors.amber
                            : AppColors.divider,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            // Star label
            Center(
              child: Text(
                _starLabel(vm.selectedStars),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: vm.selectedStars > 0
                        ? Colors.amber
                        : AppColors.textSub),
              ),
            ),
            const SizedBox(height: 28),

            // ── What you ordered ─────────────────
            const Text('What you ordered',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain)),
            const SizedBox(height: 10),
            ...widget.order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.fiber_manual_record,
                    size: 6, color: AppColors.textSub),
                const SizedBox(width: 8),
                Text(
                  '${item.productName}  x${item.quantity}',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSub),
                ),
              ]),
            )),
            const SizedBox(height: 24),

            // ── Comment field ────────────────────
            const Text('Leave a Comment (optional)',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain)),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 300,
              onChanged: (val) => context
                  .read<ReviewViewModel>()
                  .onCommentChanged(val),
              decoration: InputDecoration(
                hintText:
                    'Share your experience with this booth...',
                hintStyle: const TextStyle(
                    fontSize: 13, color: AppColors.textSub),
                filled: true,
                fillColor: AppColors.cardBg,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // ── Error message ────────────────────
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(vm.errorMessage!,
                    style: const TextStyle(
                        color: AppColors.badge,
                        fontSize: 13)),
              ),
            const SizedBox(height: 8),

            // ── Submit button ────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: vm.canSubmit && !vm.isLoading
                    ? () => context
                        .read<ReviewViewModel>()
                        .submitReview(
                          boothId: widget.order.boothId,
                          eventId: widget.order.eventId,
                          orderId: widget.order.id,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.divider,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: vm.isLoading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2),
                      )
                    : const Text('Submit Review',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _starLabel(int stars) {
    switch (stars) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent!';
      default: return 'Select a rating';
    }
  }
}