import 'package:flutter/material.dart';
import 'package:sistema_almox/services/group_service.dart';
import 'package:sistema_almox/services/sector_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/modal/base_modal.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

Future<bool?> showNewGroupModal(BuildContext context) async {
  return showCustomBottomSheet<bool>(
    context: context,
    title: 'Cadastrar Novo Grupo',
    child: const NewGroupModal(),
  );
}

class NewGroupModal extends StatefulWidget {
  const NewGroupModal({super.key});

  @override
  State<NewGroupModal> createState() => _NewGroupModalState();
}

class _NewGroupModalState extends State<NewGroupModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sectorController = TextEditingController();
  final _groupService = GroupService();
  final _sectorService = SectorService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSectorName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sectorController.dispose();
    super.dispose();
  }

  Future<void> _loadSectorName() async {
    final int? viewingSectorId = UserService.instance.viewingSectorId;

    if (viewingSectorId == null) {
      _sectorController.text = 'Setor não encontrado';
      return;
    }

    try {
      final String? sectorName =
          await _sectorService.getSectorNameById(viewingSectorId);
      _sectorController.text = sectorName ?? 'Setor Desconhecido';
    } catch (e) {
      _sectorController.text = 'Erro ao carregar setor';
    }
  }

  Future<void> _registerGroup() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final int? viewingSectorId = UserService.instance.viewingSectorId;
      if (viewingSectorId == null) {
        throw 'ID do setor de visualização não encontrado.';
      }

      final payload = {
        'nome': _nameController.text,
        'id_setor': viewingSectorId,
      };

      await _groupService.createGroup(payload);
      if (mounted) {
        showCustomSnackbar(context, 'Grupo cadastrado com sucesso!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) showCustomSnackbar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                upperLabel: 'SETOR',
                hintText: 'Nome do Setor',
                controller: _sectorController,
                readOnly: true,
                validator: (_) => null,
              ),
              const SizedBox(height: 24),
              CustomTextFormField(
                upperLabel: 'NOME DO GRUPO',
                hintText: 'Ex: EPIs, Medicamentos de Alto Custo, etc.',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O nome do grupo é obrigatório.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        InternalPageBottom(
          buttonText: 'Cadastrar Grupo',
          onButtonPressed: _isSaving ? null : _registerGroup,
          isEditMode: false,
          isLoading: _isSaving,
        ),
      ],
    );
  }
}
