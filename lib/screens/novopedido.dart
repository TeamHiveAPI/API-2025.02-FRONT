import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/imputgeral.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Página Novo Pedido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: text40,
                ),
              ),
              const SizedBox(height: 24),
              CustomInput(
                hintText: 'Digite algo',
                iconPath: 'assets/icons/search.svg', // Exemplo de ícone SVG
              ),
              const SizedBox(height: 16),
              CustomInput(
                isCalendarMode: true,
                onDateSelected: (date) {
                  print('Data selecionada: $date');
                },
              ),
              const SizedBox(height: 16),
              CustomInput(
                hintText: 'Apenas números',
                onlyNumbers: true,
                iconPath: 'assets/icons/number.svg', // Exemplo de ícone SVG
              ),
            ],
          ),
        ),
      ),
    );
  }
}