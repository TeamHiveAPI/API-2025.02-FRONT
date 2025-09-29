import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/utils/api_simulator.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';

class RecentMovementsTable extends StatefulWidget {
  const RecentMovementsTable({super.key});

  @override
  State<RecentMovementsTable> createState() => _RecentMovementsTableState();
}

class _RecentMovementsTableState extends State<RecentMovementsTable>
    with TableHandler {
      
  @override
  String get apiEndpoint => 'movimentacoes/recentes';

  @override
  List<TableColumn> get tableColumns => [
        TableColumn(
          title: 'Nome do item',
          dataField: 'item_name',
          widthFactor: 0.55,
        ),
        TableColumn(
          title: 'QTD',
          dataField: 'quantity',
          widthFactor: 0.2,
          cellBuilder: (value) {
            final isPositive = value.toString().startsWith('+');
            return Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isPositive ? successGreen : deleteRed,
              ),
            );
          },
        ),
        TableColumn(
          title: 'Responsável',
          dataField: 'responsible',
          widthFactor: 0.3,
        ),
      ];

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) {
    return getRecentMovements();
  }

  @override
  void initState() {
    super.initState();
    initTableHandler();
  }

  void _handleRowTap(Map<String, dynamic> itemData) {
    print("Item clicado: $itemData");
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton = isLoading && loadedItems.isEmpty;

    final List<Map<String, dynamic>> displayData =
        showSkeleton ? List.generate(2, (_) => {}) : loadedItems;

    return DynamicJsonTable(
      jsonData: displayData,
      columns: tableColumns,
      isLoading: isLoading,
      showSkeleton: showSkeleton,
      hidePagination: true,
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