import 'package:flutter/material.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';

class LastOrderSummary extends StatelessWidget {
  const LastOrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicJsonTable(
      jsonData: const [
        {
          'item_name': 'Notebook',
          'quantity': '2',
          'status': 'Pendente'
        },
      ],
      columns: [
        TableColumn(
          title: 'Nome do item',
          dataField: 'item_name',
          widthFactor: 0.45,
        ),
        TableColumn(
          title: 'QTD',
          dataField: 'quantity',
          widthFactor: 0.2,
        ),
        TableColumn(
          title: 'Status',
          dataField: 'status',
          widthFactor: 0.3,
        ),
      ],
      totalResults: 1,
      canLoadMore: false,
      isLoading: false,
      onSort: (column) {},
      isAscending: true,
      thisOrThatState: ThisOrThatSortState.none,
      showSkeleton: false,
      hidePagination: true,
      onRowTap: (itemData) {
        print('Navegando para detalhes do pedido...');
      },
    );
  }
}