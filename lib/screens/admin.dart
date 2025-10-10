import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/cards/admin_header.dart';
import 'package:sistema_almox/widgets/cards/management.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40.0),
            const AdminHeaderCard(),

            const Spacer(),

            ManagementCard(
              iconPath: "assets/icons/users.svg",
              name: 'Usuários',
              description: 'Atualize informações dos usuários do sistema',
              onPressed: () {
                print('Card de Usuários pressionado!');
              },
            ),

            const SizedBox(height: 16),

            ManagementCard(
              iconPath: "assets/icons/groups.svg",
              name: 'Grupos',
              description: 'Gerencie os grupos de itens de cada setor',
              onPressed: () {
                print('Card de Grupos pressionado!');
              },
            ),
            const SizedBox(height: 16),

            ManagementCard(
              iconPath: "assets/icons/suppliers.svg",
              name: 'Fornecedores',
              description:
                  'Gerencie os fornecedores dos pedidos',
              onPressed: () {
                print('Card de Fornecedores pressionado!');
              },
            ),

            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
