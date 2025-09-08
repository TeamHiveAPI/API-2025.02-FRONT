import 'package:flutter/material.dart';
import '../widgets/modals/filtro_modal.dart';
import '../widgets/modals/detalhes_item_modal.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exemplo Modais")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton
            (
              style: IconButton.styleFrom
              (
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                showDialog
                (
                  context: context,
                  builder: (_) => const FiltrosModal(),
                );
              },
              icon: const Icon(Icons.filter_alt_sharp),
            ),

            const SizedBox(height: 20),
            // ElevatedButton(
            //   child: const Text("Abrir Detalhes do Item"),
            //   onPressed: () {
            //     showDialog(
            //       context: context,
            //       builder: (_) => const DetalhesItemModal(
            //         nome: "Alicate",
            //         n_ficha: "POL49205",
            //         un_medida: "Pacote",
            //         qtdDisponivel: 82,
            //         qtdReservada: 24,
            //         grupo: "Segurança",
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
