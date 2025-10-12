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
}

abstract class FornecedorFields {
  static const String id = 'id';
  static const String nome = 'frn_nome';
  static const String cnpj = 'frn_cnpj';
  static const String contato = 'frn_contato';
}

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
}
