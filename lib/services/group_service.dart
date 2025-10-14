import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final SupabaseClient _client = Supabase.instance.client;

  // 🔹 Busca todos os grupos de um setor específico
  Future<List<Map<String, dynamic>>> fetchGroupsBySector(int setorId) async {
    final response = await _client
        .from('grupo')
        .select('id, grp_nome, grp_setor_id')
        .eq('grp_setor_id', setorId);

    return response;
  }

  // 🔹 Busca um grupo pelo nome (dentro de um setor)
  Future<Map<String, dynamic>?> fetchGroupByName(
    String nome,
    int setorId,
  ) async {
    final response = await _client
        .from('grupos')
        .select('id, grp_nome, grp_setor_id')
        .eq('grp_nome', nome)
        .eq('grp_setor_id', setorId)
        .maybeSingle();

    return response;
  }

  // 🔹 Cria um novo grupo (usando função SQL se existir)
  Future<int> createGroup({
    required String name,
    required int sectorId,
  }) async {
    try {
      // 🧠 Tenta usar a função SQL (caso você tenha criado no Supabase)
      final result = await _client.rpc(
        'fn_insert_grupo', // nome da função SQL no Supabase
        params: {
          'p_nome': name,
          'p_setor_id': sectorId,
        },
      );

      if (result != null && result is List && result.isNotEmpty) {
        return result.first['id'] as int;
      }

      // 🧩 fallback: inserção direta na tabela se a função SQL não existir
      final insert = await _client.from('grupos').insert({
        'grp_nome': name,
        'grp_setor_id': sectorId,
      }).select('id').maybeSingle();

      if (insert == null) {
        throw Exception('Falha ao criar grupo.');
      }

      return insert['id'] as int;
    } catch (e) {
      rethrow;
    }
  }

  // 🔹 Atualiza o nome de um grupo
  Future<void> updateGroup({
    required int id,
    required String newName,
  }) async {
    await _client
        .from('grupos')
        .update({'grp_nome': newName})
        .eq('id', id);
  }

  // 🔹 Remove um grupo pelo ID
  Future<void> deleteGroup(int id) async {
    await _client.from('grupos').delete().eq('id', id);
  }
}
