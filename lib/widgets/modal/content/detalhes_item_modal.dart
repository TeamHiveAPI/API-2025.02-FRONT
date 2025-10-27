import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/services/item_service.dart';
import 'package:sistema_almox/utils/generate_qr_code.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_lotes_item_modal.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class DetalhesItemModal extends StatefulWidget {
  final int itemId;

  const DetalhesItemModal({super.key, required this.itemId});

  @override
  State<DetalhesItemModal> createState() => _DetalhesItemModalState();
}

class _DetalhesItemModalState extends State<DetalhesItemModal> {
  Map<String, dynamic>? _itemData;
  bool _isLoadingInitialContent = true;
  bool _isSavingQr = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ItemService.instance.fetchItemById(widget.itemId);

    print('DADOS DO ITEM RECEBIDOS: $data');

    if (mounted) {
      setState(() {
        _itemData = data;
        _isLoadingInitialContent = false;
      });
    }
  }

  Future<void> _onQrCodePressed() async {
    if (_itemData == null) return;

    final numFicha = _itemData!['num_ficha']?.toString() ?? '';
    final nomeItem = _itemData!['nome']?.toString() ?? '';

    setState(() => _isSavingQr = true);

    try {
      await QrPdfGenerator.generateAndSave(
        context: context,
        numFicha: numFicha,
        nomeItem: nomeItem,
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingQr = false);
      }
    }
  }

  void _showLotesModal() {
    Navigator.of(context).pop(true);

    showCustomBottomSheet(
      context: context,
      title: "Lotes do item",
      child: LotesItemModal(itemId: widget.itemId),
    ).then((_) {
      showCustomBottomSheet(
        context: context,
        title: "Detalhes do item",
        child: DetalhesItemModal(itemId: widget.itemId),
      );
    });
  }

  bool _hasExpiredLots() {
    if (_itemData == null || _itemData!['lotes'] == null) {
      return false;
    }

    final lotes = _itemData!['lotes'] as List;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return lotes.any((lote) {
      final dateStr = lote['data_validade'] as String?;
      if (dateStr == null || dateStr.isEmpty) return false;

      try {
        final expirationDate = DateTime.parse(dateStr);
        return !expirationDate.isAfter(today);
      } catch (e) {
        return false;
      }
    });
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
    final qtdDisponivel = _itemData?['qtd_total'] ?? 0;
    final qtdReservada = _itemData?['qtd_reservada'] ?? 0;
    final grupo = _itemData?['grupo']?['nome'] ?? '';
    final controlado = _itemData?['controlado'];
    final itemSectorId = _itemData?['grupo']?['id_setor'] ?? 0;
    final isPerecivel = _itemData?['perecivel'] ?? false;
    final isAtivo = _itemData?['ativo'] ?? true;
    final isPharmacyItem = itemSectorId == 2;

    final bool hasExpired = _hasExpiredLots();

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
                onPressed: _isLoadingInitialContent || !isPerecivel
                    ? null
                    : _showLotesModal,
                valueColor: hasExpired ? const Color(0xFFd00000) : null,
                icon: hasExpired
                    ? SvgPicture.asset(
                        'assets/icons/warning.svg',
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFd00000),
                          BlendMode.srcIn,
                        ),
                        width: 18,
                        height: 18,
                      )
                    : null,
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
        if (!isAtivo) ...[
          CustomButton(
            isLoadingInitialContent: _isLoadingInitialContent,
            text: "Reativar Item",
            onPressed: _isLoadingInitialContent
                ? null
                : () async {
                    await ItemService.instance.reactivateItem(widget.itemId);
                    if (mounted) {
                      Navigator.of(context).pop();
                      showCustomSnackbar(
                        context,
                        'Item reativado com sucesso!',
                      );
                    }
                  },
            isFullWidth: true,
            customIcon: 'assets/icons/key.svg',
            green: true,
            iconPosition: IconPosition.right,
          ),
        ] else ...[
          CustomButton(
            isLoadingInitialContent: _isLoadingInitialContent,
            text: "Ver Histórico de Movimentação",

            onPressed: () {
              final arguments = {
                'itemName': nome,
                'availableQuantity': qtdDisponivel,
                'reservedQuantity': qtdReservada,
              };
              void navigateAction(BuildContext callerContext) {
                Navigator.pushNamedAndRemoveUntil(
                  callerContext,
                  AppRoutes.itemMovements,
                  (route) => route is PageRoute,
                  arguments: arguments,
                );
              }

              Navigator.of(context).pop(navigateAction);
            },
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
                  onPressed: () {
                    void navigateAction(BuildContext callerContext) {
                      Navigator.pushNamedAndRemoveUntil(
                        callerContext,
                        AppRoutes.newItem,
                        (route) => route is PageRoute,
                        arguments: itemDataForButtons,
                      );
                    }

                    Navigator.of(context).pop(navigateAction);
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
                  onPressed: _isLoadingInitialContent || _isSavingQr
                      ? null
                      : _onQrCodePressed,
                  isLoading: _isSavingQr,
                  secondary: true,
                  isFullWidth: true,
                  customIcon: 'assets/icons/download.svg',
                  iconPosition: IconPosition.right,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
