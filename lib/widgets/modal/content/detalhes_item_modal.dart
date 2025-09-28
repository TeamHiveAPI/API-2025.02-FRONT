import 'package:flutter/material.dart';
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/widgets/modal/detail_item_card.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/button.dart';

class DetalhesItemModal extends StatelessWidget {
  final String nome;
  final String numFicha;
  final String unidMedida;
  final int qtdDisponivel;
  final int qtdReservada;
  final String grupo;

  final UserRole userRole;
  final String? dataValidade;
  final bool? controlado;

  final Map<String, dynamic> itemData;

  const DetalhesItemModal({
    super.key,
    required this.nome,
    required this.numFicha,
    required this.unidMedida,
    required this.qtdDisponivel,
    required this.qtdReservada,
    required this.grupo,
    required this.userRole,
    required this.itemData,
    this.dataValidade,
    this.controlado,
  });

  @override
  Widget build(BuildContext context) {
    final int itemSectorId = itemData['id_setor'] ?? 0;
    final bool isPharmacyItem = itemSectorId == 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DetailItemCard(label: "NOME", value: nome),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DetailItemCard(label: "Nº DA FICHA", value: numFicha),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(
                label: "UNIDADE DE MEDIDA",
                value: unidMedida,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DetailItemCard(
                label: "QTD. DISPONÍVEL",
                value: qtdDisponivel.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(
                label: "QTD. RESERVADA",
                value: qtdReservada.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isPharmacyItem)
          Row(
            children: [
              Expanded(
                child: DetailItemCard(
                  label: "DATA DE VALIDADE",
                  value: formatDate(dataValidade),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DetailItemCard(
                  label: "CONTROLADO",
                  value: (controlado ?? false) ? 'Sim' : 'Não',
                ),
              ),
            ],
          ),
        if (isPharmacyItem) const SizedBox(height: 12),
        DetailItemCard(label: "GRUPO", value: grupo),
        const SizedBox(height: 12),
        CustomButton(
          text: "Ver Histórico de Movimentação",
          onPressed: () {},
          isFullWidth: true,
          customIcon: 'assets/icons/list.svg',
          iconPosition: IconPosition.right,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: "Editar",
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(
                    context,
                    AppRoutes.newItem,
                    arguments: itemData,
                  );
                },
                secondary: true,
                isFullWidth: true,
                customIcon: 'assets/icons/edit.svg',
                iconPosition: IconPosition.right,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: "QR Code",
                onPressed: () {},
                secondary: true,
                isFullWidth: true,
                customIcon: 'assets/icons/download.svg',
                iconPosition: IconPosition.right,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
