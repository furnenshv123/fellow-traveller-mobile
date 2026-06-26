import 'package:url_launcher/url_launcher.dart';

abstract final class MapsRouteLauncher {
  static Uri buildRouteUri({
    required String from,
    required String to,
  }) {
    return Uri.https('www.google.com', '/maps/dir/', <String, String>{
      'api': '1',
      'origin': from.trim(),
      'destination': to.trim(),
      'travelmode': 'driving',
    });
  }

  static Future<bool> openRoute({
    required String from,
    required String to,
  }) async {
    final fromName = from.trim();
    final toName = to.trim();
    if (fromName.isEmpty || toName.isEmpty) {
      return false;
    }

    final uri = buildRouteUri(from: fromName, to: toName);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
