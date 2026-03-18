import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowService {
  static const Size normalSize = Size(420, 700);
  static const Size miniSize = Size(220, 80);

  static Future<void> init() async {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: normalSize,
      minimumSize: miniSize,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAlwaysOnTop(true);
      await windowManager.show();
      await windowManager.focus();
    });
  }

  static Future<void> setAlwaysOnTop(bool value) async {
    await windowManager.setAlwaysOnTop(value);
  }

  static Future<void> enterMiniMode() async {
    await windowManager.setSize(miniSize);
    await windowManager.setMinimumSize(miniSize);
  }

  static Future<void> exitMiniMode() async {
    await windowManager.setMinimumSize(miniSize);
    await windowManager.setSize(normalSize);
  }
}