import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/models/consulta_medica_model.dart';

class ConsultaService {
  final supabase = Supabase.instance.client;

  Future<List<ConsultaMedicaModel>> fetchAppointmentsByPatient(
    int patientId,
  ) async {
    try {
      final response = await supabase
          .from(SupabaseTables.consultaMedica)
          .select()
          .eq(ConsultaMedicaFields.pacienteId, patientId)
          .order(ConsultaMedicaFields.dataAgendamento, ascending: false);

      return (response as List)
          .map((item) => ConsultaMedicaModel.fromMap(item))
          .toList();
    } catch (e) {
      print('Erro ao buscar consultas do paciente: $e');
      rethrow;
    }
  }

  Future<List<ConsultaMedicaModel>> fetchAppointmentsByDoctor(
    int doctorId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = supabase
          .from(SupabaseTables.consultaMedica)
          .select()
          .eq(ConsultaMedicaFields.medicoResponsavelId, doctorId);

      if (startDate != null) {
        query = query.gte(
          ConsultaMedicaFields.dataAgendamento,
          startDate.toIso8601String(),
        );
      }
      if (endDate != null) {
        query = query.lte(
          ConsultaMedicaFields.dataAgendamento,
          endDate.toIso8601String(),
        );
      }

      final response = await query.order(ConsultaMedicaFields.dataAgendamento);

      return (response as List)
          .map((item) => ConsultaMedicaModel.fromMap(item))
          .toList();
    } catch (e) {
      print('Erro ao buscar consultas do médico: $e');
      rethrow;
    }
  }

  Future<bool> checkAvailability({
    required DateTime dateTime,
    required int doctorId,
  }) async {
    try {
      final dateOnly = dateTime.toIso8601String().split('T')[0];
      final startDateTime = '${dateOnly}T00:00:00.000Z';
      final endDateTime = '${dateOnly}T23:59:59.999Z';

      final response = await supabase
          .from(SupabaseTables.consultaMedica)
          .select()
          .eq('con_medico_responsavel_id', doctorId)
          .eq('con_status', 'agendada')
          .gte('con_data_agendamento', startDateTime)
          .lt('con_data_agendamento', endDateTime);

      return (response as List).isEmpty;
    } catch (e) {
      print('Erro ao verificar disponibilidade: $e');
      rethrow;
    }
  }

  Future<ConsultaMedicaModel> createAppointment(
    ConsultaMedicaModel appointment,
  ) async {
    try {
      final data = appointment.toMapForInsert();

      final response = await supabase
          .from(SupabaseTables.consultaMedica)
          .insert(data)
          .select()
          .single();

      return ConsultaMedicaModel.fromMap(response);
    } catch (e) {
      print('Erro ao criar consulta: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAppointmentsWithDetails({
    int? patientId,
    int? doctorId,
  }) async {
    try {
      var query = supabase.from(SupabaseTables.consultaMedica).select('''
            *,
            exame:${SupabaseTables.exame}!${ConsultaMedicaFields.exameId}(
              ${ExameFields.nome},
              ${ExameFields.preparoNecessario},
              ${ExameFields.duracaoMinutos}
            ),
            paciente:${SupabaseTables.usuario}!${ConsultaMedicaFields.pacienteId}(
              ${UsuarioFields.nome},
              ${UsuarioFields.cpf},
              ${UsuarioFields.email}
            ),
            medico:${SupabaseTables.usuario}!${ConsultaMedicaFields.medicoResponsavelId}(
              ${UsuarioFields.nome},
              ${UsuarioFields.email}
            )
          ''');

      if (patientId != null) {
        query = query.eq(ConsultaMedicaFields.pacienteId, patientId);
      }
      if (doctorId != null) {
        query = query.eq(ConsultaMedicaFields.medicoResponsavelId, doctorId);
      }

      final response = await query.order(
        ConsultaMedicaFields.dataAgendamento,
        ascending: false,
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Erro ao buscar consultas com detalhes: $e');
      rethrow;
    }
  }
}
