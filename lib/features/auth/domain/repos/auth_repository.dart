import 'package:flutter_web_willbefore/features/auth/domain/requests/login_request.dart';

import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(LoginRequest request);
  Stream<UserModel?> get authStateChanges;
  Future<String?> getUserRole(String uid);
  Future<void> logout();
}