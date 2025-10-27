import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/cancelar_pedido_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_item_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_itens_pedidos.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_pedido_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_usuario_modal.dart';
import 'package:sistema_almox/widgets/modal/content/motivo_cancelamento_modal.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:sistema_almox/services/pedido_service.dart';
import 'package:sistema_almox/core/constants/pedido_constants.dart';

class PedidosTable extends StatefulWidget {
  final String? searchQuery;
  final UserRole userRole;

  const PedidosTable({super.key, this.searchQuery, required this.userRole});

  @override
  State<PedidosTable> createState() => _PedidosTableState();
}

Color _getStatusColor(String statusDescricao) {
  switch (statusDescricao) {
    case 'Pendente':
      return text60;
    case 'Concluído':
      return successGreen;
    case 'Cancelado':
      return deleteRed;
    default:
      return text80;
  }
}

class _PedidosTableState extends State<PedidosTable> with TableHandler {
  @override
  @override
  List<TableColumn> get tableColumns => [
    TableColumn(
      title: 'N° de itens',
      dataField: 'num_itens_display',
      widthFactor: 0.5,
      sortType: SortType.numeric,
    ),
    TableColumn(
      title: 'QTD',
      dataField: 'qtd_solicitada',
      widthFactor: 0.2,
      sortType: SortType.numeric,
    ),
    TableColumn(
      title: 'Status',
      dataField: 'status_descricao',
      widthFactor: 0.3,
      sortType: SortType.alphabetic,
      cellBuilder: (value) {
        final status = value.toString();
        final statusColor = _getStatusColor(status);

        return Text(
          status,
          style: TextStyle(fontWeight: FontWeight.w600, color: statusColor),
          textAlign: TextAlign.start,
        );
      },
    ),
  ];

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) async {
    try {
      return await PedidoService.instance.fetchPedidos(
        page: page,
        sortParams: sortParams,
        searchQuery: searchQuery,
        userRole: widget.userRole,
      );
    } catch (e) {
      print('Erro ao carregar pedidos: $e');
      return PaginatedResponse(items: [], totalCount: 0);
    }
  }

  @override
  void initState() {
    super.initState();
    initTableHandler(initialSearchQuery: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(covariant PedidosTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      onSearchQueryChanged(widget.searchQuery ?? '');
    }
  }

  Future<void> _cancelarPedido(int pedidoId, String motivo) async {
    try {
      await PedidoService.instance.cancelPedido(
        pedidoId: pedidoId,
        motivoCancelamento: motivo,
      );

      if (mounted) {
        showCustomSnackbar(context, 'Pedido cancelado com sucesso!');
        onSearchQueryChanged(widget.searchQuery ?? '');
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
        onSearchQueryChanged(widget.searchQuery ?? '');
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, e.toString(), isError: true);
      }
    }
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
    } while (resultFromModal
        is int);

    return resultFromModal;
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton = isLoading && loadedItems.isEmpty;

    final List<Map<String, dynamic>> displayData = showSkeleton
        ? List.generate(8, (_) => <String, dynamic>{})
        : loadedItems.map((item) {
            final status = item[PedidoFields.status] ?? 1;
            String statusDescricao;

            switch (status) {
              case PedidoConstants.statusPendente:
                statusDescricao = 'Pendente';
                break;
              case PedidoConstants.statusConcluido:
                statusDescricao = 'Concluído';
                break;
              case PedidoConstants.statusCancelado:
                statusDescricao = 'Cancelado';
                break;
              default:
                statusDescricao = 'Desconhecido';
            }

            final List<dynamic> itensPedido =
                (item[SupabaseTables.itemPedido] as List?) ?? const [];
            final int numItens = itensPedido.length;
            final String numItensDisplay = numItens.toString().padLeft(2, '0');
            final int qtdTotalSolicitada = itensPedido.fold<int>(0, (acc, it) {
              final q = (it[ItemPedidoFields.qtdSolicitada] ?? 0);
              return acc + (q is num ? q.toInt() : int.tryParse('$q') ?? 0);
            });

            return {
              ...item,
              'num_itens_display': numItensDisplay,
              'qtd_solicitada': qtdTotalSolicitada,
              'usuario_nome':
                  item[SupabaseTables.usuario]?[UsuarioFields.nome] ?? 'N/A',
              'status_descricao': statusDescricao,
            };
          }).toList();

    return DynamicJsonTable(
      jsonData: displayData,
      columns: tableColumns,
      isLoading: isLoading,
      showSkeleton: showSkeleton,
      totalResults: totalItems,
      canLoadMore: hasMore,
      onRowTap: showSkeleton ? null : _handleRowTap,
      onLoadMore: loadMoreData,
      onSort: handleSort,
      activeSortColumnDataField: activeSortColumnDataField,
      isAscending: isAscending,
      thisOrThatState: thisOrThatState,
    );
  }
}
