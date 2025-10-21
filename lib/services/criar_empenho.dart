import 'package:supabase_flutter/supabase_flutter.dart';

class NotaEmpenhoService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'nota_empenho';

  // Buscar todas as notas
Future<List<Map<String, dynamic>>> fetchNotas() async {
  print('🟡 Iniciando fetchNotas...');
  final response = await _client.from("nota_empenho").select();
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
  Future<void> deleteNota(int id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
