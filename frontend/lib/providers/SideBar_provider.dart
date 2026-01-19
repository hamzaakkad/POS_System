import 'package:flutter/material.dart';

class SidebarProvider extends ChangeNotifier {
  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  void toggleSidebar() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
}
