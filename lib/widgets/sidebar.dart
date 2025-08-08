import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../theme/app_theme.dart';

class Sidebar extends StatelessWidget {
  final NavigationItem selectedItem;
  final Function(NavigationItem) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.sentiment_satisfied,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'SmileTreats',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Text(
                  '™',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  item: NavigationItem.dashboard,
                ),
                _buildNavItem(
                  icon: Icons.category_outlined,
                  title: 'Categories',
                  item: NavigationItem.categories,
                ),
                _buildNavItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Product List',
                  item: NavigationItem.productList,
                ),
                _buildNavItem(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Order',
                  item: NavigationItem.order,
                ),
                _buildNavItem(
                  icon: Icons.local_offer_outlined,
                  title: 'Promo',
                  item: NavigationItem.promo,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  title: 'User Profile',
                  item: NavigationItem.userProfile,
                ),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  title: 'Setting',
                  item: NavigationItem.settings,
                ),
              ],
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                // Handle logout
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required NavigationItem item,
  }) {
    final isSelected = selectedItem == item;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppTheme.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () => onItemSelected(item),
      ),
    );
  }
}
