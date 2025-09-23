import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/utils/api_simulator.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';
import 'package:sistema_almox/widgets/modal/base_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_item_modal.dart';

class StockItemsTable extends StatefulWidget {
  final String? searchQuery;
  final UserRole? userRole; // Tornar opcional para usar contexto real

  const StockItemsTable({super.key, this.searchQuery, this.userRole});

  @override
  State<StockItemsTable> createState() => _StockItemsTableState();
}

class _StockItemsTableState extends State<StockItemsTable> with TableHandler {
  // Usar contexto real do usuário
  UserRole get _currentUserRole =>
      widget.userRole ??
      UserService.instance.currentUser?.role ??
      UserRole.soldadoComum;

  int? get _currentUserSetor => UserService.instance.currentUser?.idSetor;

  @override
  String get apiEndpoint {
    switch (_currentUserRole) {
      case UserRole.tenenteFarmacia:
      case UserRole.soldadoFarmacia:
        return 'farmacia';
      default:
        return 'estoque';
    }
  }

  @override
  List<TableColumn> get tableColumns => [
    TableColumn(
      title: 'Nome do Item',
      dataField: 'itemName',
      widthFactor: 0.78,
      sortType: SortType.alphabetic,
    ),
    TableColumn(
      title: 'QTD',
      dataField: 'quantity',
      widthFactor: 0.22,
      sortType: SortType.numeric,
    ),
  ];

  String get _assetPathForRole {
    switch (_currentUserRole) {
      case UserRole.tenenteFarmacia:
      case UserRole.soldadoFarmacia:
        return 'lib/temp/farmacia.json';
      case UserRole.coronel:
        return 'lib/temp/almoxarifado.json'; // Coronel vê tudo
      case UserRole.tenenteEstoque:
      case UserRole.soldadoEstoque:
        return 'lib/temp/almoxarifado.json';
      case UserRole.soldadoComum:
        return 'lib/temp/almoxarifado.json'; // Soldado comum não deveria ver, mas mantém para compatibilidade
    }
  }

  // Verificar se o usuário pode ver itens baseado no setor
  bool _canViewItem(Map<String, dynamic> item) {
    // Coronel vê tudo
    if (_currentUserRole == UserRole.coronel) return true;

    // Soldado comum não vê itens
    if (_currentUserRole == UserRole.soldadoComum) return false;

    // Verificar se o item pertence ao setor do usuário
    final itemSetor = item['id_setor'] ?? item['setor'];
    if (itemSetor == null || _currentUserSetor == null) return false;

    return itemSetor == _currentUserSetor;
  }

  @override
  Future<PaginatedResponse> performFetch(
    int page,
    SortParams sortParams,
    String? searchQuery,
  ) async {
    // Buscar dados do asset
    final response = await fetchItemsFromAsset(
      assetPath: _assetPathForRole,
      page: page,
      allColumns: tableColumns,
      sortParams: sortParams,
      searchQuery: searchQuery,
    );

    // Filtrar itens baseado nas permissões do usuário
    final filteredItems = response.items.where(_canViewItem).toList();

    return PaginatedResponse(
      items: filteredItems,
      totalCount: filteredItems.length,
    );
  }

  @override
  void initState() {
    super.initState();
    initTableHandler(initialSearchQuery: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(covariant StockItemsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      onSearchQueryChanged(widget.searchQuery ?? '');
    }
  }

  void _handleRowTap(Map<String, dynamic> itemData) {
    showCustomBottomSheet(
      context: context,
      title: "Detalhes do Item",
      child: DetalhesItemModal(
        nome: itemData['itemName']?.toString() ?? 'N/A',
        numFicha: itemData['numFicha']?.toString() ?? 'N/A',
        unidMedida: itemData['unidMedida']?.toString() ?? 'N/A',
        qtdDisponivel: itemData['quantity'] ?? 0,
        qtdReservada: itemData['qtdReservada'] ?? 0,
        grupo: itemData['grupo']?.toString() ?? 'N/A',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showSkeleton = isLoading && loadedItems.isEmpty;

    final List<Map<String, dynamic>> displayData = showSkeleton
        ? List.generate(8, (_) => <String, dynamic>{})
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
