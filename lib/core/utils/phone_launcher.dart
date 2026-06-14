import 'package:url_launcher/url_launcher.dart';

abstract final class PhoneLauncher {
  static Future<bool> call(String phone) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return false;
    }

    final uri = Uri(scheme: 'tel', path: '+$digits');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
