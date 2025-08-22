import '../entities/user_entities.dart';

abstract class UserRepository {
  Future<List<User>> getAllUsers();
  Stream<List<User>> getAllUsersStream();
  Future<User?> getUserById(String userId);
}
