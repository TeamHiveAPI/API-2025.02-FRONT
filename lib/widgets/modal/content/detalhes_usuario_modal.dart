import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';

class DetalhesUsuarioModal extends StatefulWidget {
  final int idUsuario;

  const DetalhesUsuarioModal({super.key, required this.idUsuario});

  @override
  State<DetalhesUsuarioModal> createState() => _DetalhesUsuarioModalState();
}

class _DetalhesUsuarioModalState extends State<DetalhesUsuarioModal> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await UserService.instance.fetchUserById(widget.idUsuario);
    if (mounted) {
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_userData == null) {
      return const Center(child: Text('Usuário não encontrado.'));
    }

    return _buildLoadedState();
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Center(child: ShimmerPlaceholder.circle(radius: 40)),
        SizedBox(height: 16),
        ShimmerPlaceholder(height: 56),
        SizedBox(height: 12),
        ShimmerPlaceholder(height: 56),
        SizedBox(height: 12),
        ShimmerPlaceholder(height: 56),
      ],
    );
  }

  Widget _buildLoadedState() {
    final String? fotoUrl = _userData![UsuarioFields.fotoUrl];
    final String nome = _userData![UsuarioFields.nome] ?? 'N/A';
    final String cpf = _userData![UsuarioFields.cpf] ?? 'N/A';
    final String email = _userData![UsuarioFields.email] ?? 'N/A';
    final int nivelAcesso = _userData![UsuarioFields.nivelAcesso] ?? 0;
    final int idSetor = _userData![UsuarioFields.setorId] ?? 0;

    final cargoNome = UserService.instance.getCargoNomeFromData(
      nivelAcesso: nivelAcesso,
      idSetor: idSetor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: FutureBuilder<String>(
                future: (fotoUrl != null && fotoUrl.isNotEmpty)
                    ? UserService.instance.createSignedUrlForAvatar(fotoUrl)
                    : Future.value(''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.waiting &&
                      (snapshot.data == null || snapshot.data!.isEmpty)) {
                    return const CircleAvatar(
                      radius: 40,
                      backgroundColor: coolGray,
                    );
                  }

                  final signedUrl = snapshot.data ?? '';

                  return CachedNetworkImage(
                    imageUrl: signedUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const ShimmerPlaceholder.circle(radius: 40),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      radius: 40,
                      backgroundColor: coolGray,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DetailItemCard(label: "NOME", value: nome),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DetailItemCard(label: "CPF", value: formatCPF(cpf)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DetailItemCard(label: "EMAIL", value: email),
        const SizedBox(height: 12),
        DetailItemCard(label: "CARGO", value: cargoNome),
      ],
    );
  }
}
