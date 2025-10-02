import 'package:flutter/material.dart';
import 'package:sistema_almox/services/item_service.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';

class ItemLotesTable extends StatefulWidget {
  final int itemId;

  const ItemLotesTable({super.key, required this.itemId});

  @override
  State<ItemLotesTable> createState() => _ItemLotesTableState();
}

Color _getColorForDate(String? dateStr) {
  // Retorna cinza se a data for nula ou vazia.
  if (dateStr == null || dateStr.isEmpty) {
    return Colors.grey;
  }

  try {
    final now = DateTime.now();
    final expirationDate = DateTime.parse(dateStr);
    final difference = expirationDate.difference(now);
    final daysUntilExpiration = difference.inDays;

    // Se a data já passou, usa a cor mais urgente.
    if (daysUntilExpiration < 0) {
      return const Color(0xFF6a040f);
    }

    if (daysUntilExpiration < 60) {
      return const Color(0xFF6a040f); // Menos de 2 meses
    } else if (daysUntilExpiration < 122) { // Entre 2 e 4 meses
      return const Color(0xFFd00000);
    } else if (daysUntilExpiration < 244) { // Entre 4 e 8 meses
      return const Color(0xFFe85d04);
    } else if (daysUntilExpiration < 365) { // Entre 8 e 12 meses
      return const Color(0xFFffba08);
    } else if (daysUntilExpiration < 548) { // Entre 12 e 18 meses
      return const Color(0xFF7cb518);
    } else if (daysUntilExpiration < 730) { // Entre 18 e 24 meses
      return const Color(0xFF55a630);
    } else {
      return const Color(0xFF004b23); // Mais de 24 meses
    }
  } catch (e) {
    return Colors.purple;
  }
}

class _ItemLotesTableState extends State<ItemLotesTable> with TableHandler {
  @override
  List<TableColumn> get tableColumns => [
    TableColumn(
      title: 'Lote',
      dataField: 'codigo_lote',
      widthFactor: 0.45,
      sortType: SortType.alphabetic,
    ),
    TableColumn(
      title: 'Validade',
      dataField: 'data_validade',
      widthFactor: 0.3,
      sortType: SortType.alphabetic,
      cellBuilder: (value) {
        final dateStr = value as String?;
        return Text(
          formatDate(dateStr),
          style: TextStyle(
            color: _getColorForDate(dateStr),
            fontWeight: FontWeight.bold,
          ),
        );
      },
    ),
    TableColumn(
      title: 'QTD',
      dataField: 'qtd_atual',
      widthFactor: 0.2,
      sortType: SortType.numeric,
    ),
  ];

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) {
    return ItemService.instance.fetchLotesByItemId(
      itemId: widget.itemId,
      page: page,
      sortParams: sortParams,
    );
  }

  @override
  void initState() {
    super.initState();
    initTableHandler();
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton = isLoading && loadedItems.isEmpty;
    final List<Map<String, dynamic>> displayData = showSkeleton
        ? List.generate(5, (_) => {})
        : loadedItems;

    return DynamicJsonTable(
      jsonData: displayData,
      columns: tableColumns,
      isLoading: isLoading,
      showSkeleton: showSkeleton,
      totalResults: totalItems,
      canLoadMore: hasMore,
      onRowTap: null,
      onLoadMore: loadMoreData,
      onSort: handleSort,
      activeSortColumnDataField: activeSortColumnDataField,
      isAscending: isAscending,
      thisOrThatState: ThisOrThatSortState.none,
    );
  }
}
