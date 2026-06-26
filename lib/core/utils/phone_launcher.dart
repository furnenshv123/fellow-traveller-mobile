import 'package:url_launcher/url_launcher.dart';

abstract final class PhoneLauncher {
  static String? normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return null;
    }

    var normalized = digits;
    if (normalized.startsWith('80') && normalized.length == 11) {
      normalized = '375${normalized.substring(2)}';
    } else if (normalized.length == 9) {
      normalized = '375$normalized';
    }

    return '+$normalized';
  }

  static Uri? buildTelUri(String phone) {
    final normalized = normalizePhone(phone);
    if (normalized == null) {
      return null;
    }

    return Uri.parse('tel:$normalized');
  }

  static Future<bool> call(String phone) async {
    final uri = buildTelUri(phone);
    if (uri == null) {
      return false;
    }

    return launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}
