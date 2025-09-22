import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'widgets/main_scaffold/index.dart'; 

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const Login());
      
      case home:
        return MaterialPageRoute(builder: (_) => const MainScaffold());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Rota não encontrada')),
          ),
        );
    }
  }
}