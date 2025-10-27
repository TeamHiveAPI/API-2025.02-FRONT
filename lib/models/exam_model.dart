import 'package:sistema_almox/core/constants/database.dart' as db;

class ExamModel {
  final int id;
  final String nome;
  final String preparoNecessario;
  final String documentosExigidos;
  final bool ativo;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;
  final int duracaoMinutos;
  final int? setorId;
  final bool requerJejum;
  final bool requerAgendamento;

  ExamModel({
    required this.id,
    required this.nome,
    required this.preparoNecessario,
    required this.documentosExigidos,
    required this.ativo,
    this.dataCriacao,
    this.dataAtualizacao,
    required this.duracaoMinutos,
    this.setorId,
    required this.requerJejum,
    required this.requerAgendamento,
  });

  factory ExamModel.fromMap(Map<String, dynamic> map) {
    return ExamModel(
      id: map[db.ExameFields.id] as int,
      nome: map[db.ExameFields.nome] as String,
      preparoNecessario: map[db.ExameFields.preparoNecessario] as String? ?? '',
      documentosExigidos:
          map[db.ExameFields.documentosExigidos] as String? ?? '',
      ativo: map[db.ExameFields.ativo] as bool? ?? true,
      dataCriacao: map[db.ExameFields.dataCriacao] != null
          ? DateTime.parse(map[db.ExameFields.dataCriacao] as String)
          : null,
      dataAtualizacao: map[db.ExameFields.dataAtualizacao] != null
          ? DateTime.parse(map[db.ExameFields.dataAtualizacao] as String)
          : null,
      duracaoMinutos: map[db.ExameFields.duracaoMinutos] as int? ?? 30,
      setorId: map[db.ExameFields.setorId] as int?,
      requerJejum: map[db.ExameFields.requerJejum] as bool? ?? false,
      requerAgendamento: map[db.ExameFields.requerAgendamento] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      db.ExameFields.id: id,
      db.ExameFields.nome: nome,
      db.ExameFields.preparoNecessario: preparoNecessario,
      db.ExameFields.documentosExigidos: documentosExigidos,
      db.ExameFields.ativo: ativo,
      db.ExameFields.dataCriacao: dataCriacao?.toIso8601String(),
      db.ExameFields.dataAtualizacao: dataAtualizacao?.toIso8601String(),
      db.ExameFields.duracaoMinutos: duracaoMinutos,
      db.ExameFields.setorId: setorId,
      db.ExameFields.requerJejum: requerJejum,
      db.ExameFields.requerAgendamento: requerAgendamento,
    };
  }

  Map<String, dynamic> toMapForInsert() {
    return {
      db.ExameFields.nome: nome,
      db.ExameFields.preparoNecessario: preparoNecessario,
      db.ExameFields.documentosExigidos: documentosExigidos,
      db.ExameFields.ativo: ativo,
      db.ExameFields.duracaoMinutos: duracaoMinutos,
      db.ExameFields.setorId: setorId,
      db.ExameFields.requerJejum: requerJejum,
      db.ExameFields.requerAgendamento: requerAgendamento,
    };
  }
}
