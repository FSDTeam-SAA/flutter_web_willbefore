import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';
import '../../domain/models/promo_model.dart';
import '../providers/promos_provider.dart';
import '../providers/send_promo_notification.dart';

class PromosScreen extends ConsumerStatefulWidget {
  const PromosScreen({super.key});

  @override
  ConsumerState<PromosScreen> createState() => _PromosScreenState();
}

class _PromosScreenState extends ConsumerState<PromosScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  /// Below this width the table scrolls sideways instead of squeezing.
  static const double _minTableWidth = 800;
  static const double _actionColumnWidth = 200;
  final TextEditingController _searchController = TextEditingController();

  /// Stops a second send of a promo while one is confirming or in progress.
  final Set<String> _sendingPromoIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _horizontalController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(promosProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final promosState = ref.watch(promosProvider);
    final promos = promosState.adminPromos;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildPageHeader(),

          const SizedBox(height: 16),

          // Search
          TextField(
            controller: _searchController,
            onSubmitted: (value) =>
                ref.read(promosProvider.notifier).search(value.trim()),
            decoration: InputDecoration(
              hintText: 'Search promos by title...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(promosProvider.notifier).search('');
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Promos Table
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
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
              child: LayoutBuilder(
                builder: (context, constraints) => Scrollbar(
                  controller: _horizontalController,
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: max(constraints.maxWidth, _minTableWidth),
                      child: Column(
                        children: [
                          _buildTableHeader(),

                          // Table Body
                          if (promosState.isLoadingAdmin)
                            const Expanded(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryLaurel,
                                ),
                              ),
                            )
                          else if (promos.isEmpty)
                            const Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_offer_outlined,
                                      size: 64,
                                      color: AppColors.textSecondaryHintColor,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No promos found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: AppColors.textSecondaryHintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount:
                                    promos.length +
                                    (promosState.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= promos.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryLaurel,
                                        ),
                                      ),
                                    );
                                  }

                                  return _buildPromoRow(
                                    promos[index],
                                    isLast: index == promos.length - 1,
                                    isDeleting: promosState.isDeleting,
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Promo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textAppBlack,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => context.go('${RouteEndpoint.promos}/add'),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Promo',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLaurel,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildHeaderCell('Promo Name')),
          Expanded(flex: 2, child: _buildHeaderCell('Code')),
          Expanded(flex: 2, child: _buildHeaderCell('Products')),
          SizedBox(
            width: _actionColumnWidth,
            child: _buildHeaderCell('Action'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.textAppBlack,
      ),
    );
  }

  Widget _buildPromoRow(
    PromoModel promo, {
    required bool isLast,
    required bool isDeleting,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : AppColors.borderColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildPromoName(promo)),
          Expanded(
            flex: 2,
            child: Text(
              promo.code,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondaryColor),
            ),
          ),
          Expanded(flex: 2, child: _PromoProductCount(promoId: promo.id)),
          SizedBox(
            width: _actionColumnWidth,
            child: _buildActions(promo, isDeleting: isDeleting),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoName(PromoModel promo) {
    return Row(
      children: [
        Container(
          width: 108,
          height: 46,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: AppColors.bgColor,
          ),
          child: promo.imageUrl != null
              ? Image.network(
                  promo.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImageFallback(),
                )
              : _buildImageFallback(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                promo.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textAppBlack,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                promo.discountLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageFallback() {
    return const Icon(
      Icons.local_offer,
      color: AppColors.primaryLaurel,
      size: 24,
    );
  }

  Widget _buildActions(PromoModel promo, {required bool isDeleting}) {
    final canNotify =
        promo.isCurrentlyActive && !_sendingPromoIds.contains(promo.id);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'View',
          onPressed: () =>
              context.go('${RouteEndpoint.promos}/view/${promo.id}'),
          icon: const Icon(
            Icons.visibility_outlined,
            size: 18,
            color: AppColors.textAppBlack,
          ),
        ),
        IconButton(
          tooltip: 'Edit',
          onPressed: () =>
              context.go('${RouteEndpoint.promos}/edit/${promo.id}'),
          icon: const Icon(
            Icons.edit_outlined,
            size: 18,
            color: AppColors.textAppBlack,
          ),
        ),
        IconButton(
          tooltip: promo.isCurrentlyActive
              ? 'Notify all users'
              : 'Only active promos can be sent',
          onPressed: canNotify ? () => _notifyUsers(promo) : null,
          icon: Icon(
            Icons.notifications_active_outlined,
            size: 18,
            color: canNotify
                ? AppColors.primaryLaurel
                : AppColors.textSecondaryHintColor,
          ),
        ),
        IconButton(
          tooltip: 'Delete',
          onPressed: isDeleting ? null : () => _showDeleteDialog(promo.id),
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
        ),
      ],
    );
  }

  Future<void> _notifyUsers(PromoModel promo) async {
    setState(() => _sendingPromoIds.add(promo.id));
    await confirmAndSendPromoNotification(context, promo);
    if (mounted) setState(() => _sendingPromoIds.remove(promo.id));
  }

  void _showDeleteDialog(String promoId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Promo'),
          content: const Text(
            'Are you sure you want to delete this promotional campaign? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await ref
                    .read(promosProvider.notifier)
                    .deletePromo(promoId);
                if (!mounted) return;
                final message = success
                    ? 'Promo deleted successfully!'
                    : ref
                          .read(promosProvider)
                          .errorMessage
                          .replaceFirst('Exception: ', '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: Colors.red),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PromoProductCount extends ConsumerWidget {
  final String promoId;

  const _PromoProductCount({required this.promoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(promoProductCountProvider(promoId));

    return Text(
      count.maybeWhen(data: (value) => '$value', orElse: () => '-'),
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.textSecondaryColor),
    );
  }
}
