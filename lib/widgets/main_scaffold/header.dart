import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/auth_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';

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
                    if (snapshot.connectionState != ConnectionState.waiting &&
                        (!snapshot.hasData || snapshot.data!.isEmpty)) {
                      return CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[200],
                        child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                      );
                    }

                    final imageUrl = snapshot.data ?? '';

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(18.0),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerPlaceholder.circle(radius: 18),
                        errorWidget: (context, url, error) => CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[200],
                          child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
                        ),
                      ),
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
