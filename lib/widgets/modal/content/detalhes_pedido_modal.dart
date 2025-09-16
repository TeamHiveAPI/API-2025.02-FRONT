import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';

class DetalhesPedidoModal extends StatelessWidget {
  final String Item_nome;
  final String Num_ped;
  final DateTime Data_ret; 
  final String Qnt_ped;

  const DetalhesPedidoModal({
    super.key,
    required this.Item_nome,
    required this.Num_ped,
    required this.Data_ret,
    required this.Qnt_ped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ITEM REQUISITADO
        _buildDetailItem("ITEM REQUISITADO", Item_nome),
        const SizedBox(height: 12),

        // Nº DO PEDIDO + DATA DE RETIRADA
        Row(
          children: [
            Expanded(child: _buildDetailItem("Nº DO PEDIDO", Num_ped)),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem("DATA DE RETIRADA", Data_ret.toString().split(' ')[0])), // Formata a data para exibir apenas a parte da data
          ],
        ),
        const SizedBox(height: 12),

        // QTD SOLICITADA
        _buildDetailItem("QTD. SOLICITADA", Qnt_ped),
        const SizedBox(height: 24),

        // BOTÕES
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "Finalizar Pedido",
                onPressed: () {
                  // ação para finalizar pedido
                },
                isFullWidth: true,
                // Ex: customIcon: 'assets/icons/check.svg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: "Cancelar Pedido",
                onPressed: () {
                  // ação para cancelar pedido
                },
                secondary: true,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: text80,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: text40,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
