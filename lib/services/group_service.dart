import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchGroupsBySector(int setorId) async {
    final response = await _client
        .from('grupo')
        .select('id, grp_nome, grp_setor_id')
        .eq('grp_setor_id', setorId);

    return response;
  }

  Future<Map<String, dynamic>?> fetchGroupByName(
    String nome,
    int setorId,
  ) async {
    final response = await _client
        .from('grupo')
        .select('id, grp_nome, grp_setor_id')
        .eq('grp_nome', nome)
        .eq('grp_setor_id', setorId)
        .maybeSingle();

    return response;
  }

  Future<int> countItemsInGroup(int groupId) async {
    try {
      final count = await _client
          .from('item')
          .count(CountOption.exact)
          .eq('it_grupo_id', groupId);

      return count;
    } catch (e) {
      print('Erro ao contar itens do grupo $groupId: $e');
      return 0;
    }
  }

  Future<int> createGroup({required String name, required int sectorId}) async {
    try {
      final result = await _client.rpc(
        'fn_insert_grupo',
        params: {'p_nome': name, 'p_setor_id': sectorId},
      );

      if (result != null && result is List && result.isNotEmpty) {
        return result.first['id'] as int;
      }

      final insert = await _client
          .from('grupo')
          .insert({'grp_nome': name, 'grp_setor_id': sectorId})
          .select('id')
          .maybeSingle();

      if (insert == null) {
        throw Exception('Falha ao criar grupo.');
      }

      return insert['id'] as int;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGroup({required int id, required String newName}) async {
    await _client.from('grupo').update({'grp_nome': newName}).eq('id', id);
  }

  Future<void> deleteGroup(int id) async {
    await _client.rpc('fn_delete_grupo', params: {'p_id': id});
  }
}
