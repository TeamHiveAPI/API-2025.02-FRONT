import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_almox/services/download_NE/download_nota.dart' as download_nota;

class NotaEmpenhoService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'nota_empenho';
  static const String STORAGE_BUCKET = 'notas-empenho';

  Future<List<Map<String, dynamic>>> fetchNotas() async {
    final response = await _client.from(_table).select();
    return response;
  }

  Future<void> createNota(Map<String, dynamic> data) async {
    await _client.from(_table).insert(data);
  }

  Future<void> updateNota(int id, Map<String, dynamic> data) async {
    await _client.from(_table).update(data).eq('id', id);
  }

  Future<void> deleteNota(int id, String ne) async {
    try {
      await _client.from(_table).delete().eq('id', id);
      final filePath = 'uploads/$ne.pdf';
      await _client.storage.from(STORAGE_BUCKET).remove([filePath]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> downloadNota(String ne) async {
    await download_nota.downloadNota(ne);
  }
}
