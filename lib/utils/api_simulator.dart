import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:collection/collection.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'table_handler_mixin.dart';

const int _itemsPerPage = 8;

Future<PaginatedResponse> fetchItemsFromAsset({
  required String assetPath,
  required int page,
  required List<TableColumn> allColumns,
  required SortParams sortParams,
  String? searchQuery,
}) async {
  final String jsonString = await rootBundle.loadString(assetPath);
  final List<dynamic> allJsonData = json.decode(jsonString);
  List<Map<String, dynamic>> allItems = allJsonData.cast<Map<String, dynamic>>();

  // Filtro de pesquisa
  if (searchQuery != null && searchQuery.isNotEmpty) {
    final lowerCaseQuery = searchQuery.toLowerCase();
    allItems = allItems.where((item) {
      final itemNome = item['item_nome']?.toString().toLowerCase() ?? '';
      final numPed = item['num_ped']?.toString().toLowerCase() ?? '';
      final idPedido = item['id_pedido']?.toString() ?? '';
      return itemNome.contains(lowerCaseQuery) ||
             numPed.contains(lowerCaseQuery) ||
             idPedido.contains(lowerCaseQuery);
    }).toList();
  }

  // Ordenação
  _sortOnServer(allItems, allColumns, sortParams);

  // Paginação
  final int total = allItems.length;
  final int startIndex = (page - 1) * _itemsPerPage;
  final int endIndex = startIndex + _itemsPerPage;
  final paginatedItems = allItems.sublist(
    startIndex,
    endIndex > total ? total : endIndex,
  );

  return PaginatedResponse(items: paginatedItems, totalCount: total);
}

void _sortOnServer(
  List<Map<String, dynamic>> data,
  List<TableColumn> allColumns,
  SortParams sortParams,
) {
  if (sortParams.activeSortColumnDataField == null) return;

  final column = allColumns.firstWhereOrNull(
    (c) => c.dataField == sortParams.activeSortColumnDataField,
  );
  if (column == null) return;

  data.sort((a, b) {
    final valueA = a[column.dataField];
    final valueB = b[column.dataField];

    if (valueA == null) return sortParams.isAscending ? -1 : 1;
    if (valueB == null) return sortParams.isAscending ? 1 : -1;

    int comparison;
    // Tratar como numérico se o valor puder ser convertido
    final numA = num.tryParse(valueA.toString());
    final numB = num.tryParse(valueB.toString());

    if (column.sortType == SortType.numeric && numA != null && numB != null) {
      comparison = numA.compareTo(numB);
    } else {
      comparison = valueA.toString().toLowerCase().compareTo(
        valueB.toString().toLowerCase(),
      );
    }

    return sortParams.isAscending ? comparison : -comparison;
  });
}
