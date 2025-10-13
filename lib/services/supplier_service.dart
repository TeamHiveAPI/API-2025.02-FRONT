import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/constants/system_constants.dart';
import 'package:sistema_almox/utils/table_handler_mixin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupplierService {
  final supabase = Supabase.instance.client;
  SupplierService._privateConstructor();
  static final SupplierService instance = SupplierService._privateConstructor();

  Future<PaginatedResponse> fetchSuppliers({
    required int page,
    required SortParams sortParams,
    String? searchQuery,
    required UserRole userRole,
  }) async {
    try {
      
      final query = supabase.from(SupabaseTables.fornecedor).select();
      
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.or('frn_nome.ilike.%$searchQuery%,frn_cnpj.ilike.%$searchQuery%');  
      }

      
      if (sortParams.activeSortColumnDataField != null) {
        query.order(sortParams.activeSortColumnDataField!, 
          ascending: sortParams.isAscending);
      }

      
      final int startIndex = (page - 1) * SystemConstants.itemsPorPagina;
      final dataResponse = await query.range(
        startIndex, 
        startIndex + SystemConstants.itemsPorPagina - 1
      );

      
      final countQuery = supabase.from(SupabaseTables.fornecedor).select();
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        countQuery.or('frn_nome.ilike.%$searchQuery%,frn_cnpj.ilike.%$searchQuery%');  
      }

      final countResponse = await countQuery;
      final totalCount = countResponse.length;

      final items = List<Map<String, dynamic>>.from(dataResponse);

      print('Fornecedores encontrados: ${items.length}');
      print('Total de fornecedores: $totalCount');

      return PaginatedResponse(items: items, totalCount: totalCount);
    } catch (e) {
      print('Erro ao buscar fornecedores: $e');
      return PaginatedResponse(items: [], totalCount: 0);
    }
  }
  Future<Map<String, dynamic>?> fetchSupplierById(int supplierId) async {
    try {
      final response = await supabase
          .from(SupabaseTables.fornecedor)
          .select()
          .eq('id', supplierId)
          .single();
      return response;
    } catch (e) {
      print('Erro ao buscar detalhes do fornecedor: $e');
      return null;
    }
  }

  Future<void> createSupplier(Map<String, dynamic> supplierPayload) async {
    try {
      await supabase
          .from(SupabaseTables.fornecedor)
          .insert(supplierPayload);
    } on PostgrestException catch (e) {
    
      print('Erro do Supabase ao criar fornecedor: ${e.message}');
      
      if (e.message.contains('fornecedor_frn_cnpj_key')) {  
        throw 'O CNPJ informado já está em uso.';
      } else {
        rethrow;
      }
    } catch (e) {

      print('Erro desconhecido ao criar fornecedor: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<void> updateSupplier(int supplierId, Map<String, dynamic> supplierData) async {
    try {
      await supabase
          .from(SupabaseTables.fornecedor)
          .update(supplierData)
          .eq('id', supplierId);
    } on PostgrestException catch (e) {
      print('Erro do Supabase ao atualizar fornecedor: ${e.message}');
      
      if (e.message.contains('fornecedor_frn_cnpj_key')) {  
        throw 'O CNPJ informado já está em uso.';
      } else {
        rethrow;
      }
    } catch (e) {
    
      print('Erro desconhecido ao atualizar fornecedor: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  Future<void> deactivateSupplier(int supplierId) async {
    try {
      await supabase
          .from(SupabaseTables.fornecedor)
          .delete()
          .eq('id', supplierId);
    } on PostgrestException catch (e) {
      
      print('Erro do Supabase ao deletar fornecedor: ${e.message}');
      throw 'Falha ao deletar fornecedor: ${e.message}';
    } catch (e) {
      
      print('Erro desconhecido ao deletar fornecedor: $e');
      throw 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }
}