import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSeleted = false;

  bool get isSelected => _isSeleted;

  set isSelected(bool value) {
    _isSeleted = value;
    notifyListeners();
  }
}
