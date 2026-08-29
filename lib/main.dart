import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_locales.dart';

void main() {
  runApp(const ElderEaseApp());
}

class ElderEaseApp extends StatelessWidget {
  const ElderEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppLocales.version,
      builder: (context, _, __) => MaterialApp(
        title: 'ElderEase',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}