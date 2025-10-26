import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/main.dart';
import 'package:sistema_almox/utils/pluralizer.dart';
import 'package:sistema_almox/widgets/badge.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';
import 'package:sistema_almox/core/constants/database.dart';

class DetalhesItensPedidoModal extends StatefulWidget {
  final List<dynamic> itens;
  final void Function(int idItem)? onViewItemDetails;

  const DetalhesItensPedidoModal({
    super.key,
    required this.itens,
    this.onViewItemDetails,
  });

  @override
  State<DetalhesItensPedidoModal> createState() =>
      _DetalhesItensPedidoModalState();
}

class _DetalhesItensPedidoModalState extends State<DetalhesItensPedidoModal> {
  int _selectedIndex = 0;

  bool _isLoadingLotes = true;
  Map<dynamic, int> _quantidadesReaisLotes = {};

  @override
  void initState() {
    super.initState();
    _fetchQuantidadesLotes();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchQuantidadesLotes() async {
    final allLoteIds = <dynamic>{};

    for (var item in widget.itens) {
      final List<dynamic> lotesJson = (item['iped_lotes'] as List?) ?? [];
      for (var lote in lotesJson) {
        if (lote['lote_id'] != null) {
          allLoteIds.add(lote['lote_id']);
        }
      }
    }

    if (allLoteIds.isEmpty) {
      if (mounted) {
        setState(() => _isLoadingLotes = false);
      }
      return;
    }

    try {
      final response = await supabase
          .from(SupabaseTables.lote)
          .select('id, lot_qtd_atual, lot_qtd_reservada')
          .filter('id', 'in', allLoteIds.toList());
      final Map<dynamic, int> qtds = {};
      for (var loteInfo in response) {
        final int id = loteInfo['id'];
        final int atual = (loteInfo['lot_qtd_atual'] as num?)?.toInt() ?? 0;
        final int reservada =
            (loteInfo['lot_qtd_reservada'] as num?)?.toInt() ?? 0;

        final int totalY = atual + reservada;

        qtds[id] = totalY;
      }

      if (mounted) {
        setState(() {
          _quantidadesReaisLotes = qtds;
          _isLoadingLotes = false;
        });
      }
    } catch (e) {
      print('Erro ao buscar quantidades totais dos lotes: $e');
      if (mounted) {
        setState(() => _isLoadingLotes = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itens.isEmpty) {
      return const Center(child: Text('Este pedido não possui itens.'));
    }

    final dynamic selectedItem = widget.itens[_selectedIndex];
    final String itemNome =
        selectedItem[SupabaseTables.item]?[ItemFields.nome] ?? 'Item';
    final int itemId = selectedItem[ItemPedidoFields.itemId] ?? 0;
    final List<dynamic> lotes =
        (selectedItem['iped_lotes'] as List?) ?? const [];
    final String unidade =
        selectedItem[SupabaseTables.item]?[ItemFields.unidade]?.toString() ??
        '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: widget.itens.asMap().entries.map((entry) {
              final int index = entry.key;
              final dynamic item = entry.value;
              final bool isSelected = _selectedIndex == index;
              final bool isLastItem = index == widget.itens.length - 1;

              final String nome =
                  item[SupabaseTables.item]?[ItemFields.nome] ??
                  'Item ${index + 1}';

              final List<dynamic> lotes =
                  (item['iped_lotes'] as List?) ?? const [];
              final num totalQtdLotes = lotes.fold(
                0,
                (sum, lote) => sum + (lote['quantidade'] ?? 0),
              );

              final Widget buttonChild = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(nome),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : brandBlue,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    child: Text(
                      totalQtdLotes.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? brandBlue
                            : Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );

              return Padding(
                padding: EdgeInsets.only(right: isLastItem ? 20.0 : 8.0),
                child: isSelected
                    ? FilledButton(
                        onPressed: () => _onItemTapped(index),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          backgroundColor: brandBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                        ),
                        child: buttonChild,
                      )
                    : OutlinedButton(
                        onPressed: () => _onItemTapped(index),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          backgroundColor: brandBlueLight,
                          foregroundColor: brandBlue,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                        ),
                        child: buttonChild,
                      ),
              );
            }).toList(),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),

              DetailItemCard(
                label: "DETALHES DO ITEM",
                value: "Clique para ver",
                isLoading: false,
                onPressed: () {
                  if (widget.onViewItemDetails != null) {
                    widget.onViewItemDetails!(itemId);
                  }
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Text(
                    'Lotes envolvidos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(width: 8),

                  CustomBadge(
                    text: lotes.length.toString().padLeft(2, '0'),
                    backgroundColor: coolGray,
                    textColor: text60,
                    small: true,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (lotes.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('- $itemNome: (sem lotes informados)'),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 170.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: lotes.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final dynamic lote = entry.value;

                        final dynamic codigo =
                            lote['codigo'] ??
                            lote['codigo_lote'] ??
                            lote['lote_id'];

                        final dynamic loteId = lote['lote_id'];
                        final qtdSolicitada = lote['quantidade'] ?? 0;
                        final int qtdTotal = _quantidadesReaisLotes[loteId] ?? 0;

                        final String unidadePluralizada = pluralize(
                          unidade,
                          qtdSolicitada,
                        );

                        final String unidadeSuffixDinamico = unidade.isNotEmpty
                            ? ' $unidadePluralizada'
                            : '';

                        final String qtdFormatada;

                        if (_isLoadingLotes) {
                          qtdFormatada =
                              '$qtdSolicitada de ...${unidade.isNotEmpty ? ' $unidade' : ''}';
                        } else if (qtdTotal > 0) {
                          qtdFormatada =
                              '$qtdSolicitada de $qtdTotal$unidadeSuffixDinamico';
                        } else {
                          qtdFormatada = '$qtdSolicitada$unidadeSuffixDinamico';
                        }

                        final Color cardBackgroundColor = brandBlueLight;
                        final Color loteBadgeColor = text40;
                        final Color qtdBadgeColor = brandBlue;

                        return Container(
                          key: ValueKey('${codigo.toString()}-$index'),
                          margin: const EdgeInsets.only(bottom: 8.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomBadge(
                                text: codigo.toString(),
                                backgroundColor: loteBadgeColor,
                              ),

                              CustomBadge(
                                text: qtdFormatada,
                                backgroundColor: qtdBadgeColor,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
