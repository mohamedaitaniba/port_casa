import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/anomaly_provider.dart';
import 'theme/app_theme.dart';
import 'routes.dart';
import 'screens/auth/login_screen.dart';

class PortCasaApp extends StatelessWidget {
  const PortCasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnomalyProvider()),
      ],
      child: MaterialApp(
        title: 'Port Casa - Gestion des Anomalies',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
        onGenerateRoute: AppRoutes.generateRoute,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

