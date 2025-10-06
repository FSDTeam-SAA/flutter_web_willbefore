import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';

import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/sources/order_remote_data_source.dart';
import '../../data/sources/user_remote_data_source.dart';
import '../../domain/entities/order_entities.dart';
import '../../domain/entities/user_entities.dart';
import '../../domain/repositories/order_repositry.dart';
import '../../domain/repositories/user_repository.dart';

class AdminOrderState {
  final List<Order> orders;
  final List<User> users;
  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;

  const AdminOrderState({
    this.orders = const [],
    this.users = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
  });

  AdminOrderState copyWith({
    List<Order>? orders,
    List<User>? users,
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
  }) {
    return AdminOrderState(
      orders: orders ?? this.orders,
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AdminOrderNotifier extends StateNotifier<AdminOrderState> {
  final OrderRepository _orderRepository;
  final UserProfileRepository _userRepository;

  AdminOrderNotifier(this._orderRepository, this._userRepository)
    : super(const AdminOrderState());

  Future<void> fetchAllUsersAndOrders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Fetch all users first
      final users = await _userRepository.getAllUsers();

      // Fetch all orders directly from main orders collection
      final orders = await _orderRepository.getAllOrders();

      state = state.copyWith(users: users, orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchAllOrders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final orders = await _orderRepository.getAllOrders();

      DPrint.log('Fetched ${orders.length} orders from repository');

      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    state = state.copyWith(isUpdating: true, errorMessage: null);

    try {
      await _orderRepository.updateOrderStatus(orderId, newStatus);

      // Update the order in the local state
      final updatedOrders = state.orders.map((order) {
        if (order.id == orderId) {
          return order.copyWith(status: newStatus);
        }
        return order;
      }).toList();

      state = state.copyWith(orders: updatedOrders, isUpdating: false);
      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false, errorMessage: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void subscribeToUsersAndOrders() {
    // Subscribe to users stream
    _userRepository.getAllUsersStream().listen(
      (users) {
        state = state.copyWith(users: users);
      },
      onError: (error) {
        state = state.copyWith(errorMessage: error.toString());
      },
    );

    // Subscribe to orders stream directly
    _orderRepository.getAllOrdersStream().listen(
      (orders) {
        if (!state.isLoading) {
          state = state.copyWith(orders: orders);
        }
      },
      onError: (error) {
        state = state.copyWith(errorMessage: error.toString());
      },
    );
  }

  void subscribeToOrders() {
    _orderRepository.getAllOrdersStream().listen(
      (orders) {
        if (!state.isLoading) {
          state = state.copyWith(orders: orders);
        }
      },
      onError: (error) {
        state = state.copyWith(errorMessage: error.toString());
      },
    );
  }

  User? getUserForOrder(String userId) {
    try {
      return state.users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }
}

final adminOrderProvider =
    StateNotifierProvider<AdminOrderNotifier, AdminOrderState>((ref) {
      final orderRemoteDataSource = ref.read(orderRemoteDataSourceProvider);
      final orderRepository = OrderRepositoryImpl(orderRemoteDataSource);

      final userRemoteDataSource = ref.read(userRemoteDataSourceProvider);
      final userRepository = UserRepositoryImpl(userRemoteDataSource);

      final notifier = AdminOrderNotifier(orderRepository, userRepository);

      // Subscribe to real-time updates for users and orders
      notifier.subscribeToUsersAndOrders();

      return notifier;
    });
