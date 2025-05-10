import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int currentIndex = 0;

  selectedIndex(index) {
    currentIndex = index;
    notifyListeners();
  }
}
