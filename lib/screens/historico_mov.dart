import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sistema_almox/services/audit.dart';
import 'package:sistema_almox/services/movimentation_service.dart';
import 'package:sistema_almox/widgets/data_table/content/recent_movimentation.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/audit_pdf_preview.dart';

class AllMovementsScreen extends StatefulWidget {
  const AllMovementsScreen({super.key});

  @override
  State<AllMovementsScreen> createState() => _AllMovementsScreenState();
}

class _AllMovementsScreenState extends State<AllMovementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isDownloading = false;

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

  Future<void> _baixarAuditoria() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final allMovements = await StockMovementService.instance
          .fetchAllMovementsForReport(searchQuery: _searchQuery);

      if (!mounted) return;

      if (allMovements.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nenhuma movimentação encontrada para gerar o relatório.',
            ),
          ),
        );
        return;
      }

      final Uint8List pdfBytes = await PdfAuditService.generateAuditPdf(
        allMovements,
      );
      final String fileName =
          'relatorio_auditoria_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (!mounted) return;

      await showCustomBottomSheet(
        context: context,
        title: 'Pré-visualização de PDF',
        child: PdfPreviewContent(pdfBytes: pdfBytes, fileName: fileName),
      );
    } catch (e) {
      print('Erro ao gerar PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocorreu um erro ao gerar o relatório.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InternalPageHeader(title: 'Histórico de Movimentações'),

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
                        hintText: 'Pesquisar por nome ou tipo',
                      ),
                      const SizedBox(height: 20),
                      MovimentationLogTable(
                        isRecentView: false,
                        searchQuery: _searchQuery,
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
