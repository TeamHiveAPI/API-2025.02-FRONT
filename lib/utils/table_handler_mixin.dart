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

  String _currentSearchQuery = '';

  String? activeSortColumnDataField;
  bool isAscending = true;
  ThisOrThatSortState thisOrThatState = ThisOrThatSortState.none;

  List<TableColumn> get tableColumns;
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  );
  
  void initTableHandler({String initialSearchQuery = ''}) {
    _currentSearchQuery = initialSearchQuery;
    _fetchData();
  }

  void onSearchQueryChanged(String query) {
    if (_currentSearchQuery == query) return;
    
    setState(() {
      _currentSearchQuery = query;
    });
    _fetchData(isReset: true);
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

    _fetchData(isReset: true);
  }

  void loadMoreData() {
    _fetchData();
  }

  Future<void> _fetchData({bool isReset = false}) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      if (isReset) {
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

    final response = await performFetch(
      _currentPage,
      sortParams,
      _currentSearchQuery,
    );

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
}