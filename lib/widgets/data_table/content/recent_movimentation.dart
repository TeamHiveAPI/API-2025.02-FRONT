import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/movimentation_service.dart';
import 'package:sistema_almox/utils/app_events.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_item_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_movimentacao_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_usuario_modal.dart';
import 'package:intl/intl.dart';

class MovimentationLogTable extends StatefulWidget {
  final bool isRecentView;
  final String? searchQuery;
  final bool isSpecificItem;
  final String? fixedItemNameFilter;
  final ValueNotifier<int>? refreshNotifier;

  const MovimentationLogTable({
    super.key,
    this.isRecentView = false,
    this.searchQuery,
    this.isSpecificItem = false,
    this.fixedItemNameFilter,
    this.refreshNotifier,
  });

  @override
  State<MovimentationLogTable> createState() => _MovimentationLogTableState();
}

class _MovimentationLogTableState extends State<MovimentationLogTable>
    with TableHandler {
  @override
  List<TableColumn> get tableColumns {
    final List<TableColumn> columns = [
      TableColumn(
        title: 'QTD',
        dataField: 'saldo_operacao',
        widthFactor: 0.2,
        advancedCellBuilder: (value, rowData) {
          final int saldo = value is int ? value : 0;
          final String tipoMov = rowData['tipo_mov'] as String? ?? '';

          String textoValor;
          Color? corDoSaldo;

          if (tipoMov == 'RESERVA') {
            textoValor = saldo.toString();
            corDoSaldo = Colors.orange.shade500;
          } else {
            final bool isPositive = saldo > 0;
            textoValor = isPositive ? '+$saldo' : saldo.toString();
            corDoSaldo = saldo == 0
                ? null
                : (isPositive ? successGreen : deleteRed);
          }

          return Text(
            textoValor,
            style: TextStyle(fontWeight: FontWeight.w600, color: corDoSaldo),
          );
        },
      ),
      TableColumn(title: 'Tipo', dataField: 'tipo_mov', widthFactor: 0.25),
    ];

    final TableColumn mainColumn = widget.isSpecificItem
        ? TableColumn(
            title: 'Data e Hora',
            dataField: 'data_operacao',
            widthFactor: 0.55,
            cellBuilder: (value) {
              final DateTime dateTime = value is String
                  ? DateTime.tryParse(value) ?? DateTime.now()
                  : (value as DateTime? ?? DateTime.now());

              final String formattedDate = DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(dateTime);

              return Text(formattedDate);
            },
          )
        : TableColumn(
            title: 'Nome do item',
            dataField: 'nome_item',
            widthFactor: 0.55,
          );

    columns.insert(0, mainColumn);

    return columns;
  }

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) async {
    return StockMovementService.instance.fetchMovements(
      page: page,
      isRecentView: widget.isRecentView,
      fixedItemName: widget.fixedItemNameFilter,
      searchQuery: searchQuery,
    );
  }

  @override
  void initState() {
    super.initState();
    initTableHandler(initialSearchQuery: widget.searchQuery ?? '');
    if (widget.isRecentView) {
      AppEvents.stockUpdateNotifier.addListener(_forceRefresh);
    }
  }

  @override
  void dispose() {
    if (widget.isRecentView) {
      AppEvents.stockUpdateNotifier.removeListener(_forceRefresh);
    }
    super.dispose();
  }

  void _forceRefresh() {
    if (!mounted) return;

    setState(() {
      loadedItems.clear();
      isLoading = false;
    });
    loadMoreData();
  }

  @override
  void didUpdateWidget(covariant MovimentationLogTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      onSearchQueryChanged(widget.searchQuery ?? '');
    }
    if (widget.fixedItemNameFilter != oldWidget.fixedItemNameFilter) {
      onSearchQueryChanged(widget.fixedItemNameFilter ?? '');
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

            final result = await showCustomBottomSheet(
              context: context,
              title: "Detalhes do Item",
              child: DetalhesItemModal(itemId: itemId),
            );

            if (result is Function) {
              result(context);
            } else {
              showMovimentacaoModal();
            }
          },

          onViewUserDetails: (userId) async {
            Navigator.of(context).pop();
            final result = await showCustomBottomSheet(
              context: context,
              title: "Detalhes do Usuário",
              child: DetalhesUsuarioModal(idUsuario: userId),
            );
            if (result is Function) {
              result(context);
            } else {
              showMovimentacaoModal();
            }
          },
        ),
      );
    }

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
