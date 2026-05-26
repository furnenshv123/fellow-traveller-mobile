import 'package:dio/dio.dart';
import 'package:fellow_traveller_mobile/core/data/secure_storage.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/auth_api.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/auth_repository.dart';
import 'package:fellow_traveller_mobile/core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fellow_traveller_mobile/core/interceptors/dio_interceptor.dart';

class AppDependencies {
  AppDependencies._();

  static final AppDependencies instance = AppDependencies._();

  late final SecureTokenStorage secureTokenStorage;
  late final Dio dio;
  late final ApiClientAuth authApi;
  late final AuthRepository authRepository;

  Future<void> init() async {
    secureTokenStorage = SecureTokenStorage();
    dio = DioFactory.createDio(secureTokenStorage);
    authApi = ApiClientAuth(dio);
    authRepository = AuthRepository(
      apiClient: authApi,
      tokenStorage: secureTokenStorage,
    );
  }

  AuthBloc createAuthBloc() => AuthBloc(authRepository);
}
