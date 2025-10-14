import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/cards/lieutenant.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/modal/content/detalhes_usuario_modal.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';

class LieutenantCards extends StatefulWidget {
  const LieutenantCards({super.key});

  @override
  State<LieutenantCards> createState() => _LieutenantCardsState();
}

class _LieutenantCardsState extends State<LieutenantCards> {
  late Future<Map<String, dynamic>> _almoxarifadoFuture;
  late Future<Map<String, dynamic>> _farmaciaFuture;
  final _userService = UserService.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _almoxarifadoFuture = _userService.fetchLieutenant(
      accessLevel: 2,
      sectorId: 1,
    );
    _farmaciaFuture = _userService.fetchLieutenant(accessLevel: 2, sectorId: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLieutenantCard(
          future: _almoxarifadoFuture,
          title: 'Tenente Almoxarifado',
        ),
        const SizedBox(height: 20),
        _buildLieutenantCard(
          future: _farmaciaFuture,
          title: 'Tenente Farmácia',
        ),
      ],
    );
  }

  Widget _buildLieutenantCard({
    required Future<Map<String, dynamic>> future,
    required String title,
  }) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerPlaceholder(height: 120);
        }
        if (userSnapshot.hasError) {
          return Center(child: Text('Erro: ${userSnapshot.error}'));
        }
        if (userSnapshot.hasData) {
          final userData = userSnapshot.data!;
          final userId = userData['id'] as int;
          final userName = userData['usr_nome'] as String;
          final photoPath = userData['usr_foto_url'] as String? ?? '';
          final lastModifiedString = userData['usr_data_criacao'] as String?;
          String formattedDate = 'Data não disponível';
          if (lastModifiedString != null) {
            try {
              final dateTime = DateTime.parse(lastModifiedString);
              formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
            } catch (e) {
              print("Erro ao formatar data: $e");
            }
          }
          final displayDate = 'Desde $formattedDate';

          return FutureBuilder<String>(
            future: _userService.createSignedUrlForAvatar(photoPath),
            builder: (context, urlSnapshot) {
              final imageUrl = (urlSnapshot.data ?? '').isNotEmpty
                  ? urlSnapshot.data!
                  : '';

              return Stack(
                children: [
                  LieutenantCard(
                    title: title,
                    name: formatName(userName),
                    date: displayDate,
                    imageUrl: imageUrl,
                  ),

                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          showCustomBottomSheet(
                            context: context,
                            title: "Detalhes do Usuário",
                            child: DetalhesUsuarioModal(
                              idUsuario: userId,
                              manageMode: true,
                            ),
                          );
                        },
                        splashColor: const Color.fromARGB(16, 0, 0, 0),
                        highlightColor: const Color.fromARGB(16, 0, 0, 0),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
