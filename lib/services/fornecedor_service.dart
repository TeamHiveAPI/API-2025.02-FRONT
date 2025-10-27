import 'package:supabase_flutter/supabase_flutter.dart';

class FornecedorService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<String>> fetchFornecedores() async {
    final response = await _client.from('fornecedor').select('frn_nome');

    return (response as List).map((f) => f['frn_nome'].toString()).toList();
  }
}
