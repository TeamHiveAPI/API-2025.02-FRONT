import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/modal/base_center_modal.dart';

Future<bool?> showFinalizarPedidoModal(
  BuildContext context,
  DateTime dataAtual,
) {
  return showCustomDialog(
    context: context,
    title: 'Finalizar Pedido',
    primaryButtonText: 'Confirmar',
    child: Column(
      children: [
        const Text(
          'Deseja realmente finalizar este pedido? A data de retirada será o dia atual:',
          style: TextStyle(color: text60, fontSize: 14),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: brightGray,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            formatDate(dataAtual),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: text60,
            ),
          ),
        ),
      ],
    ),
  );
}
