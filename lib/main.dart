import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
final ValueNotifier<String> languageNotifier = ValueNotifier('tl');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait so the rosary layout always looks correct.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const RosaryApp());
}

class RosaryApp extends StatelessWidget {
  const RosaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Santo Rosaryo',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5E6D3),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCA8A04),
              secondary: Color(0xFF991B1B),
              surface: Color(0xFFE5D3BD),
              error: Color(0xFF991B1B),
            ),
            textTheme: GoogleFonts.spectralTextTheme(
              ThemeData.light().textTheme,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1A0F0A),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFCA8A04),
              secondary: Color(0xFF991B1B),
              surface: Color(0xFF2C1A10),
              error: Color(0xFF991B1B),
            ),
            textTheme: GoogleFonts.spectralTextTheme(
              ThemeData.dark().textTheme,
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
