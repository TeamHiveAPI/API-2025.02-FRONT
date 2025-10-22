import 'dart:typed_data';
import 'dart:ui';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class QrPdfGenerator {
  static Future<void> generateAndSave({
    required BuildContext context,
    required String numFicha,
    required String nomeItem,
  }) async {
    if (numFicha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Número da ficha indisponível para gerar QR Code.'),
        ),
      );
      return;
    }

    try {
      final qrValidationResult = QrValidator.validate(
        data: numFicha,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      final qrCode = qrValidationResult.qrCode;
      if (qrCode == null) throw Exception('Erro ao validar dados do QR Code.');

      final painter = QrPainter.withQr(
        qr: qrCode,
        color: const Color(0xff000000),
        gapless: true,
      );
      final picData = await painter.toImageData(
        200,
        format: ImageByteFormat.png,
      );
      if (picData == null) {
        throw Exception('Erro ao converter QR Code para imagem.');
      }

      final pdf = pw.Document();
      final qrImage = pw.MemoryImage(picData.buffer.asUint8List());

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'Item: ${nomeItem.isEmpty ? "Não informado" : nomeItem}',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Nº da Ficha: $numFicha',
                    style: const pw.TextStyle(fontSize: 18),
                  ),
                  pw.SizedBox(height: 60),
                  pw.SizedBox(
                    width: 400,
                    height: 400,
                    child: pw.Image(qrImage),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final Uint8List pdfBytes = await pdf.save();

      final savedPath = await FileSaver.instance.saveFile(
        name: 'qrcode_item_$numFicha',
        bytes: pdfBytes,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );

      if (context.mounted) {
        try {
          await OpenFilex.open(savedPath);
        } catch (e) {
          if (context.mounted) {
            showCustomSnackbar(
              context,
              'Erro ao abrir o arquivo: $e',
              isError: true,
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        showCustomSnackbar(context, 'Erro ao salvar PDF: $e', isError: true);
      }
    }
  }
}
