import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/imputgeral.dart';
import 'package:sistema_almox/widgets/titleheader.dart';
import 'package:sistema_almox/widgets/buttonaddfooter.dart';
import 'package:sistema_almox/widgets/cardpedido.dart'; 

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderComponent(title: 'Registrar Novo Pedido'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ITEM REQUISITADO Section
                  const Text(
                    'ITEM REQUISITADO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF606060),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomInput(
                    hintText: 'Digite algo',
                    iconPath: 'assets/icons/lupa.svg',
                  ),
                  const SizedBox(height: 16),

                  // QUANTIDADE Section
                  const Text(
                    'QUANTIDADE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF606060),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomInput(
                    hintText: 'Digite a quantidade',
                    // Removed onlyNumbers: true to allow text and numbers
                  ),
                  const SizedBox(height: 16),

                  // OrderCard Section
                  OrderCard(
                    isSelectionMode: false,
                    title: 'Produto Exemplo',
                    unit: 'Litros',
                    requested: '10 litros',
                    available: '50 unidades',
                    onTitleChanged: (value) {
                      print('Título alterado: $value');
                    },
                    onRequestedChanged: (value) {
                      print('Requisitado alterado: $value');
                    },
                    onAvailableChanged: (value) {
                      print('Disponível alterado: $value');
                    },
                  ),
                  const SizedBox(height: 16),

                  // DATA DE RETIRADA Section
                  const Text(
                    'DATA DE RETIRADA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF606060),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomInput(
                    isCalendarMode: true,
                    onDateSelected: (date) {
                      print('Data selecionada: $date');
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            FooterComponent(
              buttonText: 'Adicionar Pedido',
              onButtonPressed: () {
                print('Registrar Pedido');
              },
            ),
          ],
        ),
      ),
    );
  }
}