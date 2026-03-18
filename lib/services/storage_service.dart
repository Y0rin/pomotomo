import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/task_model.dart';

class StorageService {
  static const _keyFocus = 'focus_minutes';
  static const _keyRest = 'rest_minutes';
  static const _keyAccent = 'accent_color';
  static const _keyOpacity = 'card_opacity';
  static const _keyBgPath = 'bg_path';
  static const _keyIsVideo = 'is_video';
  static const _keyAlwaysOnTop = 'always_on_top';
  static const _keyLockedMini = 'locked_mini';
  static const _keyTasks = 'tasks';

  static Future<void> loadSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    settings.focusMinutes = prefs.getInt(_keyFocus) ?? 25;
    settings.restMinutes = prefs.getInt(_keyRest) ?? 5;
    settings.cardOpacity = prefs.getDouble(_keyOpacity) ?? 0.5;
    settings.alwaysOnTop = prefs.getBool(_keyAlwaysOnTop) ?? true;
    settings.lockedMiniMode = prefs.getBool(_keyLockedMini) ?? false;

    final colorVal = prefs.getInt(_keyAccent);
    if (colorVal != null) {
      settings.accentColor = Color.fromARGB(
        (colorVal >> 24) & 0xFF,
        (colorVal >> 16) & 0xFF,
        (colorVal >> 8) & 0xFF,
        colorVal & 0xFF,
      );
    }

    final bgPath = prefs.getString(_keyBgPath);
    if (bgPath != null) {
      settings.setBackground(
        bgPath,
        isVideo: prefs.getBool(_keyIsVideo) ?? false,
      );
    }
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFocus, settings.focusMinutes);
    await prefs.setInt(_keyRest, settings.restMinutes);
    await prefs.setInt(_keyAccent, settings.accentColor.toARGB32());
    await prefs.setDouble(_keyOpacity, settings.cardOpacity);
    await prefs.setBool(_keyAlwaysOnTop, settings.alwaysOnTop);
    await prefs.setBool(_keyLockedMini, settings.lockedMiniMode);

    if (settings.backgroundPath != null) {
      await prefs.setString(_keyBgPath, settings.backgroundPath!);
      await prefs.setBool(_keyIsVideo, settings.isVideo);
    } else {
      await prefs.remove(_keyBgPath);
      await prefs.remove(_keyIsVideo);
    }
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyTasks);
    if (str == null) return [];
    return Task.decodeList(str);
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTasks, Task.encodeList(tasks));
  }
}