import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/novo_pedido/index.dart';
import 'widgets/main_scaffold/index.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String newOrder = '/novo-pedido';

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
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Rota não encontrada'))),
        );
    }
  }
}
