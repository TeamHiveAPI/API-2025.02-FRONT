import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/pedido_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/constants/pedido_constants.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_pedido_modal.dart';
import 'package:sistema_almox/widgets/modal/content/cancelar_pedido_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_item_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_itens_pedidos.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_usuario_modal.dart';
import 'package:sistema_almox/widgets/modal/content/motivo_cancelamento_modal.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:sistema_almox/utils/app_events.dart';
import 'package:sistema_almox/core/constants/database.dart';

class LastOrderCard extends StatefulWidget {
  const LastOrderCard({super.key});

  @override
  State<LastOrderCard> createState() => _LastOrderCardState();
}

class _LastOrderCardState extends State<LastOrderCard> {
  int _refreshKey = 0;

  void _refreshData() {
    setState(() {
      _refreshKey++;
    });
  }

  Future<void> _cancelarPedido(int pedidoId, String motivo) async {
    try {
      await PedidoService.instance.cancelPedido(
        pedidoId: pedidoId,
        motivoCancelamento: motivo,
      );

      if (mounted) {
        showCustomSnackbar(context, 'Pedido cancelado com sucesso!');
        _refreshData();
        AppEvents.notifyStockUpdate();
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, e.toString(), isError: true);
      }
    }
  }

  Future<void> _finalizarPedido(int pedidoId) async {
    try {
      final hoje = DateTime.now();
      final dataFormatada = hoje.toIso8601String().split('T')[0];

      await PedidoService.instance.finalizePedido(
        pedidoId: pedidoId,
        dataRetirada: dataFormatada,
      );

      if (mounted) {
        showCustomSnackbar(context, 'Pedido finalizado com sucesso!');
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, e.toString(), isError: true);
      }
    }
  }

  Future<dynamic> _showMotivoCancelamentoFlow(
    Map<String, dynamic> pedidoData,
  ) async {
    dynamic resultFromModal;
    do {
      resultFromModal = await showCustomBottomSheet(
        context: context,
        title: "Motivo do Cancelamento",
        child: MotivoCancelamentoModal(
          motivo:
              pedidoData[PedidoFields.motivoCancelamento] ?? 'Não especificado',
          responsavelId: pedidoData[PedidoFields.responsavelCancelamentoId],
          onViewResponsavelDetails: (userId) {
            Navigator.of(context).pop(userId);
          },
        ),
      );

      if (resultFromModal is int) {
        await showCustomBottomSheet(
          context: context,
          title: "Detalhes do Usuário",
          child: DetalhesUsuarioModal(idUsuario: resultFromModal),
        );
      }
    } while (resultFromModal is int);

    return resultFromModal;
  }

  void _handleRowTap(Map<String, dynamic> pedidoData) {
    void showPedidoModal() {
      showCustomBottomSheet(
        context: context,
        title: "Detalhes do Pedido",
        child: DetalhesPedidoModal(
          pedidoId: pedidoData['id'],
          onFinalizar: _finalizarPedido,
          onShowCancelModal: () async {
            Navigator.of(context).pop();
            final motivo = await showCancelarPedidoModal(
              context,
              idPedido: pedidoData['id'].toString(),
            );
            if (motivo != null && motivo.isNotEmpty) {
              await _cancelarPedido(pedidoData['id'], motivo);
            } else {
              showPedidoModal();
            }
          },
          onViewItemDetails: (itemId) async {
            Navigator.of(context).pop();
            final result = await showCustomBottomSheet(
              context: context,
              title: "Detalhes do Item",
              child: DetalhesItemModal(itemId: itemId),
            );
            if (result == null) showPedidoModal();
          },
          onViewOrderedItemsDetails: () async {
            Navigator.of(context).pop();
            final result = await showCustomBottomSheet(
              context: context,
              title: "Conteúdo do Pedido",
              removeRightPadding: true,
              child: DetalhesItensPedidoModal(
                itens: pedidoData['item_pedido'],
                onViewItemDetails: (itemId) async {
                  Navigator.of(context).pop('navigateToItem');
                  final itemResult = await showCustomBottomSheet(
                    context: context,
                    title: "Detalhes do Item",
                    child: DetalhesItemModal(itemId: itemId),
                  );
                  if (itemResult == null) {
                    showPedidoModal();
                  }
                },
              ),
            );
            if (result == null) {
              showPedidoModal();
            }
          },
          onViewUserDetails: (userId) async {
            Navigator.of(context).pop();
            final result = await showCustomBottomSheet(
              context: context,
              title: "Detalhes do Usuário",
              child: DetalhesUsuarioModal(idUsuario: userId),
            );
            if (result == null) showPedidoModal();
          },
          onViewCancelDetails: (Map<String, dynamic> currentPedidoData) async {
            Navigator.of(context).pop();
            final result = await _showMotivoCancelamentoFlow(currentPedidoData);
            if (result == null) {
              showPedidoModal();
            }
          },
        ),
      );
    }

    showPedidoModal();
  }

  @override
  Widget build(BuildContext context) {
    final userRole =
        UserService.instance.currentUser?.role ?? UserRole.soldadoComum;

    return FutureBuilder<PaginatedResponse>(
      key: ValueKey(_refreshKey),
      future: PedidoService.instance.fetchPedidos(
        page: 1,
        sortParams: SortParams(
          activeSortColumnDataField: null,
          isAscending: false,
          thisOrThatState: ThisOrThatSortState.none,
        ),
        userRole: userRole,
        onlyMyOrders: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerPlaceholder(height: 88);
        }

        if (snapshot.hasError || (snapshot.data?.items.isEmpty ?? true)) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: brightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/icons/box.svg',
                  width: 32,
                  height: 32,
                  color: Colors.grey.shade600,
                ),
                SizedBox(height: 12),
                Text(
                  "Você ainda não fez pedidos.",
                  style: TextStyle(color: text80),
                ),
              ],
            ),
          );
        }

        final lastOrder = snapshot.data!.items.first;

        final status = lastOrder['ped_status'];
        String statusText = 'Desconhecido';
        Color statusColor = text80;

        switch (status) {
          case PedidoConstants.statusPendente:
            statusText = 'Pendente';
            statusColor = text60;
            break;
          case PedidoConstants.statusConcluido:
            statusText = 'Concluído';
            statusColor = successGreen;
            break;
          case PedidoConstants.statusCancelado:
            statusText = 'Cancelado';
            statusColor = deleteRed;
            break;
        }

        final itens = (lastOrder['item_pedido'] as List?) ?? [];

        return Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: InkWell(
              onTap: () => _handleRowTap(lastOrder),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "PEDIDO #${lastOrder['id']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: text40,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(16),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.list_alt, size: 16, color: text60),
                        const SizedBox(width: 4),
                        Text(
                          "${itens.length} itens",
                          style: const TextStyle(color: text60, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
