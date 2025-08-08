import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/dashboard_layout.dart';
import '../../screens/overview_screen.dart';
import '../../screens/categories_screen.dart';
import '../../screens/product_list_screen.dart';
import '../../screens/add_product_screen.dart';
import '../../screens/edit_product_screen.dart';
import '../../screens/order_screen.dart';
import '../../screens/promo_screen.dart';
import '../../screens/add_promo_screen.dart';
import '../../screens/user_profile_screen.dart';
import '../../screens/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return DashboardLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const OverviewScreen(),
          ),
          GoRoute(
            path: '/categories',
            name: 'categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/products',
            name: 'products',
            builder: (context, state) => const ProductListScreen(),
            routes: [
              GoRoute(
                path: '/add',
                name: 'add-product',
                builder: (context, state) => const AddProductScreen(),
              ),
              GoRoute(
                path: '/edit/:id',
                name: 'edit-product',
                builder: (context, state) {
                  final productId = state.pathParameters['id']!;
                  return EditProductScreen(productId: productId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            builder: (context, state) => const OrderScreen(),
          ),
          GoRoute(
            path: '/promos',
            name: 'promos',
            builder: (context, state) => const PromoScreen(),
            routes: [
              GoRoute(
                path: '/add',
                name: 'add-promo',
                builder: (context, state) => const AddPromoScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const UserProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}