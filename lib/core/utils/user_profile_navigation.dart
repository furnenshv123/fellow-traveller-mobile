import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class UserProfileNavigation {
  static void openDriverProfile(
    BuildContext context, {
    required int profileId,
  }) {
    context.push(AppRoutesEnum.userDriverProfile.pathWithProfileId(profileId));
  }

  static void openPassengerProfile(
    BuildContext context, {
    required int profileId,
  }) {
    context.push(
      AppRoutesEnum.userPassengerProfile.pathWithProfileId(profileId),
    );
  }
}
