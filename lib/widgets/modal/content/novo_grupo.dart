import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/group_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/modal/base_center_modal.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:sistema_almox/widgets/toggle_sector_buttons.dart';

class NovoGrupoModal extends StatefulWidget {
  final Map<String, dynamic>? groupToEdit;

  const NovoGrupoModal({super.key, this.groupToEdit});

  @override
  State<NovoGrupoModal> createState() => _NovoGrupoModalState();
}

class _NovoGrupoModalState extends State<NovoGrupoModal> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _readOnlySectorController = TextEditingController();

  late int _selectedSectorId;
  bool _isSubmitting = false;
  bool get _isEditing => widget.groupToEdit != null;

  final _groupService = GroupService();
  final _userService = UserService.instance;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final currentUser = _userService.currentUser;
    final bool isCoronel = currentUser?.role == UserRole.coronel;

    if (_isEditing) {
      _nomeController.text = widget.groupToEdit!['grp_nome'] ?? '';
      _selectedSectorId = widget.groupToEdit!['grp_setor_id'] ?? 1;
    } else {
      if (isCoronel) {
        _selectedSectorId = _userService.viewingSectorId ?? 1;
      } else {
        _selectedSectorId = currentUser?.idSetor ?? 1;
      }
    }

    if (!isCoronel || _isEditing) {
      _readOnlySectorController.text = _getSectorName(_selectedSectorId);
    }
  }

  String _getSectorName(int id) {
    if (id == 1) return 'Almoxarifado';
    if (id == 2) return 'Farmácia';
    return 'Desconhecido';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _readOnlySectorController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final nome = _nomeController.text.trim();

      if (_isEditing) {
        await _groupService.updateGroup(
          id: widget.groupToEdit!['id'],
          newName: nome,
        );
        if (mounted) {
          showCustomSnackbar(context, 'Grupo atualizado com sucesso!');
        }
      } else {
        await _groupService.createGroup(
          name: nome,
          sectorId: _selectedSectorId,
        );
        if (mounted) {
          showCustomSnackbar(context, 'Grupo criado com sucesso!');
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          'Erro ao ${_isEditing ? "atualizar" : "criar"} grupo: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleDelete() async {
    final bool? confirmed = await showCustomDialog(
      context: context,
      title: 'Confirmar Exclusão',
      primaryButtonText: 'Excluir',
      primaryButtonDanger: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Tem certeza que deseja excluir este grupo?',
            textAlign: TextAlign.center,
            style: TextStyle(color: text60, fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            'Esta ação não pode ser desfeita e pode afetar itens vinculados.',
            textAlign: TextAlign.center,
            style: TextStyle(color: text60, fontSize: 14),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      await _groupService.deleteGroup(widget.groupToEdit!['id']);

      if (mounted) {
        showCustomSnackbar(context, 'Grupo excluído com sucesso!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, 'Erro ao excluir grupo: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _userService.currentUser;
    final bool isCoronel = currentUser?.role == UserRole.coronel;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextFormField(
            upperLabel: 'NOME DO GRUPO',
            hintText: 'Digite o nome do grupo',
            controller: _nomeController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'O nome do grupo é obrigatório.';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          if (isCoronel && !_isEditing) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'SETOR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            SectorToggleButtons(
              currentSectorId: _selectedSectorId,
              onSectorSelected: (int newId) {
                setState(() => _selectedSectorId = newId);
              },
            ),
          ] else ...[
            CustomTextFormField(
              upperLabel: 'SETOR',
              controller: _readOnlySectorController,
              readOnly: true,
            ),
          ],

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: (_isEditing ? 'Salvar Alterações' : 'Registrar Grupo'),
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  isLoading: _isSubmitting,
                  icon: Icons.add,
                ),
              ),

              if (_isEditing) ...[
                const SizedBox(width: 16),

                CustomButton(
                  squareMode: true,
                  danger: true,
                  onPressed: _isSubmitting ? null : _handleDelete,
                  borderRadius: 8.0,
                  customIcon: "assets/icons/trash.svg",
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
