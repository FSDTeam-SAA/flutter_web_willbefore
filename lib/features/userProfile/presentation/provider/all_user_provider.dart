// features/users/presentation/providers/user_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/base/base_state.dart';
import '../../../order/data/models/user_model.dart';
import '../../data/repository/user_profile_repository_impl.dart';
import '../../domain/repository/user_profile_repository.dart';

class AllUserState extends BaseState {
  final List<UserModel> users;
  final String? updateError;
  final String? deleteError;

  const AllUserState({
    super.isLoading = false,
    super.errorMessage,
    this.users = const [],
    this.updateError,
    this.deleteError,
  });

  @override
  AllUserState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<UserModel>? users,
    String? updateError,
    String? deleteError,
  }) {
    return AllUserState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      users: users ?? this.users,
      updateError: updateError ?? this.updateError,
      deleteError: deleteError ?? this.deleteError,
    );
  }
}

final userRepositoryProvider = Provider<AllUserProfileRepository>((ref) {
  return AllUserProfileRepositorImpl(FirebaseFirestore.instance);
});

final userProvider = StateNotifierProvider<UserProvider, AllUserState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserProvider(userRepository);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return ref
      .watch(userProvider)
      .users
      .firstWhere(
        (u) => u.id == user.uid,
        orElse: () => throw Exception('Current user not found'),
      );
});

class UserProvider extends StateNotifier<AllUserState> {
  final AllUserProfileRepository _userRepository;

  UserProvider(this._userRepository) : super(const AllUserState()) {
    _loadUsers();
  }

  void _loadUsers() {
    state = state.copyWith(isLoading: true);

    // Listen to users stream
    _userRepository.getUsers().listen(
      (users) {
        state = state.copyWith(
          users: users,
          isLoading: false,
          errorMessage: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load users: $error',
        );
      },
    );
  }

  Future<bool> updateUserRole(String userId, String role) async {
    state = state.copyWith(isLoading: true, updateError: null);
    try {
      await _userRepository.updateUserRole(userId, role);

      // Update local state
      final updatedUsers = state.users.map((user) {
        if (user.id == userId) {
          return user.copyWith(role: role);
        }
        return user;
      }).toList();

      state = state.copyWith(users: updatedUsers, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        updateError: 'Failed to update user role: $e',
      );
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    state = state.copyWith(isLoading: true, deleteError: null);
    try {
      await _userRepository.deleteUser(userId);

      // Remove from local state
      final updatedUsers = state.users
          .where((user) => user.id != userId)
          .toList();

      state = state.copyWith(users: updatedUsers, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        deleteError: 'Failed to delete user: $e',
      );
      return false;
    }
  }

  void refreshUsers() {
    _loadUsers();
  }
}
