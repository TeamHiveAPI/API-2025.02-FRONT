import 'package:flutter/material.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/modal/detalhe_card_modal.dart';

class MotivoCancelamentoModal extends StatefulWidget {
  final String motivo;
  final int? responsavelId;
  final void Function(int userId) onViewResponsavelDetails;

  const MotivoCancelamentoModal({
    super.key,
    required this.motivo,
    required this.responsavelId,
    required this.onViewResponsavelDetails,
  });

  @override
  State<MotivoCancelamentoModal> createState() =>
      _MotivoCancelamentoModalState();
}

class _MotivoCancelamentoModalState extends State<MotivoCancelamentoModal> {
  String _responsavelNome = '';
  bool _isLoadingNome = true;

  @override
  void initState() {
    super.initState();
    _fetchResponsavelNome();
  }

  Future<void> _fetchResponsavelNome() async {
    if (widget.responsavelId == null) {
      setState(() {
        _responsavelNome = 'Não informado';
        _isLoadingNome = false;
      });
      return;
    }

    try {
      final usuarioData = await UserService.instance.fetchUserById(
        widget.responsavelId!,
      );
      if (mounted) {
        setState(() {
          _responsavelNome =
              usuarioData?[UsuarioFields.nome] ?? 'Nome não encontrado';
          _isLoadingNome = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _responsavelNome = 'Erro ao buscar nome';
          _isLoadingNome = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        DetailItemCard(label: 'MOTIVO', value: widget.motivo),
        const SizedBox(height: 12),
        DetailItemCard(
          isLoading: _isLoadingNome,
          label: 'RESPONSÁVEL',
          value: _responsavelNome,
          onPressed: widget.responsavelId != null
              ? () => widget.onViewResponsavelDetails(widget.responsavelId!)
              : null,
        ),
      ],
    );
  }
}
