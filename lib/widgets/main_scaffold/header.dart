import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/main_scaffold/navbar.dart';
import 'package:sistema_almox/services/auth_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/app_routes.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String fotoUrl;
  final List<NavBarItemInfo> navBarItemsInfo;
  final Function(int) onProfileTap;

  const CustomHeader({
    super.key,
    required this.fotoUrl,
    required this.navBarItemsInfo,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  final perfilIndex = navBarItemsInfo.indexWhere(
                    (item) => item.label == 'Perfil',
                  );
                  if (perfilIndex != -1) {
                    onProfileTap(perfilIndex);
                  }
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: (fotoUrl.isNotEmpty)
                      ? AssetImage(fotoUrl)
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: (fotoUrl.isEmpty)
                      ? Icon(Icons.person, size: 20, color: Colors.grey[600])
                      : null,
                ),
              ),
              Text(
                UserService.instance.currentUser?.nome ?? 'SISTEMA ALMOX',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: brandBlue,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: InkWell(
                  onTap: () async {
                    await AuthService.instance.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    }
                  },
                  hoverColor: brandBlue.withAlpha(128),
                  splashColor: brandBlue.withAlpha(128),
                  highlightColor: brandBlue.withAlpha(128),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: brandBlueLight,
                    child: const Icon(
                      Icons.exit_to_app,
                      color: brandBlue,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
