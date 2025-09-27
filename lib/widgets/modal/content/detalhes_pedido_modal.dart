import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/content/finalizar_pedido_modal.dart';
import 'package:sistema_almox/widgets/modal/content/cancelar_pedido_modal.dart';
import 'package:sistema_almox/core/constants/pedido_constants.dart';


class DetalhesPedidoModal extends StatelessWidget {
  final int pedidoId;
  final String itemNome;
  final String idPedido;
  final String dataRet;
  final String qtdSolicitada;
  final int status;
  final Future<void> Function(int pedidoId, String motivo) onCancelar;
  final Future<void> Function(int pedidoId) onFinalizar;

  const DetalhesPedidoModal({
    super.key,
    required this.pedidoId,
    required this.itemNome,
    required this.idPedido,
    required this.dataRet,
    required this.qtdSolicitada,
    required this.status,
    required this.onCancelar,
    required this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPendente = status == PedidoConstants.statusPendente;
    
    // ✅ ADICIONA FUNÇÃO PARA OBTER DESCRIÇÃO DO STATUS
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
        _buildDetailItem("ITEM REQUISITADO", itemNome),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _buildDetailItem("Nº DO PEDIDO", idPedido)),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem("STATUS", getStatusDescricao())), // ✅ NOVO
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                "DATA DE RETIRADA", 
                dataRet == 'Em aberto' ? dataRet : formatDate(dataRet)
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildDetailItem("QTD. SOLICITADA", qtdSolicitada)),
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
                      Navigator.of(context).pop(); // Fecha modal antes
                      await onFinalizar(pedidoId); // ✅ USA FUNÇÃO REAL
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
                    Navigator.of(context).pop();
                    showCancelarPedidoModal(
                      context,
                      idPedido: pedidoId.toString(),
                      cancelarPedido: (idPedido, motivo) async {
                        await onCancelar(pedidoId, motivo); // ✅ USA FUNÇÃO REAL
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