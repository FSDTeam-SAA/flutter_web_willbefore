import '../features/product/domain/entrity/product.dart';
import '../models/dashboard_models.dart';

class DummyData {
  static DashboardStats get dashboardStats => DashboardStats(
    totalRevenue: 10250.0,
    totalLiveProducts: 10250,
    totalUsers: 10250,
  );

  static List<ChartData> get newUserData => [
    ChartData(label: 'Jan', value: 0),
    ChartData(label: 'Feb', value: 1000),
    ChartData(label: 'Mar', value: 1200),
    ChartData(label: 'Apr', value: 2800),
    ChartData(label: 'May', value: 3500),
    ChartData(label: 'Jun', value: 3200),
    ChartData(label: 'Jul', value: 2000),
  ];

  static List<ChartData> get liveProductData => [
    ChartData(label: '1.0', value: 55),
    ChartData(label: '2.0', value: 70),
    ChartData(label: '3.0', value: 55),
    ChartData(label: '4.0', value: 80),
    ChartData(label: '5.0', value: 70),
    ChartData(label: '6.0', value: 85),
    ChartData(label: '7.0', value: 75),
  ];

  static List<ChartData> get revenueThisYear => [
    ChartData(label: 'JAN', value: 0),
    ChartData(label: 'FEB', value: 800),
    ChartData(label: 'MAR', value: 1200),
    ChartData(label: 'APR', value: 900),
    ChartData(label: 'MAY', value: 1500),
    ChartData(label: 'JUN', value: 400),
    ChartData(label: 'JUL', value: 300),
    ChartData(label: 'AUG', value: 100),
    ChartData(label: 'SEP', value: 800),
    ChartData(label: 'OCT', value: 1000),
    ChartData(label: 'NOV', value: 600),
    ChartData(label: 'DEC', value: 200),
  ];

  static List<ChartData> get revenueLastYear => [
    ChartData(label: 'JAN', value: 200),
    ChartData(label: 'FEB', value: 600),
    ChartData(label: 'MAR', value: 1000),
    ChartData(label: 'APR', value: 1400),
    ChartData(label: 'MAY', value: 1800),
    ChartData(label: 'JUN', value: 1200),
    ChartData(label: 'JUL', value: 800),
    ChartData(label: 'AUG', value: 400),
    ChartData(label: 'SEP', value: 600),
    ChartData(label: 'OCT', value: 1200),
    ChartData(label: 'NOV', value: 800),
    ChartData(label: 'DEC', value: 400),
  ];

  static List<Product> get products => [
    Product(
      id: '1',
      title: 'Premium Chocolate Cake',
      actualPrice: 25.99,
      discountPrice: 19.99,
      stock: 50,
      description: 'Delicious premium chocolate cake with rich cocoa flavor',
      sizes: ['Small', 'Medium', 'Large'],
      colors: ['Brown', 'Dark Brown'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      categoryId: '',
      colorCodes: [],
      imageUrls: [],
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '2',
      title: 'Vanilla Cupcakes (6 pack)',
      actualPrice: 15.99,
      discountPrice: 12.99,
      stock: 30,
      description: 'Fresh vanilla cupcakes with buttercream frosting',
      sizes: ['Regular'],
      colors: ['White', 'Pink'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      categoryId: '',
      colorCodes: [],
      imageUrls: [],
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '3',
      title: 'Strawberry Cheesecake',
      actualPrice: 32.99,
      discountPrice: 28.99,
      stock: 20,
      description: 'Creamy strawberry cheesecake with fresh strawberries',
      sizes: ['Medium', 'Large'],
      colors: ['Pink', 'Red'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      categoryId: '',
      colorCodes: [],
      imageUrls: [],
      updatedAt: DateTime.now(),
    ),
  ];

  static List<Promo> get promos => [
    Promo(
      id: '1',
      title: 'Summer Sale',
      code: 'SUMMER2024',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      imageUrl: 'summer_promo.jpg',
    ),
    Promo(
      id: '2',
      title: 'Weekend Special',
      code: 'WEEKEND20',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
    ),
  ];

  static List<String> get categories => [
    'Cakes',
    'Cupcakes',
    'Cookies',
    'Pastries',
    'Cheesecakes',
    'Brownies',
    'Muffins',
  ];
}
