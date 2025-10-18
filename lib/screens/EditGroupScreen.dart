import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:sistema_almox/services/group_service.dart';

class EditGroupScreen extends StatefulWidget {
  final int groupId;
  final String initialName;
  final int initialSectorId;

  const EditGroupScreen({
    super.key,
    required this.groupId,
    required this.initialName,
    required this.initialSectorId,
  });

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _setorController = TextEditingController();
  bool _isSubmitting = false;

  final _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.initialName;
    _setorController.text = widget.initialSectorId.toString();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _setorController.dispose();
    super.dispose();
  }

  Future<void> _submitEdit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final nome = _nomeController.text.trim();
      // setorId is read-only on this screen and not used in update

      await _groupService.updateGroup(
        id: widget.groupId,
        newName: nome,
      );

      if (mounted) {
        showCustomSnackbar(context, 'Grupo atualizado com sucesso!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, 'Erro ao atualizar grupo: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const InternalPageHeader(title: 'Editar Grupo'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      CustomTextFormField(
                        upperLabel: 'SETOR (ID)',
                        hintText: 'ID do setor',
                        controller: _setorController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        readOnly: true, 
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset('assets/icons/office.svg'),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            InternalPageBottom(
              buttonText: _isSubmitting ? 'Atualizando...' : 'Atualizar Grupo',
              onButtonPressed: _isSubmitting ? null : _submitEdit,
            ),
          ],
        ),
      ),
    );
  }
}
