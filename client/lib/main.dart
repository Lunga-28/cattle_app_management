import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'screens/dashboard_screen.dart';
import 'login_screen.dart';
import 'colors.dart';

void main() {
  runApp(CattleFarmApp());
}

class CattleFarmApp extends StatelessWidget {
  const CattleFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final String farmId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => DashboardScreen(farmId: farmId),
          );
        } else if (settings.name == '/finances') {
          final String farmId = settings.arguments as String;
          /*return MaterialPageRoute(
            builder: (context) => FinancePage(farmId: farmId),
          );*/
        }
        return null;
      },
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const loginScreen(),
      },
      theme: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFF4CAF50)), // Natural green
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: createMaterialColor(const Color(0xFF4CAF50)), // Primary green
          accentColor: const Color(0xFFFFC107), // Soft yellow
        ),
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
