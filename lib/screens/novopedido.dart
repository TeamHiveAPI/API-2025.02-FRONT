import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/imputgeral.dart';
import 'package:sistema_almox/widgets/titleheader.dart';
import 'package:sistema_almox/widgets/buttonaddfooter.dart';

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
                  CustomInput(
                    hintText: 'Digite algo',
                    iconPath: 'assets/icons/lupa.svg',
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