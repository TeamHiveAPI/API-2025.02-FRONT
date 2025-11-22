import 'package:flutter/material.dart';
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/screens/fornecedor.dart';
import 'package:sistema_almox/screens/notaEmpenho.dart';
import 'package:sistema_almox/screens/painel_analitico/index.dart';
import 'package:sistema_almox/widgets/cards/admin_header.dart';
import 'package:sistema_almox/widgets/cards/management.dart';
import 'package:sistema_almox/screens/grupo.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': "assets/icons/users.svg",
        'name': 'Usuários',
        'action': () => Navigator.of(context).pushNamed(AppRoutes.usuarios),
      },
      {
        'icon': "assets/icons/groups.svg",
        'name': 'Grupos',
        'action': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GroupsScreen()),
            ),
      },
      {
        'icon': "assets/icons/supplier.svg",
        'name': 'Fornecedores',
        'action': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FornecedorScreen()),
            ),
      },
      {
        'icon': "assets/icons/paper.svg",
        'name': 'Notas de Empenho',
        'action': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotaEmpenhoScreen()),
            ),
      },
      {
        'icon': "assets/icons/panel.svg",
        'name': 'Painel Analítico',
        'action': () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PainelAnaliticoScreen()),
            ),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40.0),
            const AdminHeaderCard(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ...menuItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ManagementCard(
                          iconPath: item['icon'] as String,
                          name: item['name'] as String,
                          onPressed: item['action'] as VoidCallback,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}