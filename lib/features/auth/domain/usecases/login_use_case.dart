import 'package:flutter_web_willbefore/features/auth/domain/requests/login_request.dart';

import '../repos/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<void> call(LoginRequest request) async {
    await repository.login(request);
  }
}