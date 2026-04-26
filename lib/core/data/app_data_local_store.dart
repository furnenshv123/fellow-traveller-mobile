import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

const String _CLASS_NAME = 'AppDataLocalStore';
const String _KEY = 'app_data_v1';

class AppDataLocalStore {
  static String? _installationId;
  static String? get installationId => _installationId;

  static Future<void> prepare() async {
    final dbDirectory = await getApplicationDocumentsDirectory();
    Hive.init(dbDirectory.path);
  }

  static Future<Box> _openBox() => Hive.openBox(_KEY);
}
