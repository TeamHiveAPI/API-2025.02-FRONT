import 'package:flutter/material.dart';
import 'package:sistema_almox/utils/api_simulator.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/content/base_modal.dart';
import 'package:sistema_almox/widgets/modal/detalhes_item_modal.dart';

class StockItemsTable extends StatefulWidget {
  const StockItemsTable({super.key});

  @override
  State<StockItemsTable> createState() => _StockItemsTableState();
}

class _StockItemsTableState extends State<StockItemsTable> with TableHandler {
  @override
  List<TableColumn> get tableColumns => [
        TableColumn(
          title: 'Nome do Item',
          dataField: 'itemName',
          widthFactor: 0.5,
          sortType: SortType.alphabetic,
        ),
        TableColumn(
          title: 'QTD',
          dataField: 'quantity',
          widthFactor: 0.2,
          sortType: SortType.numeric,
        ),
        TableColumn(
          title: 'Status',
          dataField: 'status',
          widthFactor: 0.3,
          sortType: SortType.thisOrThat,
          primarySortValue: 'Pendente',
          secondarySortValue: 'Finalizado',
        ),
      ];

  @override
  Future<PaginatedResponse> performFetch(int page, SortParams sortParams) {
    return fetchItemsFromAsset(
      assetPath: 'lib/temp/estoque.json',
      page: page,
      allColumns: tableColumns,
      sortParams: sortParams,
    );
  }

  @override
  void initState() {
    super.initState();
    initTableHandler();
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