import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/data_table/content/pedidos_list.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/services/subirEmpenho.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    UserService.instance.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    UserService.instance.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  final userService = UserService.instance;

  UserRole get _currentUserRole =>
      UserService.instance.currentUser?.role ?? UserRole.soldadoComum;

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

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GenericSearchInput(
                    onSearchChanged: _handleSearch,
                    hintText: 'Pesquisar',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            PedidosTable(key: ValueKey(userService.viewingSectorId), searchQuery: _searchQuery, userRole: _currentUserRole),
          ],
        ),
      ),
    );
  }
}
