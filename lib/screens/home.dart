import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/data_table/content/stock_list.dart';

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
              'Estoque Teste',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: text40,
              ),
            ),
            SizedBox(height: 16),
            StockItemsTable(),
          ],
        ),
      ),
    );
  }
}
