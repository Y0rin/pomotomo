import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../models/app_settings.dart';
import '../services/timer_service.dart';
import '../services/window_service.dart';
import '../widgets/background_layer.dart';
import '../widgets/timer_card.dart';
import '../widgets/task_list.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final settings = context.read<AppSettings>();
    final timer = context.read<TimerService>();
    settings.addListener(() {
      timer.updateDurations(settings.focusMinutes, settings.restMinutes);
    });
    timer.updateDurations(settings.focusMinutes, settings.restMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final timer = context.watch<TimerService>();

    if (settings.isMiniMode) {
      return _MiniModeView(timer: timer, settings: settings);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          const BackgroundLayer(),
          Column(
            children: [
              _TitleBar(settings: settings),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: const Column(
                    children: [
                      SizedBox(height: 8),
                      TimerCard(),
                      SizedBox(height: 4),
                      TaskList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  final AppSettings settings;
  const _TitleBar({required this.settings});

  @override
  Widget build(BuildContext context) {
    final accent = settings.accentColor;

    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.black.withValues(alpha: 0.3),
        child: Row(
          children: [
            Icon(Icons.timer_rounded, color: accent, size: 18),
            const SizedBox(width: 8),
            Text(
              'Pomotomo',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),

            // Minimize to taskbar
            _barButton(
              icon: Icons.minimize_rounded,
              accent: accent,
              onTap: () => windowManager.minimize(),
            ),
            const SizedBox(width: 4),

            // Mini mode
            _barButton(
              icon: Icons.picture_in_picture_alt_rounded,
              accent: accent,
              onTap: () {
                settings.isMiniMode = true;
                WindowService.enterMiniMode();
              },
            ),
            const SizedBox(width: 4),

            // Settings
            _barButton(
              icon: Icons.settings_rounded,
              accent: accent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            const SizedBox(width: 4),

            // Close
            _barButton(
              icon: Icons.close_rounded,
              accent: Colors.redAccent,
              onTap: () => windowManager.close(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barButton({
    required IconData icon,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: accent, size: 16),
      ),
    );
  }
}

class _MiniModeView extends StatelessWidget {
  final TimerService timer;
  final AppSettings settings;
  const _MiniModeView({required this.timer, required this.settings});

  @override
  Widget build(BuildContext context) {
    final accent = settings.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: GestureDetector(
        onPanStart: (_) => windowManager.startDragging(),
        onDoubleTap: () {
          settings.isMiniMode = false;
          WindowService.exitMiniMode();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: accent.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                timer.displayTime,
                style: TextStyle(
                  color: accent,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: timer.state == TimerState.focusing
                      ? accent
                      : timer.state == TimerState.resting
                          ? Colors.orangeAccent
                          : Colors.white24,
                ),
              ),
              const Spacer(),
              // Play/Pause
              GestureDetector(
                onTap: () {
                  if (timer.state == TimerState.idle) {
                    timer.startFocus();
                  } else {
                    timer.togglePause();
                  }
                },
                child: Icon(
                  timer.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              // Always show expand button
              GestureDetector(
                onTap: () {
                  settings.isMiniMode = false;
                  WindowService.exitMiniMode();
                },
                child: Icon(
                  Icons.fullscreen_exit_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}