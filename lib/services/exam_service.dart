import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/models/exam_model.dart';

class ExamService {
  final supabase = Supabase.instance.client;

  Future<List<ExamModel>> fetchActiveExams() async {
    try {
      final response = await supabase
          .from(SupabaseTables.exame)
          .select()
          .eq(ExameFields.ativo, true)
          .order(ExameFields.nome);

      return (response as List).map((item) => ExamModel.fromMap(item)).toList();
    } catch (e) {
      print('Erro ao buscar exames: $e');
      rethrow;
    }
  }

  Future<List<ExamModel>> fetchExamsBySector(int sectorId) async {
    try {
      final response = await supabase
          .from(SupabaseTables.exame)
          .select()
          .eq(ExameFields.ativo, true)
          .eq(ExameFields.setorId, sectorId)
          .order(ExameFields.nome);

      return (response as List).map((item) => ExamModel.fromMap(item)).toList();
    } catch (e) {
      print('Erro ao buscar exames por setor: $e');
      rethrow;
    }
  }

  Future<ExamModel> createExam(ExamModel exam) async {
    try {
      final data = exam.toMapForInsert();
      final response = await supabase
          .from(SupabaseTables.exame)
          .insert(data)
          .select()
          .single();

      return ExamModel.fromMap(response);
    } catch (e) {
      print('Erro ao criar exame: $e');
      rethrow;
    }
  }

  Future<void> deactivateExam(int examId) async {
    try {
      await supabase
          .from(SupabaseTables.exame)
          .update({
            ExameFields.ativo: false,
            ExameFields.dataAtualizacao: DateTime.now().toIso8601String(),
          })
          .eq(ExameFields.id, examId);
    } catch (e) {
      print('Erro ao desativar exame: $e');
      rethrow;
    }
  }

  Future<ExamModel?> getExamById(int examId) async {
    try {
      final response = await supabase
          .from(SupabaseTables.exame)
          .select()
          .eq(ExameFields.id, examId)
          .maybeSingle();

      if (response == null) return null;
      return ExamModel.fromMap(response);
    } catch (e) {
      print('Erro ao buscar exame por ID: $e');
      rethrow;
    }
  }
}
