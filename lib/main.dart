import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'models/app_settings.dart';
import 'services/timer_service.dart';
import 'services/storage_service.dart';
import 'services/window_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await WindowService.init();

  final settings = AppSettings();
  await StorageService.loadSettings(settings);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => TimerService()),
      ],
      child: const PomotomoApp(),
    ),
  );
}
