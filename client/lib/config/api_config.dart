import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Web app
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      // Android emulator
      return 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      // iOS simulator
      return 'http://localhost:3000/api';
    } else {
      // Default fallback
      return 'http://localhost:3000/api';
    }
  }

  // Authentication endpoints
  static String get signIn => '$baseUrl/auth/signin';
  static String get signUp => '$baseUrl/auth/signup';
  static String get google => '$baseUrl/auth/google';

  // User endpoints
  static String get userProfile => '$baseUrl/user/profile';
  static String get changePassword => '$baseUrl/user/change-password';

  // Cattle endpoints
  static String get cattle => '$baseUrl/cattle';
  static String cattleById(String id) => '$baseUrl/cattle/$id';
  static String cattleHealthRecords(String id) => '$baseUrl/cattle/$id/health-records';

  // Feed endpoints
  static String get feeds => '$baseUrl/feed';
  static String get lowStockFeeds => '$baseUrl/feed/low-stock';
  static String feedById(String id) => '$baseUrl/feed/$id';
  static String adjustFeedStock(String id) => '$baseUrl/feed/$id/adjust-stock';

  // Health record endpoints
  static String get healthRecords => '$baseUrl/health';
  static String healthRecordById(String id) => '$baseUrl/health/$id';
  static String healthRecordsByCattle(String cattleId) => 
      '$baseUrl/health/cattle/$cattleId';

  // Finance endpoints
  static String get finances => '$baseUrl/finances';

  // Weather endpoint
  static String get weather => '$baseUrl/weather';
}