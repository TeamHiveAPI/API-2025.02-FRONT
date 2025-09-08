import 'package:flutter/material.dart';
import 'base_modals.dart';

class FiltrosModal extends StatelessWidget {
  const FiltrosModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      titulo: "Filtros",
      conteudo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Grupo"),
          DropdownButton<String>(
            value: "Todos",
            items: ["Todos", "Segurança", "vestimenta", "Ferramentas", "alimentação"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) {},
          ),
          const SizedBox(height: 16),
          const Text("Ordenar por"),
          CheckboxListTile(
            title: const Text("Ordem Alfabética"),
            value: true,
            onChanged: (_) {},
          ),
          CheckboxListTile(
            title: const Text("Quantidade"),
            value: false,
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          const Text("Ordem"),
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: const Text("Crescente"),
                  value: true,
                  groupValue: true,
                  onChanged: (_) {},
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: const Text("Decrescente"),
                  value: false,
                  groupValue: true,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
