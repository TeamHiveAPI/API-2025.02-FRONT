import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/modal/content/base_modal.dart';
import '../widgets/modal/detalhes_item_modal.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Ver Detalhes do Item"),
              onPressed: () {
                showCustomBottomSheet(
                  context: context,
                  title: "Detalhes do Item",
                  child: const DetalhesItemModal(
                    nome: "Alicate",
                    numFicha: "POL49205",
                    unidMedida: "Pacote",
                    qtdDisponivel: 82,
                    qtdReservada: 24,
                    grupo: "Segurança",
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
