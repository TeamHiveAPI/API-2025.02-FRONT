abstract class SupabaseTables {
  static const String fornecedor = 'fornecedor';
  static const String grupo = 'grupo';
  static const String item = 'item';
  static const String itemPedido = 'item_pedido';
  static const String itemPedidoCompra = 'item_pedido_compra';
  static const String lote = 'lote';
  static const String movEstoque = 'mov_estoque';
  static const String pedido = 'pedido';
  static const String pedidoCompra = 'pedido_compra';
  static const String setor = 'setor';
  static const String usuario = 'usuario';
  static const String exame = 'exame';
  static const String consultaMedica = 'consulta_medica';
}

const String fornTable = 'fornecedor';
const String fornId = 'id';
const String fornNome = 'frn_nome';
const String fornCnpj = 'frn_cnpj';
const String fornTelefone = 'frn_telefone';
const String fornEmail = 'frn_email';
const String fornItem = 'frn_item';
const String fornSetor = 'frn_setor_id';

abstract class GrupoFields {
  static const String id = 'id';
  static const String nome = 'grp_nome';
  static const String setorId = 'grp_setor_id';
}

abstract class ItemFields {
  static const String id = 'id';
  static const String nome = 'it_nome';
  static const String numFicha = 'it_num_ficha';
  static const String unidade = 'it_unidade';
  static const String minEstoque = 'it_min_estoque';
  static const String controlado = 'it_controlado';
  static const String grupoId = 'it_grupo_id';
  static const String ativo = 'it_ativo';
  static const String perecivel = 'it_perecivel';
  static const String qtdReservada = 'it_qtd_reservada';
}

abstract class ItemPedidoFields {
  static const String pedidoId = 'iped_pedido_id';
  static const String itemId = 'iped_item_id';
  static const String qtdSolicitada = 'iped_qtd_solicitada';
  static const String loteRetiradoId = 'iped_lote_retirado_id';
}

abstract class ItemPedidoCompraFields {
  static const String compraId = 'ipc_compra_id';
  static const String itemId = 'ipc_item_id';
  static const String qtdComprada = 'ipc_qtd_comprada';
}

abstract class LoteFields {
  static const String id = 'id';
  static const String itemId = 'lot_item_id';
  static const String codigo = 'lot_codigo';
  static const String dataEntrada = 'lot_data_entrada';
  static const String dataValidade = 'lot_data_validade';
  static const String fornecedorId = 'lot_fornecedor_id';
  static const String qtdAtual = 'lot_qtd_atual';
}

abstract class MovEstoqueFields {
  static const String id = 'id';
  static const String itemId = 'mve_item_id';
  static const String loteId = 'mve_lote_id';
  static const String tipo = 'mve_tipo';
  static const String qtdMovimentada = 'mve_qtd_movimentada';
  static const String dadosMov = 'mve_dados_mov';
  static const String dataMov = 'mve_data_mov';
}

abstract class PedidoFields {
  static const String id = 'id';
  static const String usuarioId = 'ped_usuario_id';
  static const String setorId = 'ped_setor_id';
  static const String motivoCancelamento = 'ped_motivo_cancelamento';
  static const String status = 'ped_status';
  static const String dados = 'ped_dados';
  static const String dataRetirada = 'ped_data_retirada';
  static const String dataSolicitada = 'ped_data_solicitada';
  static const String responsavelCancelamentoId =
      'ped_responsavel_cancelamento_id';
}

abstract class PedidoCompraFields {
  static const String id = 'id';
  static const String fornecedorId = 'pc_fornecedor_id';
  static const String dataPedido = 'pc_data_pedido';
  static const String dataPrevistaEntrega = 'pc_data_prevista_entrega';
  static const String dataEntrega = 'pc_data_entrega';
  static const String statusCompra = 'pc_status_compra';
}

abstract class SetorFields {
  static const String id = 'id';
  static const String nome = 'set_nome';
}

abstract class UsuarioFields {
  static const String id = 'id';
  static const String nome = 'usr_nome';
  static const String email = 'usr_email';
  static const String nivelAcesso = 'usr_nivel_acesso';
  static const String setorId = 'usr_setor_id';
  static const String cpf = 'usr_cpf';
  static const String authUid = 'usr_auth_uid';
  static const String fotoUrl = 'usr_foto_url';
  static const String ativo = 'usr_ativo';
  static const String primeiroLogin = 'usr_primeiro_login';
  static const String dataCriacao = 'usr_data_criacao';
  static const String telefone = 'usr_telefone';
  static const String horarioInicio = 'usr_horario_inicio';
  static const String horarioFim = 'usr_horario_fim';
}

abstract class ExameFields {
  static const String id = 'id';
  static const String nome = 'exa_nome';
  static const String preparoNecessario = 'exa_preparo_necessario';
  static const String documentosExigidos = 'exa_documentos_exigidos';
  static const String ativo = 'exa_ativo';
  static const String dataCriacao = 'exa_data_criacao';
  static const String dataAtualizacao = 'exa_data_atualizacao';
  static const String duracaoMinutos = 'exa_duracao_minutos';
  static const String setorId = 'exa_setor_id';
  static const String requerJejum = 'exa_requer_jejum';
  static const String requerAgendamento = 'exa_requer_agendamento';
}

abstract class ConsultaMedicaFields {
  static const String id = 'id';
  static const String pacienteId = 'con_paciente_id';
  static const String exameId = 'con_exame_id';
  static const String dataAgendamento = 'con_data_agendamento';
  static const String dataRealizacao = 'con_data_realizacao';
  static const String status = 'con_status';
  static const String observacoes = 'con_observacoes';
  static const String medicoResponsavelId = 'con_medico_responsavel_id';
  static const String dataCriacao = 'con_data_criacao';
  static const String dataAtualizacao = 'con_data_atualizacao';
}
