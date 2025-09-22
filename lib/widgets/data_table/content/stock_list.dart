import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/utils/api_simulator.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/base_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_item_modal.dart';

class StockItemsTable extends StatefulWidget {
  final String? searchQuery;
  final UserRole userRole;

  const StockItemsTable({super.key, this.searchQuery, required this.userRole});

  @override
  State<StockItemsTable> createState() => _StockItemsTableState();
}

class _StockItemsTableState extends State<StockItemsTable> with TableHandler {
  @override
  String get apiEndpoint {
    switch (widget.userRole) {
      case UserRole.tenenteFarmacia:
      case UserRole.soldadoFarmacia:
        return 'farmacia';
      default:
        return 'estoque';
    }
  }

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

  String get _assetPathForRole {
    switch (widget.userRole) {
      case UserRole.tenenteFarmacia:
        return 'lib/temp/farmacia.json';
      case UserRole.soldadoFarmacia:
        return 'lib/temp/farmacia.json';
      case UserRole.coronel:
        return 'lib/temp/almoxarifado.json';
      case UserRole.tenenteEstoque:
        return 'lib/temp/almoxarifado.json';
      case UserRole.soldadoEstoque:
        return 'lib/temp/almoxarifado.json';
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
      searchFields: ['itemName', 'numFicha']
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
