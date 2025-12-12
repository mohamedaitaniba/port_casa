import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/dashboard/dashboard.dart';
import 'screens/anomalies/anomalies_list.dart';
import 'screens/anomalies/new_anomaly.dart';
import 'screens/analytics/analytics_dashboard.dart';
import 'screens/analytics/department_analytics.dart';
import 'screens/notifications/notifications_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String anomalies = '/anomalies';
  static const String newAnomaly = '/anomalies/new';
  static const String anomalyDetails = '/anomalies/details';
  static const String analytics = '/analytics';
  static const String departmentAnalytics = '/analytics/department';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case main:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );
      case anomalies:
        return MaterialPageRoute(
          builder: (_) => const AnomaliesListScreen(),
        );
      case newAnomaly:
        return MaterialPageRoute(
          builder: (_) => const NewAnomalyScreen(),
        );
      case analytics:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsDashboard(),
        );
      case departmentAnalytics:
        return MaterialPageRoute(
          builder: (_) => const DepartmentAnalyticsScreen(),
        );
      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
    }
  }
}

