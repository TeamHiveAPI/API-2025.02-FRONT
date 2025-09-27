import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SectorService {
  Future<String?> getSectorNameById(int idSetor) async {
    try {
      final response = await supabase
          .from('setor')
          .select('nome')
          .eq('id_setor', idSetor)
          .single();

      return response['nome'] as String?;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      print('Erro ao buscar o nome do setor: $e');
      throw Exception('Falha ao carregar o nome do setor.');
    } catch (e) {
      print('Erro desconhecido ao buscar o nome do setor: $e');
      throw Exception('Falha ao carregar o nome do setor.');
    }
  }
}