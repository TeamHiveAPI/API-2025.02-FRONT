import 'package:sistema_almox/core/constants/database.dart' as db;

enum StatusConsulta { agendada, realizada, cancelada, reagendada }

class ConsultaMedicaModel {
  final int id;
  final int pacienteId;
  final int exameId;
  final DateTime? dataAgendamento;
  final DateTime? dataRealizacao;
  final StatusConsulta status;
  final String? observacoes;
  final int? medicoResponsavelId;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  ConsultaMedicaModel({
    required this.id,
    required this.pacienteId,
    required this.exameId,
    this.dataAgendamento,
    this.dataRealizacao,
    required this.status,
    this.observacoes,
    this.medicoResponsavelId,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  factory ConsultaMedicaModel.fromMap(Map<String, dynamic> map) {
    final statusStr = map[db.ConsultaMedicaFields.status] as String;

    StatusConsulta status;
    switch (statusStr) {
      case 'realizada':
        status = StatusConsulta.realizada;
        break;
      case 'cancelada':
        status = StatusConsulta.cancelada;
        break;
      case 'reagendada':
        status = StatusConsulta.reagendada;
        break;
      default:
        status = StatusConsulta.agendada;
    }

    return ConsultaMedicaModel(
      id: map[db.ConsultaMedicaFields.id] as int,
      pacienteId: map[db.ConsultaMedicaFields.pacienteId] as int,
      exameId: map[db.ConsultaMedicaFields.exameId] as int,
      dataAgendamento: map[db.ConsultaMedicaFields.dataAgendamento] != null
          ? DateTime.parse(
              map[db.ConsultaMedicaFields.dataAgendamento] as String,
            )
          : null,
      dataRealizacao: map[db.ConsultaMedicaFields.dataRealizacao] != null
          ? DateTime.parse(
              map[db.ConsultaMedicaFields.dataRealizacao] as String,
            )
          : null,
      status: status,
      observacoes: map[db.ConsultaMedicaFields.observacoes] as String?,
      medicoResponsavelId:
          map[db.ConsultaMedicaFields.medicoResponsavelId] as int?,
      dataCriacao: map[db.ConsultaMedicaFields.dataCriacao] != null
          ? DateTime.parse(map[db.ConsultaMedicaFields.dataCriacao] as String)
          : null,
      dataAtualizacao: map[db.ConsultaMedicaFields.dataAtualizacao] != null
          ? DateTime.parse(
              map[db.ConsultaMedicaFields.dataAtualizacao] as String,
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      db.ConsultaMedicaFields.id: id,
      db.ConsultaMedicaFields.pacienteId: pacienteId,
      db.ConsultaMedicaFields.exameId: exameId,
      db.ConsultaMedicaFields.dataAgendamento: dataAgendamento
          ?.toIso8601String(),
      db.ConsultaMedicaFields.dataRealizacao: dataRealizacao?.toIso8601String(),
      db.ConsultaMedicaFields.status: status.name,
      db.ConsultaMedicaFields.observacoes: observacoes,
      db.ConsultaMedicaFields.medicoResponsavelId: medicoResponsavelId,
      db.ConsultaMedicaFields.dataCriacao: dataCriacao?.toIso8601String(),
      db.ConsultaMedicaFields.dataAtualizacao: dataAtualizacao
          ?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMapForInsert() {
    return {
      db.ConsultaMedicaFields.pacienteId: pacienteId,
      db.ConsultaMedicaFields.exameId: exameId,
      db.ConsultaMedicaFields.dataAgendamento: dataAgendamento
          ?.toIso8601String(),
      db.ConsultaMedicaFields.dataRealizacao: dataRealizacao?.toIso8601String(),
      db.ConsultaMedicaFields.status: status.name,
      db.ConsultaMedicaFields.observacoes: observacoes,
      db.ConsultaMedicaFields.medicoResponsavelId: medicoResponsavelId,
    };
  }

  bool get isAgendada => status == StatusConsulta.agendada;
  bool get isRealizada => status == StatusConsulta.realizada;
  bool get isCancelada => status == StatusConsulta.cancelada;
  bool get isReagendada => status == StatusConsulta.reagendada;
}
