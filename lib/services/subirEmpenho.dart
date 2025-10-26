import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../screens/notaEmpenhoFormsScreen.dart';

class UploadPdfPage {
  static const String STORAGE_BUCKET = 'notas-empenho';

  // ===========================================================
  // UPLOAD MÚLTIPLO (com reload automático após salvar)
  // ===========================================================
static Future<void> uploadMultiplePdfs(
  BuildContext? context, {
  VoidCallback? onReload, // 👈 adiciona esse parâmetro
}) async {
  final supabase = Supabase.instance.client;

  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum arquivo selecionado.')),
        );
      }
      return;
    }

    final pickedFile = result.files.first;
    final fileName = pickedFile.name;

    Uint8List? fileBytes;
    if (kIsWeb) {
      fileBytes = pickedFile.bytes;
    } else if (pickedFile.bytes != null) {
      fileBytes = pickedFile.bytes;
    } else if (pickedFile.path != null) {
      fileBytes = await File(pickedFile.path!).readAsBytes();
    }

    if (fileBytes == null) {
      throw Exception('Erro ao ler bytes do PDF');
    }

    // =======================================================
    // 1️⃣ Extrair texto do PDF
    final PdfDocument document = PdfDocument(inputBytes: fileBytes);
    final String extractedText =
        PdfTextExtractor(document).extractText() ?? '';
    document.dispose();

    // =======================================================
    // 2️⃣ Extrair dados com Regex
    final extracted = _extractDataFromPdf(extractedText);

    // =======================================================
    // 3️⃣ Upload do arquivo
    final storagePath = 'uploads/$fileName';
    await supabase.storage.from(STORAGE_BUCKET).uploadBinary(
          storagePath,
          fileBytes,
          fileOptions: const FileOptions(contentType: 'application/pdf'),
        );

    final publicUrl =
        supabase.storage.from(STORAGE_BUCKET).getPublicUrl(storagePath);

    // =======================================================
    // 4️⃣ Abrir tela de criação
    if (context != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NotaEmpenhoFormScreen(
            nota: {
              'NE': extracted['NE'],
              'favorecido': extracted['favorecido'],
              'data': extracted['data'],
              'item': extracted['item'],
              'pdf_url': publicUrl,
            },
          ),
        ),
      );

      // =======================================================
      // 5️⃣ Recarregar lista automaticamente
      if (result == true && onReload != null) {
        onReload(); // 👈 chama o callback real de reload
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🔄 Lista de notas recarregada!')),
        );
      }
    }

    print('✅ Upload concluído e formulário aberto');
  } catch (e, s) {
    print('❌ Erro durante uploadMultiplePdfs: $e');
    print(s);
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao processar PDF: $e')),
      );
    }
  }
}


  // ===========================================================
  // EXTRAÇÃO DE DADOS
  // ===========================================================
  static Map<String, dynamic> _extractDataFromPdf(String text) {
    final regexNE = RegExp(
      r'(?<=\bNúmero\s*)\n?\s*([0-9]{3,})',
      multiLine: true,
    );

    final regexFav = RegExp(
      r'\b\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}\s*\n?\s*([A-Z0-9\s\.\-&]*?)(?=\s*ATENDE)',
      multiLine: true,
    );

    final regexData = RegExp(
      r'Informação Complementar\s*([\d]{2}\/[\d]{2}\/[\d]{4})\s*Ordinário',
      caseSensitive: false,
    );

    final regexItem = RegExp(
      r'Item\s+compra:\s*([0-9]+\s*-\s*[\s\S]*?)(?=\s*Data)',
      multiLine: true,
    );

    final ne = regexNE.firstMatch(text)?.group(1)?.trim() ?? '';
    final favorecido = regexFav.firstMatch(text)?.group(1)?.trim() ?? '';
    final data = regexData.firstMatch(text)?.group(1)?.trim() ?? '';
    final item = regexItem.firstMatch(text)?.group(1)?.trim() ?? '';

    print('🧾 Extraído NE: $ne');
    print('🏢 Favorecido: $favorecido');
    print('📅 Data: $data');
    print('📦 Item: $item');

    return {'NE': ne, 'favorecido': favorecido, 'data': data, 'item': item};
  }
}
