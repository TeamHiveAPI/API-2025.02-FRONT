import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/models/consulta_medica_model.dart';

class ConsultaMedicoService {
  final supabase = Supabase.instance.client;

  Future<void> updateWorkSchedule({
    required int medicoId,
    required String horarioInicio,
    required String horarioFim,
  }) async {
    try {
      await supabase
          .from(SupabaseTables.usuario)
          .update({
            UsuarioFields.horarioInicio: horarioInicio,
            UsuarioFields.horarioFim: horarioFim,
          })
          .eq(UsuarioFields.id, medicoId);
    } catch (e) {
      print('Erro ao atualizar horário de trabalho: $e');
      rethrow;
    }
  }

  Future<Map<String, String>?> getWorkSchedule(int medicoId) async {
    try {
      final response = await supabase
          .from(SupabaseTables.usuario)
          .select('${UsuarioFields.horarioInicio}, ${UsuarioFields.horarioFim}')
          .eq(UsuarioFields.id, medicoId)
          .maybeSingle();

      if (response == null) return null;

      return {
        'horarioInicio':
            response[UsuarioFields.horarioInicio] as String? ?? '08:00',
        'horarioFim': response[UsuarioFields.horarioFim] as String? ?? '17:00',
      };
    } catch (e) {
      print('Erro ao buscar horário de trabalho: $e');
      rethrow;
    }
  }

  Future<void> updateAppointmentStatus(
    int appointmentId,
    StatusConsulta newStatus,
  ) async {
    try {
      final updateData = <String, dynamic>{
        ConsultaMedicaFields.status: newStatus.name,
        ConsultaMedicaFields.dataAtualizacao: DateTime.now().toIso8601String(),
      };

      if (newStatus == StatusConsulta.realizada) {
        updateData[ConsultaMedicaFields.dataRealizacao] = DateTime.now()
            .toIso8601String();
      }

      await supabase
          .from(SupabaseTables.consultaMedica)
          .update(updateData)
          .eq(ConsultaMedicaFields.id, appointmentId);
    } catch (e) {
      print('Erro ao atualizar status da consulta: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchDoctorAppointments(
    int doctorId,
  ) async {
    try {
      final response = await supabase
          .from(SupabaseTables.consultaMedica)
          .select('''
            *,
            exame:${SupabaseTables.exame}!${ConsultaMedicaFields.exameId}(
              ${ExameFields.nome},
              ${ExameFields.preparoNecessario}
            ),
            paciente:${SupabaseTables.usuario}!${ConsultaMedicaFields.pacienteId}(
              ${UsuarioFields.nome},
              ${UsuarioFields.cpf},
              ${UsuarioFields.telefone}
            )
          ''')
          .eq(ConsultaMedicaFields.medicoResponsavelId, doctorId)
          .order(ConsultaMedicaFields.dataAgendamento, ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Erro ao buscar consultas do médico: $e');
      rethrow;
    }
  }
}
