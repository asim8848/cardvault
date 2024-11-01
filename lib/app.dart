import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/welcome_screen.dart';
import 'utils/theme.dart';

class AppVault extends StatelessWidget {
  const AppVault({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Vault',
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
      onGenerateRoute: (settings) {
        if (AppRoutes.routes.containsKey(settings.name)) {
          return MaterialPageRoute(
            builder: AppRoutes.routes[settings.name]!,
            settings: settings,
          );
        }
        // Handle dynamic routes
        if (settings.name == AppRoutes.bankDetailsView ||
            settings.name == AppRoutes.bankEditDetail) {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null) {
            return MaterialPageRoute(
              builder: (context) => AppRoutes.routes[settings.name]!(context),
              settings: settings,
            );
          }
        }
        // If the route is not found, show an error screen or default route
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
      },
    );
  }
}
