import 'dart:async';
import 'package:flutter/foundation.dart';

enum TimerState { idle, focusing, resting }

class TimerService extends ChangeNotifier {
  TimerState _state = TimerState.idle;
  int _remainingSeconds = 0;
  Timer? _timer;
  int _focusMinutes = 25;
  int _restMinutes = 5;
  int _completedPomodoros = 0;

  // Getters
  TimerState get state => _state;
  int get remainingSeconds => _remainingSeconds;
  int get completedPomodoros => _completedPomodoros;

  String get displayTime {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get progress {
    final total = _state == TimerState.focusing
        ? _focusMinutes * 60
        : _restMinutes * 60;
    if (total == 0) return 0;
    return 1.0 - (_remainingSeconds / total);
  }

  bool get isRunning => _timer != null && _timer!.isActive;

  // Update durations from settings
  void updateDurations(int focus, int rest) {
    _focusMinutes = focus;
    _restMinutes = rest;
    if (_state == TimerState.idle) {
      _remainingSeconds = _focusMinutes * 60;
      notifyListeners();
    }
  }

  // Start focus session
  void startFocus() {
    _state = TimerState.focusing;
    _remainingSeconds = _focusMinutes * 60;
    _startCountdown();
  }

  // Start rest session
  void startRest() {
    _state = TimerState.resting;
    _remainingSeconds = _restMinutes * 60;
    _startCountdown();
  }

  // Pause / Resume
  void togglePause() {
    if (isRunning) {
      _timer?.cancel();
    } else {
      _startCountdown();
    }
    notifyListeners();
  }

  // Stop and reset
  void stop() {
    _timer?.cancel();
    _state = TimerState.idle;
    _remainingSeconds = _focusMinutes * 60;
    notifyListeners();
  }

  // Skip current phase
  void skip() {
    _timer?.cancel();
    if (_state == TimerState.focusing) {
      _completedPomodoros++;
      startRest();
    } else {
      startFocus();
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _onPhaseComplete();
      }
    });
    notifyListeners();
  }

  void _onPhaseComplete() {
    if (_state == TimerState.focusing) {
      _completedPomodoros++;
      startRest();
    } else {
      startFocus();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}