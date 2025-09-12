import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/novopedido.dart';
import 'widgets/main_scaffold.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String newOrder = '/novopedido';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const Login());

      case home:
        return MaterialPageRoute(builder: (_) => const MainScaffold());

      case newOrder:
        return MaterialPageRoute(builder: (_) => const NewOrderScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Rota não encontrada')),
          ),
        );
    }
  }
}