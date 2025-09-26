class PedidoConstants {
  static const int statusPendente = 1;
  static const int statusConcluido = 2;
  static const int statusCancelado = 3;

  static const Map<int, String> statusDescricoes = {
    statusPendente: 'Pendente',
    statusConcluido: 'Concluído',
    statusCancelado: 'Cancelado',
  };

  static const int quantidadeMinima = 1;
  static const int quantidadeMaxima = 9999;

  static const String erroQuantidadeInsuficiente = 
      'Quantidade solicitada maior que disponível em estoque';
  static const String erroItemSetorDiferente = 
      'Item não pertence ao seu setor';
  static const String erroQuantidadeInvalida = 
      'Quantidade deve ser maior que zero';
  static const String erroPermissaoCancelamento = 
      'Você não tem permissão para cancelar este pedido';
  static const String erroPedidoJaCancelado = 
      'Este pedido já foi cancelado';
  static const String erroPedidoJaConcluido = 
      'Este pedido já foi concluído';
}

class SystemConstants {
  static const int nivelSoldado = 1;
  static const int nivelTenente = 2;
  static const int nivelCoronel = 3;

  static const int setorAlmoxarifado = 1;
  static const int setorFarmacia = 2;
  static const int setorManutencao = 3;

  static const int itemsPorPagina = 10;
  static const int itemsPorPaginaEstoque = 8;
}