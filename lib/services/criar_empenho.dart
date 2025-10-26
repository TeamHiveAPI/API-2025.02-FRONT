import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Para mobile/desktop
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Para web
import 'dart:html' as html;

class NotaEmpenhoService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'nota_empenho';
  static const String STORAGE_BUCKET = 'notas-empenho';

  // Buscar todas as notas
  Future<List<Map<String, dynamic>>> fetchNotas() async {
    print('🟡 Iniciando fetchNotas...');
    final response = await _client.from(_table).select();
    print('🟢 fetchNotas OK -> ${response.length} registros');
    return response;
  }

  // Criar nova nota
  Future<void> createNota(Map<String, dynamic> data) async {
    await _client.from(_table).insert(data);
    print('🟢 fetchNotas OK -> ${data} criando nota');
  }

  // Editar nota existente
  Future<void> updateNota(int id, Map<String, dynamic> data) async {
    await _client.from(_table).update(data).eq('id', id);
    print('🟢 fetchNotas OK -> ${data} atualizando nota id: $id');
  }

  // Deletar nota
  Future<void> deleteNota(int id, String ne) async {
    try {
      // 1️⃣ Deleta registro no banco
      await _client.from(_table).delete().eq('id', id);

      // 2️⃣ Deleta arquivo PDF no storage
      final filePath = 'uploads/$ne.pdf';
      await _client.storage.from(STORAGE_BUCKET).remove([filePath]);

      print('✅ Nota e PDF apagados com sucesso: $filePath');
    } catch (e) {
      print('❌ Erro ao deletar nota ou PDF: $e');
      rethrow;
    }
  }

  // Baixar PDF da nota
  Future<void> downloadNota(String ne) async {
  try {
    final filePath = 'uploads/$ne.pdf';
    final Uint8List? bytes = await _client.storage.from(STORAGE_BUCKET).download(filePath);

    if (bytes == null || bytes.isEmpty) {
      print('❌ Arquivo não encontrado: $filePath');
      return;
    }

    if (kIsWeb) {
      // Cria um Blob e um link para download
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$ne.pdf')
        ..click(); // força o download

      html.Url.revokeObjectUrl(url);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$ne.pdf');
      await file.writeAsBytes(bytes);
      print('✅ PDF salvo em: ${file.path}');
    }
  } catch (e) {
    print('❌ Erro ao baixar PDF: $e');
    rethrow;
  }
}

}
