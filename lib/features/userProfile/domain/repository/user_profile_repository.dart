import '../../../order/data/models/user_model.dart';

abstract class AllUserProfileRepository {
  Stream<List<UserModel>> getUsers();
  Future<void> updateUserRole(String userId, String role);
  Future<void> deleteUser(String userId);
}
