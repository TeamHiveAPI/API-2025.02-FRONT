import 'package:flutter/material.dart';
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/screens/fornecedor.dart';
import 'package:sistema_almox/screens/notaEmpenho.dart';
import 'package:sistema_almox/widgets/cards/admin_header.dart';
import 'package:sistema_almox/widgets/cards/management.dart';
import 'package:sistema_almox/screens/grupo.dart';

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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    ManagementCard(
                      iconPath: "assets/icons/users.svg",
                      name: 'Usuários',
                      description:
                          'Atualize informações dos usuários do sistema',
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.usuarios);
                      },
                    ),
                    const SizedBox(height: 16),
                    ManagementCard(
                      iconPath: "assets/icons/groups.svg",
                      name: 'Grupos',
                      description: 'Gerencie os grupos de itens de cada setor',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ManagementCard(
                      iconPath: "assets/icons/suppliers.svg",
                      name: 'Fornecedores',
                      description: 'Gerencie os fornecedores dos pedidos',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FornecedorScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ManagementCard(
                      iconPath: "assets/icons/suppliers.svg",
                      name: 'Notas de Empenho',
                      description:
                          'Gerencie o envio de notas de empenho para os fornecedores',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotaEmpenhoScreen(),
                          ),
                        );
                      },
                    ),
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
