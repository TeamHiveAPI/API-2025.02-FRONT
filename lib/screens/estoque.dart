import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/screens/qrcode.dart';
import 'package:sistema_almox/services/item_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/data_table/content/stock_list.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/mod_estoque_nao_perecivel.dart';
import 'package:sistema_almox/widgets/modal/content/mod_estoque_perecivel.dart';
import 'package:sistema_almox/widgets/modal/content/novo_item_modal.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    UserService.instance.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    UserService.instance.removeListener(_onUserChanged);
    _searchController.dispose();
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

  Future<void> scanQrCodeForModification() async {
    final String? scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrPage()),
    );

    if (scannedCode == null || !mounted) return;

    final itemData = await ItemService.instance.fetchItemByFicha(scannedCode);
    final currentContext = context;

    if (!mounted) return;

    if (itemData == null) {
      showCustomSnackbar(
        currentContext,
        'O Nº de Ficha escaneado não pertence a nenhum item.',
        isError: true,
      );
      return;
    }

    final isPerishable = itemData['it_perecivel'] as bool? ?? false;

    final String title = "Modificar Estoque";
    final Widget child = isPerishable
        ? ModifyPerishableStockModal(
            itemData: itemData,
          )
        : ModifyNonPerishableStockModal(
            itemData: itemData,
          );

    final result = await showCustomBottomSheet<bool>(
      context: currentContext,
      title: title,
      child: child,
    );

    if (!mounted) return;

    if (result == true) {
      showCustomSnackbar(currentContext, 'Estoque atualizado com sucesso!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userService = UserService.instance;

    final currentUserRole = userService.currentUser!.role;
    final bool isViewingPharmacy = userService.viewingSectorId == 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomButton(
              text: 'Cadastrar Novo Item',
              icon: Icons.add,
              widthPercent: 1.0,
              onPressed: () {
                showNewStockItemModal(
                  context,
                  onScanForModification: scanQrCodeForModification,
                );
              },
            ),
            const SizedBox(height: 24),

            Text(
              isViewingPharmacy
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
                    controller: _searchController,
                    onSearchChanged: _handleSearch,
                  ),
                ),

                SizedBox(width: 20),

                CustomButton(
                  customIcon: "assets/icons/qr-code.svg",
                  squareMode: true,
                  onPressed: () async {
                    final String? scannedCode = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (context) => const QrPage()),
                    );
                    if (scannedCode != null && mounted) {
                      final String cleanCode = scannedCode.trim();
                      _searchController.text = cleanCode;
                      _handleSearch(cleanCode);
                    }
                  },
                ),
              ],
            ),

            SizedBox(height: 20),

            StockItemsTable(
              key: ValueKey(userService.viewingSectorId),
              searchQuery: _searchQuery,
              userRole: currentUserRole,
            ),
          ],
        ),
      ),
    );
  }
}
