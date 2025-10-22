import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfAuditService {
  static Future<Uint8List> generateAuditPdf(List<Map<String, dynamic>> movements) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();

    final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader(formattedDate, font),
        build: (context) => [
          _buildAuditTable(movements, font),
        ],
        footer: (context) => _buildFooter(context, font),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String formattedDate, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(bottom: 20.0),
      child: pw.Column(
        children: [
          pw.Text(
            'Relatório de Auditoria de Movimentações',
            style: pw.TextStyle(font: font, fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Gerado em: $formattedDate',
            style: pw.TextStyle(font: font, fontSize: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAuditTable(List<Map<String, dynamic>> movements, pw.Font font) {
    final headers = ['Data', 'Item', 'Tipo', 'Saldo', 'Responsável'];

    final data = movements.map((mov) {
      final operationDate = DateTime.parse(mov['data_operacao']);
      final formattedOperationDate = DateFormat('dd/MM/yyyy HH:mm').format(operationDate);

      return [
        formattedOperationDate,
        mov['nome_item'].toString(),
        mov['tipo_mov'].toString(),
        mov['saldo_operacao'].toString(),
        mov['nome_usuario'].toString(),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
      cellStyle: pw.TextStyle(font: font),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey),
      ),
    );
  }
}