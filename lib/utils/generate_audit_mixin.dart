import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sistema_almox/services/audit.dart';
import 'package:sistema_almox/services/movimentation_service.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/audit_pdf_preview.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

mixin GenerateAuditMixin<T extends StatefulWidget> on State<T> {
  Future<void> handleBaixarAuditoria({
    required String searchQuery,
    String? itemName,
    required Function(bool) setLoading,
  }) async {
    setLoading(true);
    try {
      final allMovements = await StockMovementService.instance
          .fetchAllMovementsForReport(
            searchQuery: searchQuery,
            fixedItemName: itemName,
          );

      if (!mounted) return;

      if (allMovements.isEmpty) {
        showCustomSnackbar(
          context,
          'Nenhuma movimentação encontrada para gerar o relatório.',
          isError: true,
        );
        return;
      }

      final Uint8List pdfBytes = await PdfAuditService.generateAuditPdf(
        allMovements,
      );

      final String baseName = itemName != null && itemName.isNotEmpty
          ? itemName.replaceAll(' ', '_')
          : 'geral';

      final String fileName =
          'relatorio_auditoria_${baseName}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (!mounted) return;

      await showCustomBottomSheet(
        context: context,
        title: 'Pré-visualização de PDF',
        child: PdfPreviewContent(pdfBytes: pdfBytes, fileName: fileName),
      );
    } catch (e) {
      print('Erro ao gerar PDF: $e');
      if (mounted) {
        showCustomSnackbar(
          context,
          'Ocorreu um erro inesperado ao gerar o relatório.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setLoading(false);
      }
    }
  }
}
