import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';

class PaginatedResponse {
  final List<Map<String, dynamic>> items;
  final int totalCount;
  PaginatedResponse({required this.items, required this.totalCount});
}

class SortParams {
  final String? activeSortColumnDataField;
  final bool isAscending;
  final ThisOrThatSortState thisOrThatState;
  SortParams({
    this.activeSortColumnDataField,
    required this.isAscending,
    required this.thisOrThatState,
  });
}

mixin TableHandler<T extends StatefulWidget> on State<T> {
  final List<Map<String, dynamic>> loadedItems = [];
  int totalItems = 0;
  int _currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  String? activeSortColumnDataField;
  bool isAscending = true;
  ThisOrThatSortState thisOrThatState = ThisOrThatSortState.none;

  List<TableColumn> get tableColumns;
  Future<PaginatedResponse> performFetch(int page, SortParams sortParams);

  void initTableHandler() {
    _fetchData();
  }

  Future<void> _fetchData({bool isSorting = false}) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      if (isSorting) {
        loadedItems.clear();
        _currentPage = 1;
        hasMore = true;
      }
    });

    final sortParams = SortParams(
      activeSortColumnDataField: activeSortColumnDataField,
      isAscending: isAscending,
      thisOrThatState: thisOrThatState,
    );

    _printApiRoute(_currentPage, sortParams);

    await Future.delayed(const Duration(milliseconds: 700));

    final response = await performFetch(_currentPage, sortParams);

    if (mounted) {
      setState(() {
        loadedItems.addAll(response.items);
        totalItems = response.totalCount;
        _currentPage++;
        hasMore = loadedItems.length < totalItems;
        isLoading = false;
      });
    }
  }

  void handleSort(TableColumn column) {
    final String dataField = column.dataField;
    final bool isCurrentlyActive = activeSortColumnDataField == dataField;
    ThisOrThatSortState nextThisOrThatState = thisOrThatState;
    bool nextIsAscending = isAscending;
    String? nextActiveSortColumn = activeSortColumnDataField;

    if (column.sortType == SortType.thisOrThat) {
      nextIsAscending = true;
      ThisOrThatSortState nextState = ThisOrThatSortState.primaryFirst;
      if (isCurrentlyActive) {
        if (thisOrThatState == ThisOrThatSortState.primaryFirst) {
          nextState = ThisOrThatSortState.secondaryFirst;
        } else if (thisOrThatState == ThisOrThatSortState.secondaryFirst) {
          nextState = ThisOrThatSortState.none;
        }
      }
      nextThisOrThatState = nextState;

      if (nextThisOrThatState == ThisOrThatSortState.none) {
        nextActiveSortColumn = null;
      } else {
        nextActiveSortColumn = dataField;
      }
    } else {
      nextThisOrThatState = ThisOrThatSortState.none;
      if (isCurrentlyActive && !nextIsAscending) {
        nextActiveSortColumn = null;
      } else {
        nextIsAscending = isCurrentlyActive ? !nextIsAscending : true;
        nextActiveSortColumn = dataField;
      }
    }

    setState(() {
      activeSortColumnDataField = nextActiveSortColumn;
      isAscending = nextIsAscending;
      thisOrThatState = nextThisOrThatState;
    });

    _fetchData(isSorting: true);
  }

  void loadMoreData() {
    _fetchData();
  }

  void _printApiRoute(int page, SortParams sortParams) {
    String baseUrl = "/api/items?page=$page&limit=10";
    String queryParams = "";
    if (sortParams.activeSortColumnDataField != null) {
      final column = tableColumns.firstWhere(
        (c) => c.dataField == sortParams.activeSortColumnDataField,
      );
      if (column.sortType == SortType.thisOrThat) {
        if (sortParams.thisOrThatState == ThisOrThatSortState.primaryFirst) {
          queryParams = "&sortBy=${column.primarySortValue}First";
        } else if (sortParams.thisOrThatState ==
            ThisOrThatSortState.secondaryFirst) {
          queryParams = "&sortBy=${column.secondarySortValue}First";
        }
      } else if (column.sortType == SortType.numeric) {
        queryParams = sortParams.isAscending
            ? "&sortBy=numberAscending"
            : "&sortBy=numberDescending";
      } else {
        queryParams = sortParams.isAscending
            ? "&sortBy=ascending"
            : "&sortBy=descending";
      }
    }
    print("Chamada de API simulada: $baseUrl$queryParams");
  }
}
