import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService({required AuthRepository repository}) : _repository = repository;

  Future<AuthModel> login(LoginRequest request) => _repository.login(request);

  Future<AuthModel> register(RegisterRequest request) =>
      _repository.register(request);

  Future<AuthModel> refreshToken() => _repository.refreshToken();

  Future<void> logout() => _repository.logout();

  Future<void> forgotPassword(String email) =>
      _repository.forgotPassword(email);

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) =>
      _repository.resetPassword(token: token, newPassword: newPassword);

  Future<bool> validateToken() => _repository.validateToken();

  Future<String?> getCurrentUserId() => _repository.getCurrentUserId();

  Future<String?> getCustomerId() => _repository.getCustomerId();

  Future<String?> getAccessToken() => _repository.getAccessToken();

  Future<bool> isLoggedIn() => _repository.isLoggedIn();

  Future<bool> isTokenValid() => _repository.isTokenValid();
}
