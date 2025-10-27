import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_almox/widgets/badge.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class DetalhesMovimentacaoModal extends StatelessWidget {
  final Map<String, dynamic> operationData;
  final void Function(int idItem)? onViewItemDetails;
  final void Function(int userId)? onViewUserDetails;

  const DetalhesMovimentacaoModal({
    super.key,
    required this.operationData,
    this.onViewItemDetails,
    this.onViewUserDetails,
  });

  @override
  Widget build(BuildContext context) {
    final int itemId = operationData['item_id'];
    final int usuarioId = operationData['usuario_id'];
    final String nomeItem = operationData['nome_item'] ?? 'N/A';
    final int saldoOperacao = operationData['saldo_operacao'] ?? 0;
    final String dataString = operationData['data_operacao'] ?? '';
    final String nomeUsuario = operationData['nome_usuario'];
    final List<dynamic> detalhesLotes = operationData['detalhes_lotes'] ?? [];

    final String tipoMovimentacao;
    final String saldoFormatado;
    if (saldoOperacao > 0) {
      tipoMovimentacao = 'ENTRADA';
      saldoFormatado = '+$saldoOperacao';
    } else if (saldoOperacao < 0) {
      tipoMovimentacao = 'SAÍDA';
      saldoFormatado = '$saldoOperacao';
    } else {
      tipoMovimentacao = 'BALANÇO';
      saldoFormatado = '0';
    }

    String dataFormatada = 'Data indisponível';
    if (dataString.isNotEmpty) {
      try {
        final data = DateTime.parse(dataString);
        final dataLocal = data.toLocal();
        dataFormatada = DateFormat('dd/MM/yyyy HH:mm').format(dataLocal);
      } catch (e) {
        print("Erro ao formatar data: $e");
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DetailItemCard(
          label: "ITEM",
          value: nomeItem,
          onPressed: () {
            if (onViewItemDetails != null) {
              onViewItemDetails!(itemId);
            }
          },
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: DetailItemCard(label: "TIPO", value: tipoMovimentacao),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(
                label: "SALDO FINAL",
                value: saldoFormatado,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        DetailItemCard(label: "DATA E HORA", value: dataFormatada),

        const SizedBox(height: 12),

        DetailItemCard(
          label: "RESPONSÁVEL",
          value: nomeUsuario,
          onPressed: () {
            if (onViewUserDetails != null) {
              onViewUserDetails!(usuarioId);
            }
          },
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Text(
              'Lotes envolvidos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(width: 8),

            CustomBadge(
              text: detalhesLotes.length.toString().padLeft(2, '0'),
              backgroundColor: coolGray,
              textColor: text60,
              small: true,
            ),
          ],
        ),

        const SizedBox(height: 16),

        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 170.0),
          child: SingleChildScrollView(
            child: Column(
              children: detalhesLotes.asMap().entries.map((entry) {
                final int index = entry.key;
                final Map<String, dynamic> lote = entry.value;

                final tipoLote = lote['tipo'] ?? 'N/A';
                final qtdLote = lote['quantidade'] ?? 0;
                final codigoLote = lote['codigo_lote'] ?? 'Sem código';

                final String qtdFormatada = (tipoLote == 'SAÍDA')
                    ? '-$qtdLote'
                    : '+$qtdLote';

                Color cardBackgroundColor;
                Color badgeColor;

                switch (tipoLote) {
                  case 'ENTRADA':
                    cardBackgroundColor = Colors.green.shade50;
                    badgeColor = successGreen;
                    break;
                  case 'SAÍDA':
                    cardBackgroundColor = Colors.red.shade50;
                    badgeColor = deleteRed;
                    break;
                  case 'RESERVA':
                    cardBackgroundColor = Colors.orange.shade50;
                    badgeColor = Colors.orange.shade500;
                    break;
                  default:
                    cardBackgroundColor = coolGray;
                    badgeColor = Colors.grey.shade600;
                }

                return Container(
                  key: ValueKey('$codigoLote-$index'),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomBadge(
                            text: codigoLote,
                            backgroundColor: text40,
                          ),
                          const SizedBox(width: 8),
                          CustomBadge(
                            text: tipoLote,
                            backgroundColor: badgeColor,
                          ),
                        ],
                      ),

                      CustomBadge(
                        text: qtdFormatada,
                        backgroundColor: badgeColor,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
