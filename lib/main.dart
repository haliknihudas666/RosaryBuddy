import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'providers/app_settings_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RosaryApp(),
    ),
  );
}

class RosaryApp extends ConsumerWidget {
  const RosaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Santo Rosaryo',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
