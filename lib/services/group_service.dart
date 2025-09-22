import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class GroupService {
  Future<List<Map<String, dynamic>>> fetchAllGroups() async {
    try {
      final response = await supabase
          .from('grupo')
          .select('id_grupo, nome')
          .order('nome', ascending: true);

      return response; 
    } catch (e) {
      print('Erro ao buscar grupos: $e');
      return [];
    }
  }
}