import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';

class MotivoCancelamentoModal extends StatelessWidget {
  final String motivo;
  final String responsavelNome;
  final int responsavelId;
  final void Function(int userId) onViewResponsavelDetails;

  const MotivoCancelamentoModal({
    super.key,
    required this.motivo,
    required this.responsavelNome,
    required this.responsavelId,
    required this.onViewResponsavelDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DetailItemCard(
          label: 'MOTIVO',
          value: motivo,
        ),
        const SizedBox(height: 12),
        DetailItemCard(
          label: 'RESPONSÁVEL',
          value: responsavelNome,
          onPressed: () => onViewResponsavelDetails(responsavelId),
        ),
      ],
    );
  }
}