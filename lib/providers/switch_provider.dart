import 'package:flutter/material.dart';

class SwitchProvider with ChangeNotifier {
  bool isSwitchedOn = false;

  void toggleSwitch(bool value) {
    isSwitchedOn = value;
    notifyListeners(); // Notifica a todos los widgets que dependen de este estado
  }
  void resetSwitch() {
    isSwitchedOn = false;
    notifyListeners();
  }
}
