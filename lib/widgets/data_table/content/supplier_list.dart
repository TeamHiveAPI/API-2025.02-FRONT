import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/screens/novo_fornecedor/index.dart';
import 'package:sistema_almox/services/supplier_service.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_supplier_modal.dart';
import 'package:sistema_almox/widgets/modal/content/supplier_item_list.dart';

class SupplierList extends StatefulWidget {
  final String? searchQuery;
  final UserRole? userRole;

  const SupplierList({super.key, this.searchQuery, this.userRole});

  @override
  State<SupplierList> createState() => _SupplierListState();
}

class _SupplierListState extends State<SupplierList> with TableHandler {
  @override
  List<TableColumn> get tableColumns => [
    TableColumn(
      title: 'Nome',
      dataField: fornNome,
      widthFactor: 0.8,
      sortType: SortType.alphabetic,
    ),
    TableColumn(
      title: 'Itens',
      dataField: fornItem,
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
    return SupplierService.instance.fetchSuppliers(
      page: page,
      sortParams: sortParams,
      searchQuery: searchQuery,
      userRole: widget.userRole!,
    );
  }

  @override
  void initState() {
    super.initState();
    initTableHandler(initialSearchQuery: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(covariant SupplierList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      onSearchQueryChanged(widget.searchQuery ?? '');
    }
  }

  void refresh() {
    if (mounted) {
      initTableHandler(initialSearchQuery: widget.searchQuery ?? '');
      setState(() {});
    }
  }

  void _handleRowTap(Map<String, dynamic> supplierData) async {
    final int supplierId = supplierData['id'];

    String? nextAction = 'showDetails';
    Map<String, dynamic>? dataForNextModal;

    while (nextAction != null) {
      if (nextAction == 'showDetails') {
        final result = await showCustomBottomSheet(
          context: context,
          title: "Detalhes do fornecedor",
          child: DetalhesSupplierModal(
            supplierId: supplierId,
            initialData: dataForNextModal,
          ),
        );

        dataForNextModal = null;

        if (result is Map<String, dynamic>) {
          if (result['action'] == 'edit') {
            nextAction = 'edit';
            dataForNextModal = result['data'];
          } else if (result['action'] == 'showItems') {
            nextAction = 'showItems';
            dataForNextModal = result['data'];
          } else {
            nextAction = null;
          }
        } else {
          nextAction = null;
        }
      } else if (nextAction == 'showItems') {
        final List<dynamic> items = dataForNextModal!['items'];
        final Map<String, dynamic> supplierDataForReopen =
            dataForNextModal['supplierData'];

        await showCustomBottomSheet(
          context: context,
          title: "Itens Fornecidos (${items.length})",
          child: ItensFornecidosModal(items: items),
        );

        nextAction = 'showDetails';
        dataForNextModal = supplierDataForReopen;
      } else if (nextAction == 'edit') {
        final refreshNeeded = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NewSupplierScreen(supplierToEdit: dataForNextModal),
          ),
        );
        if (refreshNeeded == true) {
          refresh();
        }
        nextAction = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton = isLoading && loadedItems.isEmpty;
    final List<Map<String, dynamic>> displayData = showSkeleton
        ? List.generate(8, (_) => {})
        : loadedItems.map((item) {
            dynamic setorValue = item[fornSetor];
            String setorString = '';

            if (setorValue is List<dynamic>) {
              setorString = setorValue.join(', ');
            } else if (setorValue is int) {
              setorString = setorValue.toString();
            } else if (setorValue is String) {
              setorString = setorValue;
            }

            return {
              ...item,
              fornSetor: setorString,
              fornItem: (item[fornItem] as List?)?.length.toString() ?? '0',
            };
          }).toList();

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
