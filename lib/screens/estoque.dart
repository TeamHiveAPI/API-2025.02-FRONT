import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/data_table/content/medicine_type_list.dart';
import 'package:sistema_almox/widgets/data_table/content/stock_list.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/modal/content/novo_item.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
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
    setState(() {});
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserRole = UserService.instance.currentUser!.role;

    final bool isPharmacyRole =
        currentUserRole == UserRole.tenenteFarmacia ||
        currentUserRole == UserRole.soldadoFarmacia;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomButton(
              text: isPharmacyRole
                  ? 'Adicionar Tipo de Lote'
                  : 'Adicionar novo item',
              icon: Icons.add,
              widthPercent: 1.0,
              onPressed: () {
                if (isPharmacyRole) {
                  // Ação para Farmácia
                } else {
                  // Ação para Almoxarifado
                }
              },
            ),
            const SizedBox(height: 24),

            Text(
              isPharmacyRole
                  ? 'Listagem de Medicamentos'
                  : 'Listagem do Inventário',
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
                    hintText: isPharmacyRole
                        ? 'Pesquisar por nome'
                        : 'Pesquisar por nome ou código',
                  ),
                ),

                const SizedBox(width: 20),
                CustomButton(
                  customIcon: "assets/icons/qr-code.svg",
                  squareMode: true,
                  onPressed: () {},
                ),
              ],
            ),

            SizedBox(height: 20),

            isPharmacyRole
                ? MedicineTypeTable(searchQuery: _searchQuery)
                : StockItemsTable(
                    searchQuery: _searchQuery,
                    userRole: currentUserRole,
                  ),
          ],
        ),
      ),
    );
  }
}
