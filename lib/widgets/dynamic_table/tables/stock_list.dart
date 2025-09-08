import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sistema_almox/widgets/dynamic_table/json_table.dart';
import 'package:sistema_almox/widgets/dynamic_table/table_column.dart';
import 'dart:convert';

class StockItemsTable extends StatefulWidget {
  const StockItemsTable({super.key});

  @override
  State<StockItemsTable> createState() => _StockItemsTableState();
}

class _StockItemsTableState extends State<StockItemsTable> {
  final List<TableColumn> _stockColumns = [
    TableColumn(
      title: 'Nome do Item',
      dataField: 'itemName',
      widthFactor: 0.8,
    ),
    TableColumn(
      title: 'QTD',
      dataField: 'quantity',
      widthFactor: 0.2, 
    ),
  ];

  Future<List<Map<String, dynamic>>> _loadJsonData() async {
    final String jsonString =
        await rootBundle.loadString('lib/temp/estoque.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadJsonData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum item em estoque encontrado.'));
        }
        
        return DynamicJsonTable(
          jsonData: snapshot.data!,
          columns: _stockColumns,
        );
      },
    );
  }
}