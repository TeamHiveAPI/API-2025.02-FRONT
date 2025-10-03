import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/group_service.dart';
import 'package:sistema_almox/services/sector_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/modal/base_bottom_sheet_modal.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';
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
  final _groupService = GroupService();
  final _sectorService = SectorService();

  String _sectorName = '';
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSectorName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSectorName() async {
    final int? viewingSectorId = UserService.instance.viewingSectorId;

    if (viewingSectorId == null) {
      if (mounted) {
        setState(() {
          _sectorName = 'Setor não encontrado';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final String? sectorName = await _sectorService.getSectorNameById(
        viewingSectorId,
      );
      if (mounted) {
        setState(() {
          _sectorName = sectorName ?? 'Setor Desconhecido';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sectorName = 'Erro ao carregar setor';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        'grp_nome': _nameController.text,
        'grp_setor_id': viewingSectorId,
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLoading)
                const ShimmerPlaceholder(height: 48)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 14.0,
                  ),
                  decoration: BoxDecoration(
                    color: brightGray,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(
                        context,
                      ).style.copyWith(fontSize: 15),
                      children: <TextSpan>[
                        const TextSpan(
                          text: 'Setor: ',
                          style: TextStyle(color: text60),
                        ),
                        TextSpan(
                          text: _sectorName,
                          style: const TextStyle(color: text60),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              CustomTextFormField(
                upperLabel: 'NOME DO GRUPO',
                hintText: 'Digite aqui',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo Obrigatório';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Cadastrar Grupo',
          icon: Icons.add,
          widthPercent: 1.0,
          onPressed: _isSaving ? null : _registerGroup,
          isLoading: _isSaving,
        ),
      ],
    );
  }
}
