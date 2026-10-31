import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';

class PromoNotFound extends StatelessWidget {
  const PromoNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: AppColors.textSecondaryHintColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Promo not found',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondaryHintColor,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(RouteEndpoint.promos),
            child: const Text('Back to Promo List'),
          ),
        ],
      ),
    );
  }
}
