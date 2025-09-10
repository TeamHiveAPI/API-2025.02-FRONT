import 'package:flutter/material.dart';
import 'package:sistema_almox/utils/api_simulator.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/content/base_modal.dart';
import 'package:sistema_almox/widgets/modal/detalhes_item_modal.dart';

class StockItemsTable extends StatefulWidget {
  final String? searchQuery;
  const StockItemsTable({super.key, this.searchQuery});

  @override
  State<StockItemsTable> createState() => _StockItemsTableState();
}

class _StockItemsTableState extends State<StockItemsTable> with TableHandler {
  @override
  List<TableColumn> get tableColumns => [
    TableColumn(
      title: 'Nome do Item',
      dataField: 'itemName',
      widthFactor: 0.78,
      sortType: SortType.alphabetic,
    ),
    TableColumn(
      title: 'QTD',
      dataField: 'quantity',
      widthFactor: 0.22,
      sortType: SortType.numeric,
    ),
  ];

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) {
    return fetchItemsFromAsset(
      assetPath: 'lib/temp/estoque.json',
      page: page,
      allColumns: tableColumns,
      sortParams: sortParams,
      searchQuery: searchQuery,
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
    showCustomBottomSheet(
      context: context,
      title: "Detalhes do Item",
      child: DetalhesItemModal(
        nome: itemData['itemName']?.toString() ?? 'N/A',
        numFicha: itemData['numFicha']?.toString() ?? 'N/A',
        unidMedida: itemData['unidMedida']?.toString() ?? 'N/A',
        qtdDisponivel: itemData['quantity'] ?? 0,
        qtdReservada: itemData['qtdReservada'] ?? 0,
        grupo: itemData['grupo']?.toString() ?? 'N/A',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton = isLoading && loadedItems.isEmpty;

    final List<Map<String, dynamic>> displayData = showSkeleton
        ? List.generate(8, (_) => <String, dynamic>{})
        : loadedItems;

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
