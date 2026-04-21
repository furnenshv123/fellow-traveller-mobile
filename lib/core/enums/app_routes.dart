enum AppRoutesEnum { login, driverMain, passengerMain, splash }

extension AppRouteExt on AppRoutesEnum {
  String get name => toString().split('.')[1];
  String get path => '/${toString().split('.')[1]}';
  String pathWithId({String? id}) {
    if (id == null) {
      return path;
    }
    return '$path/$id';
  }
}
