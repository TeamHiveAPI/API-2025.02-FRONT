import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/data_table/content/pedidos_list.dart';
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(
            'Página Pedidos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: PedidosTable(
              searchQuery: '', 
              userRole: UserRole.coronel,
            ),
          ),
        ],
      ),
    );
  }
}
