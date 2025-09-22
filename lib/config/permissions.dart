enum UserRole {
  coronel,
  tenenteEstoque,
  tenenteFarmacia,
  soldadoEstoque,
  soldadoFarmacia,
}

enum AppPermission {
  accessAdminScreen,
}

const Map<UserRole, Set<AppPermission>> permissionsByRole = {
  UserRole.coronel: {
    AppPermission.accessAdminScreen,
  },
  UserRole.tenenteEstoque: {
    AppPermission.accessAdminScreen,
  },
  UserRole.tenenteFarmacia: {
    AppPermission.accessAdminScreen,
  },
  UserRole.soldadoEstoque: {
  },
  UserRole.soldadoFarmacia: {
  },
};