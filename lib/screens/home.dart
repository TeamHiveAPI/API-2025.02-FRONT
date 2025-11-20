import 'package:flutter/material.dart';
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/data_table/content/last_order_summary.dart';
import 'package:sistema_almox/widgets/data_table/content/recent_movimentation.dart';
import 'package:sistema_almox/widgets/view_all_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = UserService.instance.currentUser?.nome ?? 'Usuário';

    return Container(
      padding: EdgeInsets.symmetric(),
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                'Olá, ${formatName(userName)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: text40,
                ),
              ),
            ),
            SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Movimentação Recente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: text40,
                  ),
                ),
                VerTudoButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.allMovements);
                  },
                ),
              ],
            ),
            MovimentationLogTable(isRecentView: true),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seu Último Pedido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: text40,
                  ),
                ),
                VerTudoButton(onPressed: () {}),
              ],
            ),
            LastOrderSummary(),
          ],
        ),
      ),
    );
  }
}
