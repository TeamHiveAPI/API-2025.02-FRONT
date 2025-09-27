import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/content/finalizar_pedido_modal.dart';
import 'package:sistema_almox/widgets/modal/content/cancelar_pedido_modal.dart';


class DetalhesPedidoModal extends StatelessWidget {
  final String itemNome;
  final String idPedido;
  final String dataRet;
  final String qtdSolicitada;

  const DetalhesPedidoModal({
    super.key,
    required this.itemNome,
    required this.idPedido,
    required this.dataRet,
    required this.qtdSolicitada,
  });

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: _buildDetailItem("DATA DE RETIRADA", formatDate(dataRet)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _buildDetailItem("QTD. SOLICITADA", qtdSolicitada),
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
                    try {
                      await finalizarPedido(idPedido);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pedido finalizado com sucesso!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erro ao finalizar pedido: $e',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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
                    idPedido: idPedido,
                    cancelarPedido: cancelarPedido,
                  );
                },
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

Future<void> cancelarPedido(String numPed, String motivo) async {}

Future<void> finalizarPedido(String numPed) async {}
