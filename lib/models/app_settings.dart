import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  // Timer durations in minutes
  int _focusMinutes = 25;
  int _restMinutes = 5;

  // Appearance
  Color _accentColor = Colors.tealAccent;
  double _cardOpacity = 0.5;
  String? _backgroundPath;
  bool _isVideo = false;

  // Window
  bool _alwaysOnTop = true;
  bool _lockedMiniMode = false;
  bool _isMiniMode = false;

  // Getters
  int get focusMinutes => _focusMinutes;
  int get restMinutes => _restMinutes;
  Color get accentColor => _accentColor;
  double get cardOpacity => _cardOpacity;
  String? get backgroundPath => _backgroundPath;
  bool get isVideo => _isVideo;
  bool get alwaysOnTop => _alwaysOnTop;
  bool get lockedMiniMode => _lockedMiniMode;
  bool get isMiniMode => _isMiniMode;

  // Setters with notification
  set focusMinutes(int val) {
    _focusMinutes = val;
    notifyListeners();
  }

  set restMinutes(int val) {
    _restMinutes = val;
    notifyListeners();
  }

  set accentColor(Color val) {
    _accentColor = val;
    notifyListeners();
  }

  set cardOpacity(double val) {
    _cardOpacity = val;
    notifyListeners();
  }

  void setBackground(String? path, {bool isVideo = false}) {
    _backgroundPath = path;
    _isVideo = isVideo;
    notifyListeners();
  }

  set alwaysOnTop(bool val) {
    _alwaysOnTop = val;
    notifyListeners();
  }

  set lockedMiniMode(bool val) {
    _lockedMiniMode = val;
    notifyListeners();
  }

  set isMiniMode(bool val) {
    _isMiniMode = val;
    notifyListeners();
  }
}