import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../services/timer_service.dart';

class TimerCard extends StatelessWidget {
  const TimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerService>();
    final settings = context.watch<AppSettings>();
    final accent = settings.accentColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: settings.cardOpacity),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _phaseLabel(timer.state),
            style: TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: timer.state == TimerState.idle ? 0 : timer.progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
                Text(
                  timer.displayTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${timer.completedPomodoros} pomodoros done',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (timer.state == TimerState.idle)
                _buildButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'Focus',
                  accent: accent,
                  onTap: timer.startFocus,
                )
              else ...[
                _buildButton(
                  icon: timer.isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: timer.isRunning ? 'Pause' : 'Resume',
                  accent: accent,
                  onTap: timer.togglePause,
                ),
                const SizedBox(width: 12),
                _buildButton(
                  icon: Icons.skip_next_rounded,
                  label: 'Skip',
                  accent: accent,
                  onTap: timer.skip,
                ),
                const SizedBox(width: 12),
                _buildButton(
                  icon: Icons.stop_rounded,
                  label: 'Stop',
                  accent: accent,
                  onTap: timer.stop,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _phaseLabel(TimerState state) {
    switch (state) {
      case TimerState.idle:
        return 'READY';
      case TimerState.focusing:
        return 'FOCUSING';
      case TimerState.resting:
        return 'RESTING';
    }
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}