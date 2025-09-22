import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';

final supabase = Supabase.instance.client;
const int _itemsPerPage = 8;

class StockItemService {
  Future<PaginatedResponse> fetchItems({
    required int page,
    required SortParams sortParams,
    String? searchQuery,
  }) async {
    try {
      var baseQuery = supabase
          .from('item')
          .select('id_item, nome, num_ficha, unidade, qtd_atual');

      if (searchQuery != null && searchQuery.isNotEmpty) {
        baseQuery = baseQuery.or(
          'nome.ilike.%$searchQuery%,num_ficha.ilike.%$searchQuery%',
        );
      }

      final countResponse = await baseQuery.count();
      final totalCount = countResponse.count;

      PostgrestTransformBuilder<PostgrestList> dataQuery = baseQuery;

      if (sortParams.activeSortColumnDataField != null) {
        dataQuery = dataQuery.order(
          sortParams.activeSortColumnDataField!,
          ascending: sortParams.isAscending,
        );
      }

      final int startIndex = (page - 1) * _itemsPerPage;
      dataQuery = dataQuery.range(startIndex, startIndex + _itemsPerPage - 1);

      final itemsResponse = await dataQuery;
      final items = itemsResponse;

      return PaginatedResponse(items: items, totalCount: totalCount);
    } catch (e) {
      print('Erro ao buscar itens do Supabase: $e');
      return PaginatedResponse(items: [], totalCount: 0);
    }
  }
}
