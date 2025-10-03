import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchGroupsBySector(int idSetor) async {
    try {
      final response = await supabase
          .from('grupo')
          .select('id_grupo, nome')
          .eq('id_setor', idSetor)
          .order('nome', ascending: true);

      return response;
    } catch (e) {
      print('Erro ao buscar grupos: $e');
      throw Exception('Falha ao buscar os grupos do setor.');
    }
  }

  Future<Map<String, dynamic>?> fetchGroupByName(String name, int sectorId) async {
    try {
      final response = await supabase
          .from('grupo')
          .select('id_grupo')
          .eq('nome', name)
          .eq('id_setor', sectorId)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Erro ao buscar grupo por nome: $e');
      throw Exception('Falha ao buscar grupo por nome.');
    }
  }

  Future<int> createGroup({required String name, required int sectorId}) async {
    try {
      final response = await supabase
          .from('grupo')
          .insert({'nome': name, 'id_setor': sectorId})
          .select('id_grupo')
          .single();

      return response['id_grupo'] as int;
    } catch (e) {
      print('Erro ao criar grupo: $e');
      throw Exception('Falha ao cadastrar o grupo.');
    }
  }
}