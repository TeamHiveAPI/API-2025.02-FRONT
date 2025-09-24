import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/data_table/content/pedidos_list.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final String _searchQuery = '';
  final UserRole _currentUserRole = UserRole.coronel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomButton(
              text: 'Registrar Novo Pedido',
              icon: Icons.add,
              widthPercent: 1.0,
              onPressed: () {
                Navigator.pushNamed(context, '/novo-pedido');
              },
            ),
            const SizedBox(height: 16),

            CustomButton(
              text: 'Meu Histórico de Pedidos',
              icon: Icons.history,
              widthPercent: 1.0,
              secondary: true,
              onPressed: () {},
            ),
            const SizedBox(height: 24),

            const Text(
              'Listagem de Pedidos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: text40,
              ),
            ),
            const SizedBox(height: 20),

            PedidosTable(searchQuery: _searchQuery, userRole: _currentUserRole),
          ],
        ),
      ),
    );
  }
}
