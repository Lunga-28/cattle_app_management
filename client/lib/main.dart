import 'package:cattle_management_app/screens/feed_screen.dart';
import 'package:cattle_management_app/screens/finances_screen.dart';
import 'package:cattle_management_app/screens/inventory_screen.dart';
import 'package:cattle_management_app/screens/weather_screen.dart';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'screens/dashboard_screen.dart';
import 'login_screen.dart';
import 'colors.dart';
import 'screens/health_screen.dart';

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
          return MaterialPageRoute(
            builder: (context) => DashboardScreen(),
          );
        } else if (settings.name == '/finances') {
          return MaterialPageRoute(
            builder: (context) => FinancesScreen(),
          );
        } else if (settings.name == '/inventory') {
          return MaterialPageRoute(
            builder: (context) => InventoryScreen(),
          );
        } else if (settings.name == '/weather') {
          return MaterialPageRoute(
            builder: (context) => WeatherScreen(),
          );
        } else if (settings.name == '/health') {
          return MaterialPageRoute(
            builder: (context) => HealthScreen(),
          );
        }else if (settings.name == '/feed') {
          return MaterialPageRoute(
            builder: (context) => FeedScreen(),
          );
        }

        return null;
      },
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
      theme: ThemeData(
        primarySwatch:
            createMaterialColor(const Color(0xFF4CAF50)), // Natural green
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch:
              createMaterialColor(const Color(0xFF4CAF50)), // Primary green
          accentColor: const Color(0xFFFFC107), // Soft yellow
        ),
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
