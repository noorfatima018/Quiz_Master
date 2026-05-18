import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _soundsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundsEnabled => _soundsEnabled;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    // Here you would typically integrate with a notification service
    notifyListeners();
  }

  void toggleSounds(bool value) {
    _soundsEnabled = value;
    // This will be checked in the Quiz logic before playing sounds
    notifyListeners();
  }
}
