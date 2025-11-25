import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/auth_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/auth_gate.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _emailController;
  late TextEditingController _cpfController;
  late TextEditingController _dateController;

  final currentUser = UserService.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    _cpfController = TextEditingController(
      text: formatCPF(currentUser?.cpf ?? ''),
    );
    _dateController = TextEditingController(
      text: formatCreationDate(
        DateTime.tryParse(currentUser?.dataCriacao ?? ''),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cpfController.dispose();
    _dateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 200.0;
    const double photoRadius = 60.0;

    final cargoLabel = UserService.instance.getLabelCargoAtual();

    return Scaffold(
      backgroundColor: brandBlue,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight + photoRadius,
            child: Container(
              decoration: BoxDecoration(
                color: brandBlue,
                image: DecorationImage(
                  image: const AssetImage(
                    'assets/fundo-perfil.png',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    brandBlue.withAlpha(96),
                    BlendMode.multiply,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 48,
            right: 12,
            child: TextButton.icon(
              onPressed: () async {
                await AuthService.instance.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthGate()),
                  (Route<dynamic> route) => false,
                );
              },
              icon: const Icon(
                Icons.exit_to_app,
                color: Colors.white,
                size: 24,
              ),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          Positioned(
            top: headerHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    const SizedBox(height: photoRadius + 15),

                    Text(
                      (currentUser?.nome ?? 'Usuário').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: text40,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      cargoLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        color: text80,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    CustomTextFormField(
                      upperLabel: 'EMAIL',
                      controller: _emailController,
                      readOnly: true,
                    ),

                    const SizedBox(height: 16),

                    CustomTextFormField(
                      upperLabel: 'CPF',
                      controller: _cpfController,
                      readOnly: true,
                    ),

                    const SizedBox(height: 16),

                    CustomTextFormField(
                      upperLabel: 'ATIVO DESDE',
                      controller: _dateController,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: headerHeight - photoRadius,
            child: Container(
              width: photoRadius * 2,
              height: photoRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: FutureBuilder<String>(
                  future: UserService.instance.getSignedAvatarUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: photoRadius,
                          color: Colors.grey[600],
                        ),
                      );
                    }

                    final imageUrl = snapshot.data!;

                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: photoRadius * 2,
                      height: photoRadius * 2,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const ShimmerPlaceholder.circle(radius: 60),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: photoRadius,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
