import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:sistema_almox/services/group_service.dart';
import 'package:sistema_almox/services/user_service.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _setorController = TextEditingController();
  bool _isSubmitting = false;

  final _groupService = GroupService();
  final _userService = UserService.instance;

  @override
  void initState() {
    super.initState();
    if (_userService.viewingSectorId != null) {
      _setorController.text = _userService.viewingSectorId.toString();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _setorController.dispose();
    super.dispose();
  }

  Future<void> _submitGroup() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final nome = _nomeController.text.trim();
      final setorId = int.parse(_setorController.text.trim());

      await _groupService.createGroup(
        name: nome,
        sectorId: setorId,
      );

      if (mounted) {
        showCustomSnackbar(context, 'Grupo criado com sucesso!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, 'Erro ao criar grupo: $e', isError: true);
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
            const InternalPageHeader(title: 'Registrar Novo Grupo'),
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
                        hintText: 'Digite o ID do setor',
                        controller: _setorController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'O ID do setor é obrigatório.';
                          }
                          if (int.tryParse(value) == null) {
                            return 'O ID do setor deve ser numérico.';
                          }
                          return null;
                        },
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
              buttonText:
                  _isSubmitting ? 'Registrando...' : 'Registrar Grupo',
              onButtonPressed: _isSubmitting ? null : _submitGroup,
            ),
          ],
        ),
      ),
    );
  }
}
