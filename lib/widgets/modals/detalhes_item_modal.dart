import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';

class DetalhesItemModal extends StatelessWidget {
  final String nome;
  final String numFicha;
  final String unidMedida;
  final int qtdDisponivel;
  final int qtdReservada;
  final String grupo;

  const DetalhesItemModal({
    super.key,
    required this.nome,
    required this.numFicha,
    required this.unidMedida,
    required this.qtdDisponivel,
    required this.qtdReservada,
    required this.grupo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDetailItem("NOME", nome),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _buildDetailItem("Nº DA FICHA", numFicha)),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem("UNIDADE DE MEDIDA", unidMedida)),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
                child:
                    _buildDetailItem("QTD. DISPONÍVEL", qtdDisponivel.toString())),
            const SizedBox(width: 12),
            Expanded(
                child:
                    _buildDetailItem("QTD. RESERVADA", qtdReservada.toString())),
          ],
        ),
        const SizedBox(height: 12),

        _buildDetailItem("GRUPO", grupo),
        const SizedBox(height: 24),

        CustomButton(
          text: "Ver Histórico de Movimentação",
          onPressed: () {},
          isFullWidth: true,
          svgIconPath: 'assets/icons/list.svg',
          iconPosition: IconPosition.right,
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "Editar",
                onPressed: () {},
                secondary: true,
                isFullWidth: true,
                svgIconPath: 'assets/icons/edit.svg',
                iconPosition: IconPosition.right,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: CustomButton(
                text: "QR Code",
                onPressed: () {},
                secondary: true,
                isFullWidth: true,
                svgIconPath: 'assets/icons/download.svg',
                iconPosition: IconPosition.right,
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