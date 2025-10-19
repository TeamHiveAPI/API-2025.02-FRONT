import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class StockMovementService {
  StockMovementService._privateConstructor();
  static final StockMovementService instance =
      StockMovementService._privateConstructor();

  Future<PaginatedResponse> fetchMovements({
    int page = 1,
    int pageSize = 8,
    bool isRecentView = false,
    String? searchQuery,
  }) async {
    try {
      var query = supabase.rpc(
        'obter_movimentacoes_agrupadas',
        params: {'search_query_param': searchQuery ?? ''},
      );

      if (isRecentView) {
        final response = await query.limit(3);
        if (response is! List) {
          throw Exception("Formato de resposta inesperado da API.");
        }
        final data = List<Map<String, dynamic>>.from(response);
        return PaginatedResponse(items: data, totalCount: data.length);
      } else {
        final from = (page - 1) * pageSize;
        final to = from + pageSize - 1;

        final response = await query.range(from, to).count();
        final data = List<Map<String, dynamic>>.from(response.data);
        return PaginatedResponse(items: data, totalCount: response.count);
      }
    } catch (e) {
      print('Erro ao buscar movimentações: $e');
      throw Exception('Falha ao carregar movimentações.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllMovementsForReport({
    String? searchQuery,
  }) async {
    try {
      final response = await supabase.rpc(
        'obter_movimentacoes_agrupadas',
        params: {'search_query_param': searchQuery ?? ''},
      );

      if (response is! List) {
        throw Exception("Formato de resposta inesperado da API.");
      }

      final data = List<Map<String, dynamic>>.from(response);
      return data;
    } catch (e) {
      print('Erro ao buscar todas as movimentações para o relatório: $e');
      throw Exception('Falha ao carregar dados para a auditoria.');
    }
  }
}
