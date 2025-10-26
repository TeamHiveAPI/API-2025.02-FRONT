import 'package:sistema_almox/core/constants/database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SectorService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAllSectors() async {
    final response = await supabase
        .from(SupabaseTables.setor)
        .select('id, set_nome')
        .order('set_nome', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }
  
  Future<String?> getSectorNameById(int idSetor) async {
     try {
      final response = await supabase
        .from(SupabaseTables.setor)
        .select('set_nome')
        .eq('id', idSetor)
        .maybeSingle();

    return response?['set_nome'] as String?;


    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      throw Exception('Falha ao carregar o nome do setor.');
    } catch (e) {
      throw Exception('Falha ao carregar o nome do setor.');
    }
  }
}