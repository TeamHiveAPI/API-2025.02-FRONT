import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sistema_almox/widgets/dynamic_table/json_table.dart';
import 'package:sistema_almox/widgets/dynamic_table/table_column.dart';
import 'dart:convert';

import 'package:sistema_almox/widgets/shimmer_card.dart';

class LastMovimentationsTable extends StatefulWidget {
  const LastMovimentationsTable({super.key});

  @override
  State<LastMovimentationsTable> createState() =>
      _LastMovimentationsTableState();
}

class _LastMovimentationsTableState extends State<LastMovimentationsTable> {
  final List<TableColumn> _logColumns = [
    TableColumn(
      title: 'Nome do Item',
      dataField: 'nomeItem',
      widthFactor: 0.6,
      sortType: SortType.alphabetic,
    ),
    TableColumn(
      title: 'QTD',
      dataField: 'quantidade',
      widthFactor: 0.2,
      sortType: SortType.numeric,
      cellBuilder: (value) {
        if (value is! num) return Text(value?.toString() ?? '');
        final color = value > 0 ? Colors.green.shade700 : Colors.red.shade700;
        final text = value > 0 ? '+${value.toString()}' : value.toString();
        return Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        );
      },
    ),
    TableColumn(
      title: 'Respons.',
      dataField: 'responsavel',
      widthFactor: 0.3,
      sortType: SortType.alphabetic,
    ),
  ];

  Future<List<Map<String, dynamic>>> _loadJsonData() async {
    final String jsonString = await rootBundle.loadString(
      'lib/temp/teste.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  void _handleRowTap(Map<String, dynamic> rowData) {
    final int? itemId = rowData['id'];
    final String? itemName = rowData['nomeItem'];

    print('ID do item: $itemId');
    print('Nome do Item: $itemName');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadJsonData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerPlaceholder(
            height: 250,
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum dado encontrado.'));
        }

        return DynamicJsonTable(
          jsonData: snapshot.data!,
          columns: _logColumns,
          onRowTap: _handleRowTap,
        );
      },
    );
  }
}
