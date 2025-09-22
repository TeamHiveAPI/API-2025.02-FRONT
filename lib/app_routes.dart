import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/home.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const Login());
      case home:
        return MaterialPageRoute(builder: (_) => const Home());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Rota não encontrada')),
          ),
        );
    }
  }
}