import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/services/item_service.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_item_modal.dart';

class StockItemsTable extends StatefulWidget {
  final String? searchQuery;
  final UserRole? userRole;

  const StockItemsTable({super.key, this.searchQuery, this.userRole});

  @override
  State<StockItemsTable> createState() => _StockItemsTableState();
}

class _StockItemsTableState extends State<StockItemsTable> with TableHandler {
  final StockItemService _itemService = StockItemService();

  @override
  String get apiEndpoint => 'item';

  @override
  List<TableColumn> get tableColumns => [
        TableColumn(
          title: 'Nome do item',
          dataField: 'nome',
          widthFactor: 0.78,
          sortType: SortType.alphabetic,
        ),
        TableColumn(
          title: 'QTD',
          dataField: 'qtd_atual',
          widthFactor: 0.22,
          sortType: SortType.numeric,
        ),
      ];

  @override
  Future<PaginatedResponse> performFetch(
      int page, SortParams sortParams, String? searchQuery) {
    return _itemService.fetchItems(
      page: page,
      sortParams: sortParams,
      searchQuery: searchQuery,
      userRole: widget.userRole!,
    );
  }

  @override
  void initState() {
    super.initState();
    initTableHandler(initialSearchQuery: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(covariant StockItemsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      onSearchQueryChanged(widget.searchQuery ?? '');
    }
  }

  void _handleRowTap(Map<String, dynamic> itemData) {
    final grupoMap = itemData['grupo'];
    final nomeDoGrupo = (grupoMap != null)
        ? grupoMap['nome']?.toString() ?? 'Sem Grupo'
        : 'Sem Grupo';

    showCustomBottomSheet(
      context: context,
      title: "Detalhes do item",
      child: DetalhesItemModal(
        itemData: itemData,
        nome: itemData['nome']?.toString() ?? 'N/A',
        numFicha: itemData['num_ficha']?.toString() ?? 'N/A',
        unidMedida: itemData['unidade']?.toString() ?? 'N/A',
        qtdDisponivel: itemData['qtd_atual'] ?? 0,
        qtdReservada: itemData['qtd_reservada'] ?? 0,
        grupo: nomeDoGrupo,
        dataValidade: itemData['data_validade'],
        controlado: itemData['controlado'],
        userRole: widget.userRole!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton = isLoading && loadedItems.isEmpty;
    final List<Map<String, dynamic>> displayData =
        showSkeleton ? List.generate(8, (_) => {}) : loadedItems;

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
