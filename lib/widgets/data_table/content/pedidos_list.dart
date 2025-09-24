import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/utils/api_simulator.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/base_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_pedido_modal.dart';

class PedidosTable extends StatefulWidget {
  final String? searchQuery;
  final UserRole userRole;

  const PedidosTable({super.key, this.searchQuery, required this.userRole});

  @override
  State<PedidosTable> createState() => _PedidosTableState();
}

class _PedidosTableState extends State<PedidosTable> with TableHandler {
  @override
  String get apiEndpoint {
    switch (widget.userRole) {
      case UserRole.tenenteFarmacia:
      case UserRole.soldadoFarmacia:
        return 'pedidos_farmacia';
      default:
        return 'pedido';
    }
  }

  @override
  List<TableColumn> get tableColumns => [
        TableColumn(
          title: 'Item',
          dataField: 'item_nome',
          widthFactor: 0.5,
          sortType: SortType.alphabetic,
        ),
        TableColumn(
          title: 'QTD',
          dataField: 'qnt_ped',
          widthFactor: 0.3,
          sortType: SortType.numeric,
        ),
        TableColumn(
          title: 'Status',
          dataField: 'estado_pedido',
          widthFactor: 0.3,
          sortType: SortType.alphabetic,
        ),
      ];

  String get _assetPathForRole {
    switch (widget.userRole) {
      case UserRole.tenenteFarmacia:
      case UserRole.soldadoFarmacia:
        return 'lib/temp/pedidos_farmacia.json';
      default:
        return 'lib/temp/pedido.json';
    }
  }

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) {
    return fetchItemsFromAsset(
      assetPath: _assetPathForRole,
      page: page,
      allColumns: tableColumns,
      sortParams: sortParams,
      searchQuery: searchQuery,
      searchFields: ['item_nome', 'num_ped'],
    );
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

  void _handleRowTap(Map<String, dynamic> pedidoData) {
    showCustomBottomSheet(
      context: context,
      title: "Detalhes do Pedido",
      child: DetalhesPedidoModal(
        Item_nome: pedidoData['item_nome']?.toString() ?? 'N/A',
        Num_ped: pedidoData['num_ped']?.toString() ?? 'N/A',
        Data_ret: DateTime.tryParse(pedidoData['data_ret'] ?? '') ?? DateTime.now(),
        Qnt_ped: pedidoData['qnt_ped']?.toString() ?? '0',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton = isLoading && loadedItems.isEmpty;

    final List<Map<String, dynamic>> displayData = showSkeleton
        ? List.generate(8, (_) => <String, dynamic>{})
        : loadedItems.map((item) {
            final dataString = item['data_ret']?.toString();
            DateTime? data = DateTime.tryParse(dataString ?? '');
            String estado;

            if (data == null) {
              estado = 'Pendente';
            } else {
              estado = data.isBefore(DateTime.now()) ? 'Finalizado' : 'Pendente';
            }

            return {
              ...item,
              'estado_pedido': estado,
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
