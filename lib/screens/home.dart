import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/vertudobutton.dart';
import 'package:sistema_almox/services/auth_service.dart';
import 'package:sistema_almox/widgets/data_table/json_table.dart';
import 'package:sistema_almox/widgets/data_table/table_column.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = AuthService.instance.getUserName() ?? 'Usuário';

    return Container(
      padding: EdgeInsets.symmetric(),
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, $userName',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF404040),
              ),
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Movimentação Recente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF404040),
                  ),
                ),
                VerTudoButton(),
              ],
            ),
            SizedBox(height: 16.0),
            DynamicJsonTable(
              jsonData: [
                {
                  'item_name': 'Kit Primeiros Socorros',
                  'quantity': '+2',
                  'responsible': 'Mauro'
                },
                {
                  'item_name': 'Vestimenta',
                  'quantity': '-5',
                  'responsible': 'Gabriel'
                },
              ],
              columns: [
                TableColumn(
                  title: 'Nome do Item',
                  dataField: 'item_name',
                  widthFactor: 0.4,
                ),
                TableColumn(
                  title: 'QTD',
                  dataField: 'quantity',
                  widthFactor: 0.3,
                  cellBuilder: (value) {
                    final isPositive = value.toString().startsWith('+');
                    return Text(
                      value.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Color(0xFF107A15) : Color(0xFFD12755),
                      ),
                    );
                  },
                ),
                TableColumn(
                  title: 'Responsável',
                  dataField: 'responsible',
                  widthFactor: 0.3,
                ),
              ],
              totalResults: 2,
              canLoadMore: false,
              isLoading: false,
              onSort: (column) {},
              isAscending: true,
              thisOrThatState: ThisOrThatSortState.none,
              showSkeleton: false,
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seu Último Pedido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF404040),
                  ),
                ),
                VerTudoButton(),
              ],
            ),
            SizedBox(height: 16.0),
            DynamicJsonTable(
              jsonData: [
                {
                  'item_name': 'Notebook',
                  'quantity': '2',
                  'status': 'Pendente'
                },
              ],
              columns: [
                TableColumn(
                  title: 'Nome do Item',
                  dataField: 'item_name',
                  widthFactor: 0.4,
                ),
                TableColumn(
                  title: 'QTD',
                  dataField: 'quantity',
                  widthFactor: 0.3,
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
            ),
          ],
        ),
      ),
    );
  }
}