import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/modal/base_modal.dart';

void showNewStockItemModal(BuildContext context) {
  showCustomBottomSheet(
    context: context,
    title: 'Escolha uma Ação',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(48),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: brightGray,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              highlightColor: Colors.black.withAlpha(20),
              splashColor: Colors.black.withAlpha(20),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: brandBlue,
                      child: SvgPicture.asset(
                        'assets/icons/qr-code.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Modificar estoque de um item',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: text40,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Via escaneamento de QR Code',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF616161),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(48),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: brightGray,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              highlightColor: Colors.black.withAlpha(20),
              splashColor: Colors.black.withAlpha(20),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: brandBlue,
                      child: SvgPicture.asset(
                        'assets/icons/navbar/estoque.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Cadastrar do zero',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: text40,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Adicione um item novo ao almoxarifado',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF616161),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
