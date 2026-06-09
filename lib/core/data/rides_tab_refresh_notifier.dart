import 'package:flutter/foundation.dart';

class RidesTabRefreshNotifier extends ChangeNotifier {
  void requestRefresh() => notifyListeners();
}
