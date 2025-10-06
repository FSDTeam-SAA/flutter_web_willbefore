import 'package:flutter_web_willbefore/features/auth/domain/requests/login_request.dart';
import 'package:flutter_web_willbefore/features/auth/domain/models/user_model.dart';
import 'package:flutter_web_willbefore/features/auth/domain/repos/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<UserModel> call(LoginRequest request) async {
    final user = await _authRepository.login(request);
    // if (user.role != 'admin') {
    //   // Sign out non-admin users
    //   await _authRepository.logout();
    //   throw Exception('Access denied: Only admins can log in');
    // }
    return user;
  }
}
