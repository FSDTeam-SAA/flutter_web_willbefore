import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sidebar.dart';
import '../widgets/dashboard_header.dart';
import '../models/dashboard_models.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;

  const DashboardLayout({
    super.key,
    required this.child,
  });

  NavigationItem _getCurrentNavigationItem(String location) {
    if (location.startsWith('/dashboard')) return NavigationItem.dashboard;
    if (location.startsWith('/categories')) return NavigationItem.categories;
    if (location.startsWith('/products')) return NavigationItem.productList;
    if (location.startsWith('/orders')) return NavigationItem.order;
    if (location.startsWith('/promos')) return NavigationItem.promo;
    if (location.startsWith('/profile')) return NavigationItem.userProfile;
    if (location.startsWith('/settings')) return NavigationItem.settings;
    return NavigationItem.dashboard;
  }

  String _getPageTitle(String location) {
    if (location.startsWith('/dashboard')) return 'Overview';
    if (location.startsWith('/categories')) return 'Categories';
    if (location.startsWith('/products/add')) return 'Add Product';
    if (location.startsWith('/products/edit')) return 'Edit Product';
    if (location.startsWith('/products')) return 'Product List';
    if (location.startsWith('/orders')) return 'Orders';
    if (location.startsWith('/promos/add')) return 'Add Promo';
    if (location.startsWith('/promos')) return 'Promos';
    if (location.startsWith('/profile')) return 'User Profile';
    if (location.startsWith('/settings')) return 'Settings';
    return 'Dashboard';
  }

  List<String> _getBreadcrumbs(String location) {
    if (location.startsWith('/dashboard')) return ['Dashboard', 'Overview'];
    if (location.startsWith('/categories')) return ['Dashboard', 'Categories'];
    if (location.startsWith('/products/add')) return ['Dashboard', 'Product List', 'Add Product'];
    if (location.startsWith('/products/edit')) return ['Dashboard', 'Product List', 'Edit Product'];
    if (location.startsWith('/products')) return ['Dashboard', 'Product List'];
    if (location.startsWith('/orders')) return ['Dashboard', 'Orders'];
    if (location.startsWith('/promos/add')) return ['Dashboard', 'Promo List', 'Add Promo'];
    if (location.startsWith('/promos')) return ['Dashboard', 'Promo List'];
    if (location.startsWith('/profile')) return ['Dashboard', 'User Profile'];
    if (location.startsWith('/settings')) return ['Dashboard', 'Settings'];
    return ['Dashboard'];
  }

  void _onNavigationItemSelected(BuildContext context, NavigationItem item) {
    switch (item) {
      case NavigationItem.dashboard:
        context.go('/dashboard');
        break;
      case NavigationItem.categories:
        context.go('/categories');
        break;
      case NavigationItem.productList:
        context.go('/products');
        break;
      case NavigationItem.order:
        context.go('/orders');
        break;
      case NavigationItem.promo:
        context.go('/promos');
        break;
      case NavigationItem.userProfile:
        context.go('/profile');
        break;
      case NavigationItem.settings:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentItem = _getCurrentNavigationItem(location);
    final pageTitle = _getPageTitle(location);
    final breadcrumbs = _getBreadcrumbs(location);

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedItem: currentItem,
            onItemSelected: (item) => _onNavigationItemSelected(context, item),
          ),
          Expanded(
            child: Column(
              children: [
                DashboardHeader(
                  title: pageTitle,
                  breadcrumbs: breadcrumbs,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}