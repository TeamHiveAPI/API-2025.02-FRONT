import 'package:flutter/material.dart';
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/services/item_service.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';

class DetalhesItemModal extends StatefulWidget {
  final int itemId;

  const DetalhesItemModal({super.key, required this.itemId});

  @override
  State<DetalhesItemModal> createState() => _DetalhesItemModalState();
}

class _DetalhesItemModalState extends State<DetalhesItemModal> {
  Map<String, dynamic>? _itemData;
  bool _isLoadingInitialContent = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ItemService.instance.fetchItemById(widget.itemId);
    if (mounted) {
      setState(() {
        _itemData = data;
        _isLoadingInitialContent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoadingInitialContent && _itemData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Item não encontrado ou erro ao carregar.'),
        ),
      );
    }

    final itemDataForButtons = _itemData ?? {};
    final nome = _itemData?['nome'] ?? '';
    final numFicha = _itemData?['num_ficha']?.toString() ?? '';
    final unidMedida = _itemData?['unidade'] ?? '';
    final qtdDisponivel = _itemData?['qtd_atual'] ?? 0;
    final qtdReservada = _itemData?['qtd_reservada'] ?? 0;
    final grupo = _itemData?['grupo']?['nome'] ?? '';
    final dataValidade = _itemData?['data_validade'];
    final controlado = _itemData?['controlado'];
    final itemSectorId = _itemData?['id_setor'] ?? 0;
    final isPharmacyItem = itemSectorId == 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DetailItemCard(
          isLoading: _isLoadingInitialContent,
          label: "NOME",
          value: nome,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DetailItemCard(
                isLoading: _isLoadingInitialContent,
                label: "Nº DA FICHA",
                value: numFicha,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(
                isLoading: _isLoadingInitialContent,
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
                isLoading: _isLoadingInitialContent,
                label: "QTD. DISPONÍVEL",
                value: qtdDisponivel.toString(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(
                isLoading: _isLoadingInitialContent,
                label: "QTD. RESERVADA",
                value: qtdReservada.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isPharmacyItem)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DetailItemCard(
                      isLoading: _isLoadingInitialContent,
                      label: "DATA DE VALIDADE",
                      value: formatDate(dataValidade),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DetailItemCard(
                      isLoading: _isLoadingInitialContent,
                      label: "CONTROLADO",
                      value: (controlado ?? false) ? 'Sim' : 'Não',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        DetailItemCard(
          isLoading: _isLoadingInitialContent,
          label: "GRUPO",
          value: grupo,
        ),
        const SizedBox(height: 12),
        CustomButton(
          isLoadingInitialContent: _isLoadingInitialContent,
          text: "Ver Histórico de Movimentação",
          onPressed: _isLoadingInitialContent ? null : () {},
          isFullWidth: true,
          customIcon: 'assets/icons/list.svg',
          iconPosition: IconPosition.right,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                isLoadingInitialContent: _isLoadingInitialContent,
                text: "Editar",
                onPressed: _isLoadingInitialContent
                    ? null
                    : () {
                        Navigator.of(context).pop(true);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.newItem,
                          arguments: itemDataForButtons,
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
                isLoadingInitialContent: _isLoadingInitialContent,
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
