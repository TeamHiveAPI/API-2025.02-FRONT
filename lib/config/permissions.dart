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
  UserRole.coronel: {
    AppPermission.accessAdminScreen,
    AppPermission.viewStockItems,
    AppPermission.viewPharmacyItems,
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

  UserRole.soldadoEstoque: {
    AppPermission.viewStockItems,
    AppPermission.createOrders,
  },

  UserRole.soldadoFarmacia: {
    AppPermission.viewPharmacyItems,
    AppPermission.createOrders,
  },

  UserRole.soldadoComum: {AppPermission.createOrders},
};
