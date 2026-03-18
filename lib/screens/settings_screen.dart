import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../services/window_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final accent = settings.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Settings', style: TextStyle(color: accent)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: accent),
          onPressed: () {
            StorageService.saveSettings(settings);
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Background ---
          _sectionTitle('Background', accent),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _settingsButton(
                  label: 'Upload Image',
                  icon: Icons.image_rounded,
                  accent: accent,
                  onTap: () => _pickBackground(context, isVideo: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _settingsButton(
                  label: 'Upload Video',
                  icon: Icons.videocam_rounded,
                  accent: accent,
                  onTap: () => _pickBackground(context, isVideo: true),
                ),
              ),
            ],
          ),
          if (settings.backgroundPath != null) ...[
            const SizedBox(height: 8),
            _settingsButton(
              label: 'Clear Background',
              icon: Icons.delete_outline_rounded,
              accent: Colors.redAccent,
              onTap: () => settings.setBackground(null),
            ),
          ],
          const SizedBox(height: 24),

          // --- Card Opacity ---
          _sectionTitle('Card Opacity', accent),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.opacity_rounded, color: Colors.white54, size: 18),
              Expanded(
                child: Slider(
                  value: settings.cardOpacity,
                  min: 0.1,
                  max: 1.0,
                  activeColor: accent,
                  inactiveColor: Colors.white12,
                  onChanged: (val) => settings.cardOpacity = val,
                ),
              ),
              Text(
                '${(settings.cardOpacity * 100).round()}%',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Accent Color ---
          _sectionTitle('Accent Color', accent),
          const SizedBox(height: 8),
          ColorPicker(
            color: accent,
            onColorChanged: (color) => settings.accentColor = color,
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.primary: false,
              ColorPickerType.accent: true,
            },
            enableShadesSelection: false,
            columnSpacing: 6,
            borderRadius: 14,
            width: 28,
            height: 28,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),

          // --- Timer Durations ---
          _sectionTitle('Timer Durations', accent),
          const SizedBox(height: 8),
          _durationRow(
            label: 'Focus',
            value: settings.focusMinutes,
            accent: accent,
            onChanged: (val) => settings.focusMinutes = val,
          ),
          const SizedBox(height: 8),
          _durationRow(
            label: 'Rest',
            value: settings.restMinutes,
            accent: accent,
            onChanged: (val) => settings.restMinutes = val,
          ),
          const SizedBox(height: 24),

          // --- Window ---
          _sectionTitle('Window', accent),
          const SizedBox(height: 8),
          _toggleRow(
            label: 'Always on Top',
            value: settings.alwaysOnTop,
            accent: accent,
            onChanged: (val) {
              settings.alwaysOnTop = val;
              WindowService.setAlwaysOnTop(val);
            },
          ),
          const SizedBox(height: 8),
          _toggleRow(
            label: 'Locked Mini Mode',
            value: settings.lockedMiniMode,
            accent: accent,
            onChanged: (val) {
              settings.lockedMiniMode = val;
            },
          ),
          if (settings.isMiniMode) ...[
            const SizedBox(height: 8),
            _settingsButton(
              label: 'Exit Mini Mode',
              icon: Icons.fullscreen_exit_rounded,
              accent: accent,
              onTap: () {
                settings.isMiniMode = false;
                WindowService.exitMiniMode();
              },
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _pickBackground(BuildContext context, {required bool isVideo}) async {
    final result = await FilePicker.platform.pickFiles(
      type: isVideo ? FileType.video : FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      if (!context.mounted) return;
      final settings = context.read<AppSettings>();
      settings.setBackground(result.files.single.path!, isVideo: isVideo);
    }
  }

  Widget _sectionTitle(String text, Color accent) {
    return Text(
      text,
      style: TextStyle(
        color: accent,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  Widget _settingsButton({
    required String label,
    required IconData icon,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _durationRow({
    required String label,
    required int value,
    required Color accent,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.remove_rounded, color: accent, size: 20),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Text(
            '${value}m',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, color: accent, size: 20),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required String label,
    required bool value,
    required Color accent,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            activeTrackColor: accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}