import 'package:flutter/material.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/content/finalizar_pedido_modal.dart';
import 'package:sistema_almox/widgets/modal/content/cancelar_pedido_modal.dart';
import 'package:sistema_almox/core/constants/pedido_constants.dart';
import 'package:sistema_almox/widgets/modal/detail_item_card.dart';

class DetalhesPedidoModal extends StatelessWidget {
  final int pedidoId;
  final String itemNome;
  final String idPedido;
  final int idUsuario;
  final String nomeUsuario;
  final String dataRet;
  final String qtdSolicitada;
  final int status;
  final Future<void> Function(int pedidoId, String motivo) onCancelar;
  final Future<void> Function(int pedidoId) onFinalizar;
  final void Function(int userId)? onViewUserDetails;

  const DetalhesPedidoModal({
    super.key,
    required this.pedidoId,
    required this.itemNome,
    required this.idUsuario,
    required this.nomeUsuario,
    required this.idPedido,
    required this.dataRet,
    required this.qtdSolicitada,
    required this.status,
    required this.onCancelar,
    required this.onFinalizar,
    this.onViewUserDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPendente = status == PedidoConstants.statusPendente;

    String getStatusDescricao() {
      switch (status) {
        case PedidoConstants.statusPendente:
          return 'Pendente';
        case PedidoConstants.statusConcluido:
          return 'Concluído';
        case PedidoConstants.statusCancelado:
          return 'Cancelado';
        default:
          return 'Desconhecido';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DetailItemCard(label: "ITEM REQUISITADO", value: itemNome),
        const SizedBox(height: 12),
        DetailItemCard(
          label: "PEDIDO POR",
          value: nomeUsuario,
          onPressed: () {
            if (onViewUserDetails != null) {
              onViewUserDetails!(idUsuario);
            }
          },
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: DetailItemCard(label: "Nº DO PEDIDO", value: idPedido),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(
                label: "STATUS",
                value: getStatusDescricao(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: DetailItemCard(
                label: "DATA DE RETIRADA",
                value: dataRet == 'Em aberto' ? dataRet : formatDate(dataRet),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(
                label: "QTD. SOLICITADA",
                value: qtdSolicitada,
              ),
            ),
          ],
        ),

        if (isPendente) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomButton(
                  text: "Finalizar",
                  onPressed: () async {
                    final DateTime dataAtual = DateTime.now();
                    final bool? confirmed = await showFinalizarPedidoModal(
                      context,
                      dataAtual,
                    );

                    if (confirmed == true) {
                      Navigator.of(context).pop();
                      await onFinalizar(pedidoId);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: "Cancelar",
                  secondary: true,
                  danger: true,
                  onPressed: () {
                    showCancelarPedidoModal(
                      context,
                      idPedido: pedidoId.toString(),
                      cancelarPedido: (idPedido, motivo) async {
                        await onCancelar(pedidoId, motivo);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
