import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers.dart';
import '../../core/utils/arabic_digits.dart';
import '../../data/repositories/settings_repository.dart';
import '../../l10n/l10n.dart';
import 'notification_copy.dart';
import 'settings_controller.dart';

/// الإعدادات (§6.6).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.notificationTime,
    );
    if (picked != null && context.mounted) {
      final copy = notificationCopyOf(context.l10n);
      await ref
          .read(settingsProvider.notifier)
          .setNotificationTime(picked, copy);
    }
  }

  void _showAbout(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final contentDb = ref.read(contentDatabaseProvider).value;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsAbout),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.aboutMission),
              const SizedBox(height: 12),
              Text(l10n.aboutScholarNote),
              const SizedBox(height: 12),
              Text(l10n.aboutPrivacyNote),
              if (contentDb != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.aboutContentVersion(
                    arabicNumber(contentDb.schemaVersion),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final notificationsSupported =
        ref.read(notificationServiceProvider).isSupported;

    final timeLabel = toArabicDigits(
      MaterialLocalizations.of(context).formatTimeOfDay(
        settings.notificationTime,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
        children: [
          if (notificationsSupported && !kIsWeb) ...[
            SwitchListTile.adaptive(
              title: Text(l10n.settingsNotificationToggle),
              value: settings.notificationsEnabled,
              onChanged: (enabled) async {
                final copy = notificationCopyOf(l10n);
                if (enabled) {
                  final granted = await ref
                      .read(notificationServiceProvider)
                      .requestPermission();
                  if (!granted) return;
                }
                await controller.setNotificationsEnabled(enabled, copy);
              },
            ),
            ListTile(
              enabled: settings.notificationsEnabled,
              title: Text(l10n.settingsNotificationTime),
              trailing: Text(timeLabel, style: theme.textTheme.bodyMedium),
              onTap: () => _pickTime(context, ref),
            ),
          ] else
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
              child: Text(
                l10n.settingsNotificationWebNote,
                style: theme.textTheme.bodySmall,
              ),
            ),
          const Divider(height: 24),
          ListTile(title: Text(l10n.settingsTheme)),
          RadioGroup<ThemeMode>(
            groupValue: settings.themeMode,
            onChanged: (mode) {
              if (mode != null) controller.setThemeMode(mode);
            },
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: Text(l10n.settingsThemeLight),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: Text(l10n.settingsThemeDark),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text(l10n.settingsThemeAuto),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          ListTile(title: Text(l10n.settingsTextSize)),
          RadioGroup<AppTextSize>(
            groupValue: settings.textSize,
            onChanged: (size) {
              if (size != null) controller.setTextSize(size);
            },
            child: Column(
              children: [
                RadioListTile<AppTextSize>(
                  value: AppTextSize.normal,
                  title: Text(l10n.settingsTextSizeNormal),
                ),
                RadioListTile<AppTextSize>(
                  value: AppTextSize.large,
                  title: Text(l10n.settingsTextSizeLarge),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAbout),
            onTap: () => _showAbout(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(l10n.settingsShare),
            onTap: () => SharePlus.instance.share(
              ShareParams(text: l10n.shareAppText),
            ),
          ),
        ],
      ),
    );
  }
}
