import 'package:flutter/material.dart';
import 'package:sistema_almox/services/group_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_grupo_modal.dart';
import 'package:sistema_almox/widgets/modal/content/novo_grupo.dart';

class GroupList extends StatefulWidget {
  final String? searchQuery;

  const GroupList({super.key, this.searchQuery});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> with TableHandler<GroupList> {
  final _groupService = GroupService();
  final _userService = UserService.instance;

  @override
  List<TableColumn> get tableColumns => [
    TableColumn(
      title: 'ID',
      dataField: 'id',
      widthFactor: 0.2,
      sortType: SortType.numeric,
    ),
    TableColumn(
      title: 'Nome',
      dataField: 'grp_nome',
      widthFactor: 0.8,
      sortType: SortType.alphabetic,
    ),
  ];

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) async {
    final currentSectorId = _userService.viewingSectorId;

    if (currentSectorId == null) {
      return PaginatedResponse(items: [], totalCount: 0);
    }

    try {
      List<Map<String, dynamic>> allGroups = await _groupService
          .fetchGroupsBySector(currentSectorId);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        allGroups = allGroups.where((g) {
          final name = g['grp_nome']?.toString().toLowerCase() ?? '';
          return name.contains(query);
        }).toList();
      }

      if (sortParams.activeSortColumnDataField != null) {
        allGroups.sort((a, b) {
          final field = sortParams.activeSortColumnDataField!;
          final aValue = a[field];
          final bValue = b[field];

          int comparison = 0;
          if (aValue is int && bValue is int) {
            comparison = aValue.compareTo(bValue);
          } else {
            comparison = (aValue?.toString() ?? '').compareTo(
              bValue?.toString() ?? '',
            );
          }

          return sortParams.isAscending ? comparison : -comparison;
        });
      }

      const int pageSize = 8;
      final int startIndex = (page - 1) * pageSize;
      final int totalCount = allGroups.length;

      List<Map<String, dynamic>> paginatedItems = [];

      if (startIndex < totalCount) {
        final int endIndex = (startIndex + pageSize) < totalCount
            ? startIndex + pageSize
            : totalCount;
        paginatedItems = allGroups.sublist(startIndex, endIndex);
      }

      return PaginatedResponse(items: paginatedItems, totalCount: totalCount);
    } catch (e) {
      debugPrint('Erro ao buscar grupos: $e');
      return PaginatedResponse(items: [], totalCount: 0);
    }
  }

  @override
  void initState() {
    super.initState();
    initTableHandler(initialSearchQuery: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(covariant GroupList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      onSearchQueryChanged(widget.searchQuery ?? '');
    }
  }

  void _handleRowTap(Map<String, dynamic> groupData) async {
    final int groupId = groupData['id'];
    final String groupName = groupData['grp_nome'] ?? 'Sem nome';

    final result = await showCustomBottomSheet(
      context: context,
      title: "Detalhes do Grupo",
      child: DetalhesGrupoModal(groupId: groupId, groupName: groupName),
    );

    if (result == 'edit') {
      if (mounted) {
        final editResult = await showCustomBottomSheet(
          context: context,
          title: "Editar Grupo",
          child: NovoGrupoModal(groupToEdit: groupData),
        );

        if (editResult == true) {
          refreshData();
        }
      }
    }
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
