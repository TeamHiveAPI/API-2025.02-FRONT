import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class GroupService {
  Future<List<Map<String, dynamic>>> fetchAllGroups(int idSetor) async {
    try {
      final response = await supabase
          .from('grupo')
          .select('id_grupo, nome')
          .eq('id_setor', idSetor)
          .order('nome', ascending: true);

      return response; 
    } catch (e) {
      print('Erro ao buscar grupos: $e');
      return [];
    }
  }

  Future<void> createGroup(Map<String, dynamic> groupPayload) async {
    try {
      final payload = Map.of(groupPayload)
        ..remove('id_grupo');
      await supabase.from('grupo').insert(payload);
    } catch (e) {
      print('Erro ao criar grupo: $e');
      throw Exception('Falha ao cadastrar o grupo.');
    }
  }
}