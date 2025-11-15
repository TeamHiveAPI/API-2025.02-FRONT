import 'package:flutter/material.dart';
import 'package:sistema_almox/screens/consultas/index.dart';
import 'package:sistema_almox/screens/consultas/agendar_consulta/index.dart';
import 'package:sistema_almox/screens/consultas_medico/index.dart';
import 'package:sistema_almox/screens/consultas_medico/config_horario.dart';
import 'package:sistema_almox/screens/historico_item.dart';
import 'package:sistema_almox/screens/historico_mov.dart';
import 'package:sistema_almox/screens/novo_grupo/index.dart';
import 'package:sistema_almox/screens/novo_item/index.dart';
import 'package:sistema_almox/screens/novo_soldado/index.dart';
import 'package:sistema_almox/screens/painelAnalitico.dart';
import 'package:sistema_almox/screens/usuarios/index.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'screens/login.dart';
import 'screens/novo_pedido/index.dart';
import 'widgets/main_scaffold/index.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String newOrder = '/novo-pedido';
  static const String newItem = '/novo-item';
  static const String usuarios = '/usuarios';
  static const String newSoldier = '/novo-soldado';
  static const String newGroup = '/novo-grupo';
  static const String allMovements = '/movimentacoes';
  static const String itemMovements = '/movimentacoes-item';
  static const String consultas = '/consultas';
  static const String agendarConsulta = '/agendar-consulta';
  static const String consultasMedico = '/consultas-medico';
  static const String configHorario = '/config-horario';
  static const String painelAnalitico = '/painel-analitico';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const Login());

      case home:
        return MaterialPageRoute(builder: (_) => const MainScaffold());

      case allMovements:
        return MaterialPageRoute(builder: (_) => const AllMovementsScreen());

      case painelAnalitico:
        return MaterialPageRoute(builder: (_) => const PainelAnaliticoScreen());

      case itemMovements:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => ItemMovementsScreen(
            itemName: args['itemName'] as String,
            availableQuantity: args['availableQuantity'] as int,
            reservedQuantity: args['reservedQuantity'] as int,
          ),
        );

      case newOrder:
        final role = UserService.instance.currentUser!.role;
        return MaterialPageRoute(
          builder: (_) => NewOrderScreen(userRole: role),
        );

      case newItem:
        final arguments = settings.arguments;
        if (arguments is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => NewItemScreen(itemToEdit: arguments),
          );
        } else {
          return MaterialPageRoute(builder: (_) => const NewItemScreen());
        }

      case newSoldier:
        final arguments = settings.arguments;
        if (arguments is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => NewSoldierScreen(soldierToEdit: arguments),
          );
        } else {
          return MaterialPageRoute(builder: (_) => const NewSoldierScreen());
        }

      case usuarios:
        return MaterialPageRoute(builder: (_) => const UsersScreen());

      case newGroup:
        return MaterialPageRoute(builder: (_) => NewGroupScreen());

      case consultas:
        return MaterialPageRoute(builder: (_) => const ConsultasScreen());

      case agendarConsulta:
        return MaterialPageRoute(builder: (_) => const AgendarConsultaScreen());

      case consultasMedico:
        return MaterialPageRoute(builder: (_) => const ConsultasMedicoScreen());

      case configHorario:
        return MaterialPageRoute(builder: (_) => const ConfigHorarioScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Rota não encontrada'))),
        );
    }
  }
}
