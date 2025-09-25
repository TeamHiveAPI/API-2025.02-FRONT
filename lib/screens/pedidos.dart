import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/data_table/content/pedidos_list.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/main_scaffold/index.dart';
import 'package:sistema_almox/widgets/view_all_button.dart';


class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _searchQuery = '';
  final UserRole _currentUserRole = UserRole.coronel;

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // ação para histórico
                },
                label: const Text('Meu Histórico de Pedidos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7F9FF),
                  foregroundColor: const Color(0xFF2847AE),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Listagem de Pedidos do Sistema',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: text40,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GenericSearchInput(
                    onSearchChanged: _handleSearch, 
                    hintText: 'Pesquisar por nome, numero do pedido, status ou data (aaaa-mm-dd)',
                  ),
                ),
              ],
            ), 
            const SizedBox(height: 20),

            PedidosTable(
              searchQuery: _searchQuery,
              userRole: _currentUserRole,
            ),
          ],
        ),
      ),
    );
  }
}
