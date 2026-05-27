import 'package:fellow_traveller_mobile/core/data/secure_storage.dart';
import 'package:fellow_traveller_mobile/core/data/user_session.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/auth_api.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/models/auth_model.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/models/auth_response.dart';

class AuthRepository {
  AuthRepository({
    required ApiClientAuth apiClient,
    required SecureTokenStorage tokenStorage,
    required UserSession userSession,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage,
        _userSession = userSession;

  final ApiClientAuth _apiClient;
  final SecureTokenStorage _tokenStorage;
  final UserSession _userSession;

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
    await _persistSession(response, role: role);
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
    await _persistSession(response, role: role);
    return response;
  }

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
    await _userSession.clear();
  }

  Future<void> _persistSession(AuthResponse response, {required String role}) async {
    final token = response.accessToken;
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
    }
    await _userSession.setFromAuth(response, fallbackRole: role);
  }
}
