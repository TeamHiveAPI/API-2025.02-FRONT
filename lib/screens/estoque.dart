import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
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
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomButton(
              text: 'Adicionar novo item',
              icon: Icons.add,
              widthPercent: 1.0,
              onPressed: () => showNovoItemModal(context),
            ),
            const SizedBox(height: 24),

            const Text(
              'Listagem do Inventário',
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
                    hintText: 'Pesquisar por nome ou código',
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

            StockItemsTable(searchQuery: _searchQuery),
          ],
        ),
      ),
    );
  }
}
