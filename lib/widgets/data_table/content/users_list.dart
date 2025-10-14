import 'package:flutter/material.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_usuario_modal.dart';

class UsersList extends StatefulWidget {
  final int? viewingSectorId;
  final String searchQuery;
  final bool showInactive;

  const UsersList({
    super.key,
    required this.viewingSectorId,
    required this.searchQuery,
    required this.showInactive,
  });

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> with TableHandler {
  @override
  List<TableColumn> get tableColumns => [
    TableColumn(
      title: 'Nome',
      dataField: UsuarioFields.nome,
      widthFactor: 0.7,
      sortType: SortType.alphabetic,
      advancedCellBuilder: (value, rowData) {
        final bool isAtivo = rowData[UsuarioFields.ativo] ?? true;
        final Color textColor = isAtivo ? text40 : text80;

        return Text(
          formatName(value),
          style: TextStyle(color: textColor),
        );
      },
    ),
    TableColumn(
      title: 'Criado em',
      dataField: UsuarioFields.dataCriacao,
      widthFactor: 0.3,
      sortType: SortType.numeric,
      advancedCellBuilder: (value, rowData) {
        final bool isAtivo = rowData[UsuarioFields.ativo] ?? true;
        final Color textColor = isAtivo ? text40 : text80;

        final String displayDate = (value == null || value.toString().isEmpty)
            ? 'N/A'
            : formatDate(value);

        return Text(displayDate, style: TextStyle(color: textColor));
      },
    ),
  ];

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) {
    return UserService.instance.fetchSectorUsers(
      page: page,
      sortParams: sortParams,
      searchQuery: searchQuery,
      showInactive: widget.showInactive,
    );
  }

  @override
  void initState() {
    super.initState();
    initTableHandler(initialSearchQuery: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant UsersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewingSectorId != oldWidget.viewingSectorId ||
        widget.showInactive != oldWidget.showInactive) {
      refreshData();
    }
    if (widget.searchQuery != oldWidget.searchQuery) {
      onSearchQueryChanged(widget.searchQuery);
    }
  }

  void _handleRowTap(Map<String, dynamic> userData) {
    final int? id = userData[UsuarioFields.id];

    if (id == null) {
      print("Erro: ID do usuário não encontrado");
      return;
    }

    showCustomBottomSheet(
      context: context,
      title: "Detalhes do Usuário",
      child: DetalhesUsuarioModal(idUsuario: id, manageMode: true),
    );
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
      onRowTap: showSkeleton ? null : _handleRowTap,
      onLoadMore: loadMoreData,
      onSort: handleSort,
      activeSortColumnDataField: activeSortColumnDataField,
      isAscending: isAscending,
      thisOrThatState: thisOrThatState,
    );
  }
}
