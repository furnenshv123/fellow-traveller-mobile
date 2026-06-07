enum AppRoutesEnum {
  auth,
  main,
  splash,
  rides,
  profile,
  createProfile,
  driverRideRequests,
  userDriverProfile,
  userPassengerProfile,
}

extension AppRouteExt on AppRoutesEnum {
  String get name => toString().split('.')[1];

  String get path {
    switch (this) {
      case AppRoutesEnum.userDriverProfile:
        return '/user/driver';
      case AppRoutesEnum.userPassengerProfile:
        return '/user/passenger';
      case AppRoutesEnum.driverRideRequests:
        return '/driver-ride-requests';
      default:
        return '/${toString().split('.')[1]}';
    }
  }

  String pathWithId({String? id}) {
    if (id == null) {
      return path;
    }
    return '$path/$id';
  }

  String pathWithProfileId(int profileId) => '$path/$profileId';
}
