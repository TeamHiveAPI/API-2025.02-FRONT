import 'package:flutter/material.dart';
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/auth_service.dart';
import 'package:sistema_almox/services/user_service.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final Function(int) onProfileTap;

  const CustomHeader({super.key, required this.onProfileTap});

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
                  onProfileTap(0);
                },
                child: FutureBuilder<String>(
                  future: UserService.instance.getSignedAvatarUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[200],
                        child: const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      );
                    }

                    final imageUrl = snapshot.data!;
                    return CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(imageUrl),
                      backgroundColor: Colors.grey[200],
                    );
                  },
                ),
              ),
              const Text(
                'SISTEMA ALMOX',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: brandBlue),
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
