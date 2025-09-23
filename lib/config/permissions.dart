enum UserRole {
  coronel,
  tenenteEstoque,
  tenenteFarmacia,
  soldadoEstoque,
  soldadoFarmacia,
  soldadoComum,
}

enum AppPermission {
  accessAdminScreen,
  viewStockItems,
  viewPharmacyItems,
  createOrders,
  viewAllOrders,
  editItems,
  viewReports,
}

const Map<UserRole, Set<AppPermission>> permissionsByRole = {
  // Coronel: acesso total
  UserRole.coronel: {
    AppPermission.accessAdminScreen,
    AppPermission.viewStockItems,
    AppPermission.viewPharmacyItems,
    AppPermission.createOrders,
    AppPermission.viewAllOrders,
    AppPermission.editItems,
    AppPermission.viewReports,
  },

  // Tenente Estoque: permissões elevadas no setor de estoque
  UserRole.tenenteEstoque: {
    AppPermission.accessAdminScreen,
    AppPermission.viewStockItems,
    AppPermission.createOrders,
    AppPermission.viewAllOrders,
    AppPermission.editItems,
    AppPermission.viewReports,
  },

  // Tenente Farmácia: permissões elevadas no setor de farmácia
  UserRole.tenenteFarmacia: {
    AppPermission.accessAdminScreen,
    AppPermission.viewPharmacyItems,
    AppPermission.createOrders,
    AppPermission.viewAllOrders,
    AppPermission.editItems,
    AppPermission.viewReports,
  },

  // Soldado Estoque: ver itens do setor de estoque
  UserRole.soldadoEstoque: {
    AppPermission.viewStockItems,
    AppPermission.createOrders,
  },

  // Soldado Farmácia: ver itens do setor de farmácia
  UserRole.soldadoFarmacia: {
    AppPermission.viewPharmacyItems,
    AppPermission.createOrders,
  },

  // Soldado Comum: apenas criar pedidos
  UserRole.soldadoComum: {AppPermission.createOrders},
};
