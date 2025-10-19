import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/movimentation_service.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_item_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_movimentacao_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_usuario_modal.dart';

class MovimentationLogTable extends StatefulWidget {
  final bool isRecentView;
  final String? searchQuery;

  const MovimentationLogTable({
    super.key,
    this.isRecentView = false,
    this.searchQuery,
  });

  @override
  State<MovimentationLogTable> createState() => _MovimentationLogTableState();
}

class _MovimentationLogTableState extends State<MovimentationLogTable>
    with TableHandler {
  @override
  List<TableColumn> get tableColumns => [
    TableColumn(
      title: 'Nome do item',
      dataField: 'nome_item',
      widthFactor: 0.55,
    ),
    TableColumn(
      title: 'QTD',
      dataField: 'saldo_operacao',
      widthFactor: 0.2,
      cellBuilder: (value) {
        final int saldo = value is int ? value : 0;
        final bool isPositive = saldo > 0;
        final String textoValor = isPositive ? '+$saldo' : saldo.toString();

        return Text(
          textoValor,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isPositive ? successGreen : deleteRed,
          ),
        );
      },
    ),
    TableColumn(title: 'Tipo', dataField: 'tipo_mov', widthFactor: 0.25),
  ];

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) async {
    return StockMovementService.instance.fetchMovements(
      page: page,
      isRecentView: widget.isRecentView,
      searchQuery: searchQuery,
    );
  }

  @override
  void initState() {
    super.initState();
    initTableHandler(initialSearchQuery: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(covariant MovimentationLogTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      onSearchQueryChanged(widget.searchQuery ?? '');
    }
  }

  void _handleRowTap(Map<String, dynamic> itemData) {
    void showMovimentacaoModal() {
      showCustomBottomSheet(
        context: context,
        title: "Detalhes da Movimentação",
        child: DetalhesMovimentacaoModal(
          operationData: itemData,

          onViewItemDetails: (itemId) async {
            Navigator.of(context).pop();
            await showCustomBottomSheet(
              context: context,
              title: "Detalhes do Item",
              child: DetalhesItemModal(itemId: itemId),
            );
            showMovimentacaoModal();
          },

          onViewUserDetails: (userId) async {
            Navigator.of(context).pop();
            await showCustomBottomSheet(
              context: context,
              title: "Detalhes do Usuário",
              child: DetalhesUsuarioModal(idUsuario: userId),
            );
            showMovimentacaoModal();
          },
        ),
      );
    }

    // Chama a função pela primeira vez
    showMovimentacaoModal();
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton = isLoading && loadedItems.isEmpty;

    final List<Map<String, dynamic>> displayData = showSkeleton
        ? List.generate(widget.isRecentView ? 3 : 8, (_) => {})
        : loadedItems;

    return DynamicJsonTable(
      jsonData: displayData,
      columns: tableColumns,
      isLoading: isLoading,
      showSkeleton: showSkeleton,
      hidePagination: widget.isRecentView,
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
