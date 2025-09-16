import 'package:flutter/material.dart';
import 'package:sistema_almox/services/user_service.dart';
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
        final role = UserService.instance.currentUser!.role;
        return MaterialPageRoute(
          builder: (_) => NewOrderScreen(userRole: role),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Rota não encontrada'))),
        );
    }
  }
}
