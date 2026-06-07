import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/models/auth_response.dart';

class ProfileNavigation {
  ProfileNavigation._();

  static Future<String> resolvePostAuthRoute({
    AuthResponse? authResponse,
  }) async {
    final deps = AppDependencies.instance;
    final hasToken = await deps.secureTokenStorage.hasToken();

    if (!hasToken) {
      return AppRoutesEnum.auth.path;
    }

    if (authResponse != null) {
      deps.userSession.setProfileSetupHintFromAuth(authResponse);
    }
    try {
      final complete = await deps.profileRepository.isProfileComplete();
      deps.userSession.setProfileComplete(complete);
      return complete
          ? AppRoutesEnum.main.path
          : AppRoutesEnum.createProfile.path;
    } catch (e) {
      return AppRoutesEnum.auth.path;
    }
  }

  static Future<String> resolveSplashRoute() => resolvePostAuthRoute();
}
