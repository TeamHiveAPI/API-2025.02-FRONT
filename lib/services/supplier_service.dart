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
      final query = supabase
          .from(SupabaseTables.fornecedor)
          .select('id, frn_nome, frn_cnpj, frn_telefone, frn_email, frn_item, setor(set_nome)');

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.or('frn_nome.ilike.%$searchQuery%,frn_cnpj.ilike.%$searchQuery%');
      }

      final int startIndex = (page - 1) * SystemConstants.itemsPorPagina;
      final dataResponse = await query.range(
        startIndex,
        startIndex + SystemConstants.itemsPorPagina - 1,
      );

      final items = List<Map<String, dynamic>>.from(dataResponse);

      
      for (final item in items) {
        if (item['setor'] != null) {
          
          if (item['setor'] is List && (item['setor'] as List).isNotEmpty) {
            item['frn_setor_id'] = (item['setor'] as List).map((s) => s['set_nome']).join(', ');
          } else if (item['setor'] is Map && item['setor']['set_nome'] != null) {
            item['frn_setor_id'] = item['setor']['set_nome'];
          } else {
            item['frn_setor_id'] = '';
          }
        } else {
          item['frn_setor_id'] = '';
        }
      }


      final countResponse = await supabase
          .from(SupabaseTables.fornecedor)
          .select('id');

      return PaginatedResponse(
        items: items,
        totalCount: countResponse.length,
      );
    } catch (e) {
      print('Erro ao buscar fornecedores: $e');
      return PaginatedResponse(items: [], totalCount: 0);
    }
  }

    Future<Map<String, dynamic>?> fetchSupplierById(int supplierId) async {
      try {
        final response = await supabase
          .from(SupabaseTables.fornecedor)
          .select('*, setor(set_nome)')
          .eq('id', supplierId)
          .single();

      if (response['setor'] != null) {
        response['frn_setor_id'] = response['setor']['set_nome']; 
      } else {
        response['frn_setor_id'] = 'Sem setor';
      }


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