import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/constants/database.dart';
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
  @override
  @override
  List<TableColumn> get tableColumns => [
    TableColumn(
      title: 'Nome do item',
      dataField: 'it_nome',
      widthFactor: 0.82,
      sortType: SortType.alphabetic,
    ),
    TableColumn(
      title: 'QTD',
      dataField: 'qtd_total_lotes',
      widthFactor: 0.18,
      sortType: SortType.numeric,
    ),
  ];

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) {
    return ItemService.instance.fetchItems(
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
    final int? itemId = itemData[ItemFields.id];

    if (itemId == null) {
      print(
        "Erro: O ID do item não pôde ser encontrado para abrir os detalhes.",
      );
      return;
    }

    showCustomBottomSheet(
      context: context,
      title: "Detalhes do item",
      child: DetalhesItemModal(itemId: itemId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton = isLoading && loadedItems.isEmpty;
    final List<Map<String, dynamic>> displayData = showSkeleton
        ? List.generate(8, (_) => {})
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
