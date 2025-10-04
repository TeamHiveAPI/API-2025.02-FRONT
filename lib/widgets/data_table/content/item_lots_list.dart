import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

bool _hasExpired(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) {
    return false;
  }
  try {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expirationDate = DateTime.parse(dateStr);

    return !expirationDate.isAfter(today);
  } catch (e) {
    return false;
  }
}

Color _getColorForDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) {
    return Colors.grey;
  }

  try {
    final now = DateTime.now();
    final expirationDate = DateTime.parse(dateStr);
    final daysUntilExpiration = expirationDate.difference(now).inDays;

    const int urgentThreshold = 60;
    const int midPoint = 120;
    const int safeThreshold = 300;
    const int verySafeThreshold = 730;

    const Color redColor = Color(0xFFd00000);
    const Color orangeColor = Colors.orange;
    const Color yellowColor = Color(0xFFffba08);
    const Color lightGreenColor = Color.fromARGB(255, 24, 175, 62);
    const Color darkGreenColor = Color(0xFF004b23);

    if (daysUntilExpiration >= verySafeThreshold) {
      return darkGreenColor;
    }

    if (daysUntilExpiration < urgentThreshold) {
      // Segmento 1: Vermelho -> Laranja (0 a 2 meses)
      final double range = urgentThreshold.toDouble();
      final double current = daysUntilExpiration.toDouble().clamp(0.0, range);
      final double t = current / range;
      return Color.lerp(redColor, orangeColor, t)!;
    } else if (daysUntilExpiration < midPoint) {
      // Segmento 2: Laranja -> Amarelo (2 a 4 meses)
      final double range = (midPoint - urgentThreshold).toDouble();
      final double current = (daysUntilExpiration - urgentThreshold).toDouble();
      final double t = (current / range).clamp(0.0, 1.0);
      return Color.lerp(orangeColor, yellowColor, t)!;
    } else if (daysUntilExpiration < safeThreshold) {
      // Segmento 3: Amarelo -> Verde Claro (4 a 10 meses)
      final double range = (safeThreshold - midPoint).toDouble();
      final double current = (daysUntilExpiration - midPoint).toDouble();
      final double t = (current / range).clamp(0.0, 1.0);
      return Color.lerp(yellowColor, lightGreenColor, t)!;
    } else {
      // Segmento 4: Verde Claro -> Verde Escuro (10 a 24 meses)
      final double range = (verySafeThreshold - safeThreshold).toDouble();
      final double current = (daysUntilExpiration - safeThreshold).toDouble();
      final double t = (current / range).clamp(0.0, 1.0);
      return Color.lerp(lightGreenColor, darkGreenColor, t)!;
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
      widthFactor: 0.35,
      sortType: SortType.alphabetic,
      cellBuilder: (value) {
        final dateStr = value as String?;
        final bool hasExpired = _hasExpired(dateStr);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatDate(dateStr),
              style: TextStyle(
                color: _getColorForDate(dateStr),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasExpired) ...[
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/icons/warning.svg',
                colorFilter: const ColorFilter.mode(
                  Color(0xFFd00000),
                  BlendMode.srcIn,
                ),
                width: 20,
                height: 20,
              ),
            ],
          ],
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
