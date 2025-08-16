import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final List<String> breadcrumbs;

  const DashboardHeader({
    super.key,
    required this.title,
    required this.breadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        // color: AppTheme.backgroundColor,
        border: Border(
          // bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    // color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: breadcrumbs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final breadcrumb = entry.value;
                    final isLast = index == breadcrumbs.length - 1;

                    return Row(
                      children: [
                        Text(
                          breadcrumb,
                          style: TextStyle(
                            // color: isLast ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: isLast
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                        if (!isLast) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            // color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // User Profile
          Row(
            children: [
              const Text(
                'Admin',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  // color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                // backgroundColor: AppColors.primaryLaurel,
                child: const Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
