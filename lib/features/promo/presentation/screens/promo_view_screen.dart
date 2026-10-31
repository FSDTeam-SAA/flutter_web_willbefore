import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';
import '../../domain/models/promo_model.dart';
import '../providers/promos_provider.dart';
import '../widgets/promo_not_found.dart';

class PromoViewScreen extends ConsumerWidget {
  final String promoId;

  const PromoViewScreen({super.key, required this.promoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(promoByIdProvider(promoId))
        .when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryLaurel),
          ),
          error: (_, _) => const PromoNotFound(),
          data: (promo) => _buildContent(context, promo),
        );
  }

  Widget _buildContent(BuildContext context, PromoModel promo) {
    final narrow = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(narrow ? 12 : 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  promo.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textAppBlack,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.go('${RouteEndpoint.promos}/edit/${promo.id}'),
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  label: const Text(
                    'Edit Promo',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLaurel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (promo.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  promo.imageUrl!,
                  height: narrow ? 160 : 240,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 24),
            ],
            _buildDetailRow('Code', promo.code),
            _buildDetailRow('Status', _statusLabel(promo)),
            _buildDetailRow('Description', promo.description),
            _buildDetailRow(
              'Discount Percentage',
              '${promo.discountPercentage.toInt()}%',
            ),
            _buildDetailRow(
              'Fixed Discount Amount',
              _formatAmount(promo.discountAmount),
            ),
            _buildDetailRow(
              'Minimum Order Amount',
              _formatAmount(promo.minimumOrderAmount),
            ),
            _buildDetailRow('Starts', _formatDate(promo.startDate)),
            _buildDetailRow('Ends', _formatDate(promo.endDate)),
            _buildDetailRow(
              'Usage',
              promo.usageLimit > 0
                  ? '${promo.usedCount}/${promo.usageLimit}'
                  : '${promo.usedCount} (no limit)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: const TextStyle(fontSize: 16, color: AppColors.textAppBlack),
          ),
        ],
      ),
    );
  }

  String _statusLabel(PromoModel promo) {
    if (!promo.isActive) return 'Inactive';
    if (promo.isExpired) return 'Expired';
    if (promo.isCurrentlyActive) return 'Active';
    if (DateTime.now().isBefore(promo.startDate)) return 'Scheduled';
    return 'Usage limit reached';
  }

  String _formatAmount(double? amount) {
    if (amount == null || amount <= 0) return 'None';
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y • h:mm a').format(date);
  }
}
