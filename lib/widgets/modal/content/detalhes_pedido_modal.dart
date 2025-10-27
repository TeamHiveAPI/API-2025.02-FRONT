import 'package:flutter/material.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/constants/pedido_constants.dart';
import 'package:sistema_almox/services/pedido_service.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/content/finalizar_pedido_modal.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';

class DetalhesPedidoModal extends StatefulWidget {
  final int pedidoId;
  final Future<void> Function(int pedidoId) onFinalizar;
  final void Function(int idItem)? onViewItemDetails;
  final void Function(int userId)? onViewUserDetails;
  final VoidCallback? onViewOrderedItemsDetails;
  final VoidCallback? onShowCancelModal;
  final void Function(Map<String, dynamic> pedidoData)? onViewCancelDetails;

  const DetalhesPedidoModal({
    super.key,
    required this.pedidoId,
    required this.onFinalizar,
    this.onViewItemDetails,
    this.onViewOrderedItemsDetails,
    this.onViewUserDetails,
    this.onShowCancelModal,
    this.onViewCancelDetails,
  });

  @override
  State<DetalhesPedidoModal> createState() => _DetalhesPedidoModalState();
}

class _DetalhesPedidoModalState extends State<DetalhesPedidoModal> {
  Map<String, dynamic>? _pedidoData;
  bool _isLoadingInitialContent = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await PedidoService.instance.fetchPedidoById(widget.pedidoId);
    if (mounted) {
      setState(() {
        _pedidoData = data;
        _isLoadingInitialContent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoadingInitialContent && _pedidoData == null) {
      return const Center(
        child: Text('Pedido não encontrado ou erro ao carregar.'),
      );
    }

    final nomeUsuario =
        _pedidoData?[SupabaseTables.usuario]?[UsuarioFields.nome] ?? '';
    final idPedido = _pedidoData?[PedidoFields.id]?.toString() ?? '';
    final idUsuario = _pedidoData?[PedidoFields.usuarioId] ?? 0;
    final dataRet =
        _pedidoData?[PedidoFields.dataRetirada]?.toString() ?? 'Em aberto';
    final status = _pedidoData?[PedidoFields.status] ?? 1;
    final List<dynamic> itensPedido =
        (_pedidoData?[SupabaseTables.itemPedido] as List?) ?? const [];

    final isPendente = status == PedidoConstants.statusPendente;
    final isCancelado = status == PedidoConstants.statusCancelado;

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
        DetailItemCard(
          isLoading: _isLoadingInitialContent,
          label: "ITENS PEDIDOS",
          value: _isLoadingInitialContent ? '' : itensPedido.length.toString(),
          onPressed: _isLoadingInitialContent
              ? null
              : () {
                  if (widget.onViewOrderedItemsDetails != null) {
                    widget.onViewOrderedItemsDetails!();
                  }
                },
        ),

        const SizedBox(height: 12),
        DetailItemCard(
          isLoading: _isLoadingInitialContent,
          label: "PEDIDO POR",
          value: nomeUsuario,
          onPressed: _isLoadingInitialContent
              ? null
              : () {
                  if (widget.onViewUserDetails != null) {
                    widget.onViewUserDetails!(idUsuario);
                  }
                },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DetailItemCard(
                isLoading: _isLoadingInitialContent,
                label: "Nº DO PEDIDO",
                value: idPedido,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(
                isLoading: _isLoadingInitialContent,
                label: "STATUS",
                value: getStatusDescricao(),
                onPressed: (!isCancelado)
                    ? null
                    : () {
                        if (widget.onViewCancelDetails != null) {
                          widget.onViewCancelDetails!(_pedidoData!);
                        }
                      },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DetailItemCard(
          isLoading: _isLoadingInitialContent,
          label: "DATA DE RETIRADA",
          value: dataRet == 'Em aberto' ? dataRet : formatDate(dataRet),
        ),
        const SizedBox(height: 12),

        if (isPendente) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomButton(
                  isLoadingInitialContent: _isLoadingInitialContent,
                  text: "Finalizar",
                  onPressed: () async {
                    final DateTime dataAtual = DateTime.now();
                    final bool? confirmed = await showFinalizarPedidoModal(
                      context,
                      dataAtual,
                    );

                    if (confirmed == true) {
                      Navigator.of(context).pop();
                      await widget.onFinalizar(widget.pedidoId);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  isLoadingInitialContent: _isLoadingInitialContent,
                  text: "Cancelar",
                  secondary: true,
                  danger: true,
                  onPressed: widget.onShowCancelModal,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
