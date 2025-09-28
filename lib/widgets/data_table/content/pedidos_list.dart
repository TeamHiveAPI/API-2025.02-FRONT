import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_pedido_modal.dart';
import 'package:sistema_almox/widgets/modal/detalhes_usuario_modal.dart';
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

class _PedidosTableState extends State<PedidosTable> with TableHandler {
  final _pedidoService = PedidoService();

  @override
  String get apiEndpoint => 'pedidos';

  @override
  List<TableColumn> get tableColumns => [
    TableColumn(
      title: 'Nome do item',
      dataField: 'item_nome',
      widthFactor: 0.55,
      sortType: SortType.alphabetic,
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
      widthFactor: 0.25,
      sortType: SortType.alphabetic,
    ),
  ];

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) async {
    try {
      return await _pedidoService.fetchPedidos(
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
      await _pedidoService.cancelPedido(
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

      await _pedidoService.finalizePedido(
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
          pedidoId: pedidoData['id_pedido'],
          itemNome: pedidoData['item']?['nome']?.toString() ?? 'N/A',
          idPedido: pedidoData['id_pedido']?.toString() ?? 'N/A',
          idUsuario: pedidoData['id_usuario'],
          nomeUsuario: pedidoData['usuario']?['nome'] ?? 'Desconhecido',
          dataRet: pedidoData['data_ret']?.toString() ?? 'Em aberto',
          qtdSolicitada: pedidoData['qtd_solicitada']?.toString() ?? '0',
          status: pedidoData['status'] ?? 1,
          onCancelar: _cancelarPedido,
          onFinalizar: _finalizarPedido,

          onViewUserDetails: (userId) async {
            Navigator.of(context).pop();

            await showCustomBottomSheet(
              context: context,
              title: "Detalhes do Usuário",
              child: DetalhesUsuarioModal(idUsuario: userId),
            );
            showPedidoModal();
          },
        ),
      );
    }
    showPedidoModal();
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton = isLoading && loadedItems.isEmpty;

    final List<Map<String, dynamic>> displayData = showSkeleton
        ? List.generate(8, (_) => <String, dynamic>{})
        : loadedItems.map((item) {
            final status = item['status'] ?? 1;
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

            return {
              ...item,
              'item_nome': item['item']?['nome'] ?? 'N/A',
              'usuario_nome': item['usuario']?['nome'] ?? 'N/A',
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
