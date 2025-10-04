import 'package:sistema_almox/core/constants/database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchGroupsBySector(int idSetor) async {
    try {
      final response = await supabase
          .from(SupabaseTables.grupo)
          .select('${GrupoFields.id}, ${GrupoFields.nome}')
          .eq(GrupoFields.setorId, idSetor)
          .order(GrupoFields.nome, ascending: true);

      return response;
    } catch (e) {
      print('Erro ao buscar grupos: $e');
      throw Exception('Falha ao buscar os grupos do setor.');
    }
  }

  Future<Map<String, dynamic>?> fetchGroupByName(String name, int sectorId) async {
    try {
      final response = await supabase
          .from(SupabaseTables.grupo)
          .select(GrupoFields.id)
          .eq(GrupoFields.nome, name)
          .eq(GrupoFields.setorId, sectorId)
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
          .from(SupabaseTables.grupo)
          .insert({
            GrupoFields.nome: name,
            GrupoFields.setorId: sectorId
          })
          .select(GrupoFields.id)
          .single();

      return response[GrupoFields.id] as int;
    } catch (e) {
      print('Erro ao criar grupo: $e');
      throw Exception('Falha ao cadastrar o grupo.');
    }
  }
}