import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,

      width: double.infinity,
      height: double.infinity,

      child: const Center(
        child: Text(
          'Página Estoque',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: text40,
          ),
        ),
      ),
    );
  }
}
