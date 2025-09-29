enum UserRole {
  coronel,
  tenenteEstoque,
  tenenteFarmacia,
  tenenteOdonto,
  soldadoEstoque,
  soldadoFarmacia,
  soldadoOdonto,
  soldadoComum,
}

enum AppPermission {
  accessAdminScreen,
  viewStockItems,
  viewPharmacyItems,
  viewOdontoItems,
  createOrders,
  viewAllOrders,
  editItems,
  viewReports,
}

const Map<UserRole, Set<AppPermission>> permissionsByRole = {
  UserRole.coronel: {
    AppPermission.accessAdminScreen,
    AppPermission.viewStockItems,
    AppPermission.viewPharmacyItems,
    AppPermission.viewOdontoItems,
    AppPermission.createOrders,
    AppPermission.viewAllOrders,
    AppPermission.editItems,
    AppPermission.viewReports,
  },

  UserRole.tenenteEstoque: {
    AppPermission.accessAdminScreen,
    AppPermission.viewStockItems,
    AppPermission.createOrders,
    AppPermission.viewAllOrders,
    AppPermission.editItems,
    AppPermission.viewReports,
  },

  UserRole.tenenteFarmacia: {
    AppPermission.accessAdminScreen,
    AppPermission.viewPharmacyItems,
    AppPermission.createOrders,
    AppPermission.viewAllOrders,
    AppPermission.editItems,
    AppPermission.viewReports,
  },

  UserRole.tenenteOdonto: {
    AppPermission.accessAdminScreen,
    AppPermission.viewOdontoItems,
    AppPermission.createOrders,
    AppPermission.viewAllOrders,
    AppPermission.editItems,
    AppPermission.viewReports,
  },

  UserRole.soldadoEstoque: {
    AppPermission.viewStockItems,
    AppPermission.createOrders,
  },

  UserRole.soldadoFarmacia: {
    AppPermission.viewPharmacyItems,
    AppPermission.createOrders,
  },

  UserRole.soldadoOdonto: {
    AppPermission.viewOdontoItems,
    AppPermission.createOrders,
  },

  UserRole.soldadoComum: {AppPermission.createOrders},
};
