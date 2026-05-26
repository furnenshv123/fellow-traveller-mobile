import 'package:fellow_traveller_mobile/core/data/secure_storage.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/auth_api.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/models/auth_model.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/models/auth_response.dart';

class AuthRepository {
  AuthRepository({
    required ApiClientAuth apiClient,
    required SecureTokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  final ApiClientAuth _apiClient;
  final SecureTokenStorage _tokenStorage;

  Future<AuthResponse> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _apiClient.login(
      loginRequest: AuthModel(
        email: email.trim(),
        password: password,
        role: role,
      ),
    );
    await _persistToken(response);
    return response;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _apiClient.register(
      registerRequest: AuthModel(
        email: email.trim(),
        password: password,
        role: role,
      ),
    );
    await _persistToken(response);
    return response;
  }

  Future<void> _persistToken(AuthResponse response) async {
    final token = response.accessToken;
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
    }
  }
}
