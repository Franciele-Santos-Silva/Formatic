import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:formatic/features/auth/pages/login_page.dart';
import 'package:formatic/features/home/pages/home_page.dart';
import 'package:formatic/services/auth/auth_service.dart';
import 'package:formatic/services/core/supabase_config.dart';

import 'package:window_size/window_size.dart' as window_size;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    const ui.Size mobileSize = ui.Size(540, 1100);

    try {
      final screen = await window_size.getCurrentScreen();
      final screenFrame =
          screen?.visibleFrame ??
          ui.Rect.fromLTWH(0, 0, mobileSize.width * 2, mobileSize.height * 2);
      final left =
          screenFrame.left + (screenFrame.width - mobileSize.width) / 2;
      final top =
          screenFrame.top + (screenFrame.height - mobileSize.height) / 2;

      window_size.setWindowTitle('Formatic');
      window_size.setWindowFrame(
        ui.Rect.fromLTWH(left, top, mobileSize.width, mobileSize.height),
      );
      window_size.setWindowMinSize(const ui.Size(320, 600));
    } catch (e) {
      // ignore: avoid_print
      print('Could not set desktop window size: $e');
    }
  }

  await dotenv.load(fileName: ".env");

  await SupabaseConfig.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formatic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.blue.shade700,
          onPrimary: Colors.white,
          secondary: Colors.blue.shade200,
          onSecondary: Colors.white,
          error: Colors.red.shade400,
          onError: Colors.white,
          surface: const Color(0xFF232B36),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF232B36)),
        scaffoldBackgroundColor: const Color(0xFF232B36),
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: AuthService().currentUser != null
          ? HomePage(
              isDarkMode: _themeMode == ThemeMode.dark,
              onThemeToggle: _toggleTheme,
            )
          : LoginPage(onThemeToggle: _toggleTheme),
    );
  }
}
