import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:collection/collection.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/core/constants/pedido_constants.dart';
import 'table_handler_mixin.dart';

const int _itemsPerPage = 8;

Future<PaginatedResponse> fetchItemsFromAsset({
  required String assetPath,
  required int page,
  required List<TableColumn> allColumns,
  required SortParams sortParams,
  String? searchQuery,
  required List<String> searchFields,
}) async {
  final String jsonString = await rootBundle.loadString(assetPath);
  final List<dynamic> allJsonData = json.decode(jsonString);
  List<Map<String, dynamic>> allItems = allJsonData.cast<Map<String, dynamic>>();

  // Pesquisa genérica em todos os campos definidos em searchFields
  if (searchQuery != null && searchQuery.isNotEmpty) {
    final lowerCaseQuery = searchQuery.toLowerCase();
    allItems = allItems.where((item) {
      return searchFields.any((field) {
        final value = item[field]?.toString().toLowerCase() ?? '';
        return value.contains(lowerCaseQuery);
      });
    }).toList();
  }

  // Ordenação
  _sortOnServer(allItems, allColumns, sortParams);

  // Paginação
  final int total = allItems.length;
  final int startIndex = (page - 1) * SystemConstants.itemsPorPagina;
  final int endIndex = startIndex + SystemConstants.itemsPorPagina;
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

  if (column.sortType == SortType.thisOrThat) {
    data.sort((a, b) {
      final valueA = a[column.dataField]?.toString();
      final valueB = b[column.dataField]?.toString();
      final targetValue =
          sortParams.thisOrThatState == ThisOrThatSortState.primaryFirst
              ? column.primarySortValue
              : column.secondarySortValue;
      if (valueA == targetValue && valueB != targetValue) return -1;
      if (valueB == targetValue && valueA != targetValue) return 1;
      return 0;
    });
  } else {
    data.sort((a, b) {
      final valueA = a[column.dataField];
      final valueB = b[column.dataField];
      if (valueA == null) return sortParams.isAscending ? -1 : 1;
      if (valueB == null) return sortParams.isAscending ? 1 : -1;

      int comparison;
      if (column.sortType == SortType.numeric) {
        comparison = (valueA as num).compareTo(valueB as num);
      } else {
        comparison = valueA.toString().toLowerCase().compareTo(
              valueB.toString().toLowerCase(),
            );
      }
      return sortParams.isAscending ? comparison : -comparison;
    });
  }
}

// Simulador de API para testes
Future<PaginatedResponse> getRecentMovements({String? searchQuery}) async {
  await Future.delayed(const Duration(milliseconds: 500));

  final data = [
    {
      'item_name': 'Kit Primeiros Socorros',
      'quantity': '+2',
      'responsible': 'Mauro'
    },
    {
      'item_name': 'Vestimenta',
      'quantity': '-5',
      'responsible': 'Gabriel'
    },
    {
      'item_name': 'Munição 9mm',
      'quantity': '-50',
      'responsible': 'Almeida'
    },
  ];

  List<Map<String, dynamic>> filteredData = data;

  if (searchQuery != null && searchQuery.isNotEmpty) {
    final lowerCaseQuery = searchQuery.toLowerCase();
    filteredData = data.where((item) {
      return ['item_name', 'quantity', 'responsible', 'date'].any((field) {
        final value = item[field]?.toString().toLowerCase() ?? '';
        return value.contains(lowerCaseQuery);
      });
    }).toList();
  }

  return PaginatedResponse(
    items: filteredData,
    totalCount: filteredData.length,
  );
}
