import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/dynamic_table/tables/last_movimentations.dart';
import 'package:sistema_almox/widgets/dynamic_table/tables/stock_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 64),
            Text(
              'Últimas Movimentações',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: text40,
              ),
            ),

            SizedBox(height: 12),
            LastMovimentationsTable(),

            SizedBox(height: 48),
            Text(
              'Estoque Teste',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: text40,
              ),
            ),
            SizedBox(height: 12),
            StockItemsTable(),
          ],
        ),
      ),
    );
  }
}
