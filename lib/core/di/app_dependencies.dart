import 'package:dio/dio.dart';
import 'package:fellow_traveller_mobile/core/data/secure_storage.dart';
import 'package:fellow_traveller_mobile/core/data/user_session.dart';
import 'package:fellow_traveller_mobile/core/data/user_session_storage.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/auth_api.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/auth_repository.dart';
import 'package:fellow_traveller_mobile/core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fellow_traveller_mobile/core/features/driver/presentation/bloc/driver_home_bloc.dart';
import 'package:fellow_traveller_mobile/core/features/passenger/presentation/bloc/passenger_home_bloc.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/rides_repository.dart';
import 'package:fellow_traveller_mobile/core/interceptors/dio_interceptor.dart';

class AppDependencies {
  AppDependencies._();

  static final AppDependencies instance = AppDependencies._();

  late final SecureTokenStorage secureTokenStorage;
  late final UserSessionStorage userSessionStorage;
  late final UserSession userSession;
  late final Dio dio;
  late final ApiClientAuth authApi;
  late final AuthRepository authRepository;
  late final RidesRepository ridesRepository;

  Future<void> init() async {
    secureTokenStorage = SecureTokenStorage();
    userSessionStorage = UserSessionStorage();
    userSession = UserSession(userSessionStorage);
    await userSession.load();

    dio = DioFactory.createDio(secureTokenStorage);
    authApi = ApiClientAuth(dio);
    authRepository = AuthRepository(
      apiClient: authApi,
      tokenStorage: secureTokenStorage,
      userSession: userSession,
    );
    ridesRepository = RidesRepository(dio: dio);
  }

  AuthBloc createAuthBloc() => AuthBloc(authRepository);

  PassengerHomeBloc createPassengerHomeBloc() =>
      PassengerHomeBloc(ridesRepository);

  DriverHomeBloc createDriverHomeBloc() => DriverHomeBloc(ridesRepository);
}
