import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivationProvider with ChangeNotifier {
  // --- The master activation code. You can change this to whatever you want. ---
  static const String _masterCode = 'K3y7277';
  static const String _activationKey = 'is_app_activated';

  bool _isActivated = false;

  bool get isActivated => _isActivated;

  ActivationProvider() {
    _loadActivationStatus();
  }

  // Loads the activation status from the device's storage.
  Future<void> _loadActivationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isActivated = prefs.getBool(_activationKey) ?? false;
    notifyListeners();
  }

  // Activates the app if the provided code is correct.
  Future<bool> activateApp(String code) async {
    if (code == _masterCode) {
      _isActivated = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_activationKey, true);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }
}
