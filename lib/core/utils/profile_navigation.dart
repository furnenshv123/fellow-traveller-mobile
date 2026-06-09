import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/models/auth_response.dart';

class ProfileNavigation {
  ProfileNavigation._();

  static Future<String> resolvePostAuthRoute({
    AuthResponse? authResponse,
    String completeRoute = '/main',
  }) async {
    final deps = AppDependencies.instance;
    final hasToken = await deps.secureTokenStorage.hasToken();

    if (!hasToken) {
      return AppRoutesEnum.auth.path;
    }

    return _resolveProfileRoute(
      authResponse: authResponse,
      completeRoute: completeRoute,
    );
  }

  static Future<String> resolvePostRoleSwitchRoute({
    required AuthResponse authResponse,
  }) {
    return _resolveProfileRoute(
      authResponse: authResponse,
      completeRoute: AppRoutesEnum.profile.path,
    );
  }

  static Future<String> _resolveProfileRoute({
    AuthResponse? authResponse,
    required String completeRoute,
  }) async {
    final deps = AppDependencies.instance;

    if (authResponse != null) {
      deps.userSession.setProfileSetupHintFromAuth(authResponse);
    }

    try {
      final complete = await deps.profileRepository.isProfileComplete();
      await deps.userSession.setProfileComplete(complete);
      return complete ? completeRoute : AppRoutesEnum.createProfile.path;
    } catch (_) {
      return deps.userSession.needsProfileSetup
          ? AppRoutesEnum.createProfile.path
          : completeRoute;
    }
  }

  static Future<String> resolveSplashRoute() => resolvePostAuthRoute();
}
