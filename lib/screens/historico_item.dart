import 'package:flutter/material.dart';
import 'package:sistema_almox/utils/generate_audit_mixin.dart';
import 'package:sistema_almox/widgets/data_table/content/recent_movimentation.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';

class ItemMovementsScreen extends StatefulWidget {
  final String itemName;
  final int availableQuantity;
  final int reservedQuantity;

  const ItemMovementsScreen({
    super.key,
    required this.itemName,
    required this.availableQuantity,
    required this.reservedQuantity,
  });
  @override
  State<ItemMovementsScreen> createState() => _ItemMovementsScreenState();
}

class _ItemMovementsScreenState extends State<ItemMovementsScreen>
    with GenerateAuditMixin<ItemMovementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _setDownloadingState(bool isDownloading) {
    setState(() {
      _isDownloading = isDownloading;
    });
  }

  Future<void> _baixarAuditoria() async {
    await handleBaixarAuditoria(
      searchQuery: _searchQuery,
      itemName: widget.itemName,
      setLoading: _setDownloadingState,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int calculatedTotal =
        widget.availableQuantity + widget.reservedQuantity;
    final String dynamicSearchQuery = _searchQuery;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InternalPageHeader(title: 'Histórico de Movimentações'),

            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                left: 20.0,
                right: 20.0,
              ),
              child: Column(
                children: [
                  DetailItemCard(label: "NOME", value: widget.itemName),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DetailItemCard(
                          label: "QTD TOTAL",
                          value: calculatedTotal.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DetailItemCard(
                          label: "DISPONÍVEL",
                          value: widget.availableQuantity.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DetailItemCard(
                          label: "RESERVADO",
                          value: widget.reservedQuantity.toString(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      GenericSearchInput(
                        controller: _searchController,
                        onSearchChanged: _handleSearch,
                        hintText: 'Pesquisar',
                      ),
                      const SizedBox(height: 20),

                      MovimentationLogTable(
                        isRecentView: false,
                        isSpecificItem: true,
                        fixedItemNameFilter: widget.itemName,
                        searchQuery: dynamicSearchQuery,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            InternalPageBottom(
              buttonText: 'Baixar Relatório de Auditoria',
              onButtonPressed: _baixarAuditoria,
              isLoading: _isDownloading,
            ),
          ],
        ),
      ),
    );
  }
}
