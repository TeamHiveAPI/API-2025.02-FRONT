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

  static Future<void> uploadMultiplePdfs(
    BuildContext? context, {
    VoidCallback? onReload,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true, 
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

      for (final pickedFile in result.files) {
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
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao ler o arquivo $fileName')),
            );
          }
          continue;
        }

        final PdfDocument document = PdfDocument(inputBytes: fileBytes);
        final String extractedText = PdfTextExtractor(document).extractText() ?? '';
        document.dispose();

        final extracted = _extractDataFromPdf(extractedText);

        final storagePath = 'uploads/$fileName';
        final storageRef = supabase.storage.from(STORAGE_BUCKET);

        try {
          await storageRef.uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(contentType: 'application/pdf'),
          );
        } on StorageException catch (e) {
          if (e.statusCode == '409') {
            if (context != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Arquivo duplicado: $fileName')),
              );
            }
            continue;
          } else {
            if (context != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao enviar $fileName: ${e.message}')),
              );
            }
            continue;
          }
        } catch (e) {
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha inesperada ao enviar $fileName.')),
            );
          }
          continue;
        }

        String? publicUrl;
        try {
          publicUrl = storageRef.getPublicUrl(storagePath);

          if (publicUrl.isEmpty || !publicUrl.contains(STORAGE_BUCKET)) {
            throw Exception('URL pública inválida ou não gerada corretamente.');
          }
        } catch (e) {
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao gerar link público de $fileName')),
            );
          }
          continue;
        }

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

          if (result == true && onReload != null) {
            onReload();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🔄 Lista de notas recarregada!')),
            );
          }
        }
      }
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar PDFs: $e')),
        );
      }
    }
  }

  static Map<String, dynamic> _extractDataFromPdf(String text) {
    try {
      if (text.isEmpty) {
        throw Exception('O texto do PDF está vazio ou não pôde ser extraído.');
      }

      final regexNE = RegExp(
        r'(?<=NE\s)([\s\S]*?)(?=Natureza da Despesa)',
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

      if ([ne, favorecido, data, item].every((v) => v.isEmpty)) {
        throw Exception('Nenhum dado válido foi identificado no texto do PDF.');
      }

      return {'NE': ne, 'favorecido': favorecido, 'data': data, 'item': item};
    } catch (e, s) {
      debugPrint('Erro ao extrair dados do PDF: ${e.runtimeType} -> $e\n$s');

      return {
        'NE': '',
        'favorecido': '',
        'data': '',
        'item': '',
        'erro': e.toString(),
      };
    }
  }
}
