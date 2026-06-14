import 'package:fellow_traveller_mobile/core/config/app_config.dart';

class PhotoUrlResolver {
  PhotoUrlResolver._();

  static String? resolve(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null;
    }

    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final base = AppConfig.baseUrl.endsWith('/')
        ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
        : AppConfig.baseUrl;
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }
}
