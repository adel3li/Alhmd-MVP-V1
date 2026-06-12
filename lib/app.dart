import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/router.dart';
import 'core/theme/theme.dart';
import 'features/settings/settings_controller.dart';
import 'l10n/l10n.dart';

class AlhamdApp extends ConsumerWidget {
  const AlhamdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      // Arabic-only, RTL throughout (§1, §3.3): locale AND an explicit
      // Directionality wrapper, so Material widgets localize correctly and
      // direction can never silently fall back to LTR.
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        // «كبير» multiplies on top of the OS accessibility scale (§6.6).
        final appScale = settings.textSize.scaleFactor;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(
                mediaQuery.textScaler.scale(appScale),
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
