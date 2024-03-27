
import 'package:flutter/material.dart';

class WaterLevelProvider with ChangeNotifier {
  double _tank1Level = 0.0;
  double _tank2Level = 0.0;
  double _tank3Level = 0.0;

  double get tank1Level => _tank1Level;
  double get tank2Level => _tank2Level;
  double get tank3Level => _tank3Level;


  void updateTank1LevelFromJson(dynamic jsonData) {
    // Assuming jsonData contains a field for the water level of tank 1
    if (jsonData['output'] != null) {
      _tank1Level = double.parse(jsonData['output'].toString());
      notifyListeners();
    }
  }

  void setTankLevel(int tankNumber, double level) {
    switch (tankNumber) {
      case 1:
        _tank1Level = level.clamp(0.0, 1.0);
        break;
      case 2:
        _tank2Level = level.clamp(0.0, 1.0);
        break;
      case 3:
        _tank3Level = level.clamp(0.0, 1.0);
        break;
    }
    notifyListeners();
  }
}
