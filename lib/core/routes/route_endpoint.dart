import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_willbefore/features/order/presentation/screens/order_details_screen.dart';
import 'package:flutter_web_willbefore/features/order/presentation/screens/orders_screen.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_layout.dart';
import '../../features/order/domain/entities/order_entities.dart';
import '../../features/overview/presentation/screens/overview_screen.dart';
import '../../features/product/presentation/screens/add_product_screen.dart';
import '../../features/product/presentation/screens/edit_product_screen.dart';
import '../../features/product/presentation/screens/product_list_screen.dart';
import '../../features/promo/presentation/screens/add_promo_screen.dart';
import '../../features/promo/presentation/screens/promo_screen.dart';
import '../../features/setting/presentation/screens/admin_setting_screen.dart';
import '../../features/userProfile/presentation/screens/user_profile_screen.dart';

part 'app_router.dart';

class RouteEndpoint {
  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main dashboard
  static const String dashboard = '/dashboard';

  // Product routes
  static const String products = '/products';
  static const String addProduct = '/products/add';
  // static const String editProduct = '/products/edit/:id';

  // Category routes
  static const String categories = '/categories';

  // Order routes
  static const String orders = '/orders';
  static const String ordersDetails = 'orders-details';

  // Promo routes
  static const String promos = '/promos';
  static const String addPromo = '/promos/add';
  static const String editPromo = '/promos/edit/:id';
  static const String viewPromo = '/promos/view/:id';

  // User routes
  static const String profile = '/profile';
  static const String users = '/user-profile';
  static const String settings = '/settings';

  // Error routes
  static const String notFound = '/not-found';
}
