import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/screens/novo_soldado/form_handler.dart';
import 'package:sistema_almox/screens/novo_soldado/index.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/utils/formatters.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';

class DetalhesUsuarioModal extends StatefulWidget {
  final int idUsuario;
  final bool manageMode;

  const DetalhesUsuarioModal({
    super.key,
    required this.idUsuario,
    this.manageMode = false,
  });

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

  void _reactivateUser() async {
    if (_userData == null) return;
    await RegisterSoldierFormHandler().reactivateUser(context, _userData!);
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
    if (!_isLoading && _userData == null) {
      return const Center(child: Text('Usuário não encontrado.'));
    }

    final bool isUserActive = _isLoading
        ? true
        : (_userData![UsuarioFields.ativo] ?? true);
    final String? fotoUrl = _isLoading
        ? null
        : _userData![UsuarioFields.fotoUrl];
    final String nome = _isLoading
        ? ''
        : _userData![UsuarioFields.nome] ?? 'N/A';
    final String cpf = _isLoading ? '' : _userData![UsuarioFields.cpf] ?? 'N/A';
    final String email = _isLoading
        ? ''
        : _userData![UsuarioFields.email] ?? 'N/A';

    final String cargoNome = _isLoading
        ? ''
        : UserService.instance.getCargoNomeFromData(
            nivelAcesso: _userData![UsuarioFields.nivelAcesso] ?? 0,
            idSetor: _userData![UsuarioFields.setorId] ?? 0,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: _isLoading
                ? const ShimmerPlaceholder.circle(radius: 40)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: FutureBuilder<String>(
                      future: (fotoUrl != null && fotoUrl.isNotEmpty)
                          ? UserService.instance.createSignedUrlForAvatar(
                              fotoUrl,
                            )
                          : Future.value(''),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ShimmerPlaceholder.circle(radius: 40);
                        }

                        final signedUrl = snapshot.data ?? '';

                        return CachedNetworkImage(
                          imageUrl: signedUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const ShimmerPlaceholder.circle(radius: 40),
                          errorWidget: (context, url, error) => CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        DetailItemCard(
          label: "NOME",
          value: formatName(nome),
          copyButton: true,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 12),
        DetailItemCard(
          label: "CPF",
          value: formatCPF(cpf),
          copyButton: true,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 12),

        DetailItemCard(
          label: "EMAIL",
          value: email,
          copyButton: true,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 12),
        DetailItemCard(label: "CARGO", value: cargoNome, isLoading: _isLoading),

        if (widget.manageMode)
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: isUserActive
                ? Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: "Editar",
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    NewSoldierScreen(soldierToEdit: _userData),
                              ),
                            );
                          },
                          customIcon: 'assets/icons/edit.svg',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: "Redefinir",
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          secondary: true,
                        ),
                      ),
                    ],
                  )
                : CustomButton(
                    text: "Reativar Conta",
                    onPressed: _reactivateUser,
                    customIcon: 'assets/icons/key.svg',
                    green: true,
                    widthPercent: 1.0,
                  ),
          ),
      ],
    );
  }
}
