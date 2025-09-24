import 'package:flutter/foundation.dart';

class SectorService with ChangeNotifier {
  SectorService._privateConstructor();
  static final SectorService instance = SectorService._privateConstructor();

  int? _currentSectorId;

  int? get currentSectorId => _currentSectorId;

  void setSector(int? sectorId) {
    _currentSectorId = sectorId;
    notifyListeners();
  }

  void clearSector() {
    _currentSectorId = null;
    notifyListeners();
  }
}