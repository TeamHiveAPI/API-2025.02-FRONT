import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomButton(
            text: 'Adicionar novo item',
            icon: Icons.add,
            widthPercent: 1.0,
            onPressed: () {},
          ),

          const SizedBox(height: 24),

          Text(
            'Listagem do Inventário',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: text40,
            ),
          ),
        ],
      ),
    );
  }
}
