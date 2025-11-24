import 'package:flutter/foundation.dart';

class AppEvents {
  static final ValueNotifier<int> stockUpdateNotifier = ValueNotifier(0);

  static void notifyStockUpdate() {
    stockUpdateNotifier.value++;
  }
}