import 'package:flutter/material.dart';
import 'package:sistema_almox/utils/api_simulator.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';

class MedicineTypeTable extends StatefulWidget {
  final String? searchQuery;

  const MedicineTypeTable({super.key, this.searchQuery});

  @override
  State<MedicineTypeTable> createState() => _MedicineTypeTableState();
}

class _MedicineTypeTableState extends State<MedicineTypeTable>
    with TableHandler {
  @override
  String get apiEndpoint => '';

  @override
  List<TableColumn> get tableColumns => [
    TableColumn(
      title: 'Nome',
      dataField: 'typeName',
      widthFactor: 0.5,
      sortType: SortType.alphabetic,
    ),
    TableColumn(
      title: 'Contr.',
      dataField: 'controlado',
      widthFactor: 0.3,
      formatter: (value) {
        if (value is bool) {
          return value ? 'Sim' : 'Não';
        }
        return '';
      },
      sortType: SortType.thisOrThat,
      primarySortValue: "true",
      secondarySortValue: "false",
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
      assetPath: 'lib/temp/medicamento_tipo.json',
      page: page,
      allColumns: tableColumns,
      sortParams: sortParams,
      searchQuery: searchQuery,
      searchFields: ['typeName'],
    );
  }

  @override
  void initState() {
    super.initState();
    initTableHandler(initialSearchQuery: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(covariant MedicineTypeTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      onSearchQueryChanged(widget.searchQuery ?? '');
    }
  }

  void _handleRowTap(Map<String, dynamic> itemData) {}

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
