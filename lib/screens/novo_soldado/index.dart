import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/screens/novo_soldado/form_handler.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';

class NewSoldierScreen extends StatefulWidget {
  final Map<String, dynamic>? soldierToEdit;
  const NewSoldierScreen({super.key, this.soldierToEdit});

  @override
  State<NewSoldierScreen> createState() => _NewSoldierScreenState();
}

class _NewSoldierScreenState extends State<NewSoldierScreen> {
  final _formHandler = RegisterSoldierFormHandler();
  bool get isEditMode => widget.soldierToEdit != null;

  @override
  void initState() {
    super.initState();
    _formHandler.init(widget.soldierToEdit);
    _formHandler.addListener(_onFormHandlerChange);
  }

  @override
  void dispose() {
    _formHandler.removeListener(_onFormHandlerChange);
    _formHandler.dispose();
    super.dispose();
  }

  void _onFormHandlerChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final viewingSectorId = UserService.instance.viewingSectorId;
    final sectorName = viewingSectorId == 1
        ? 'Almoxarifado'
        : (viewingSectorId == 2 ? 'Farmácia' : 'N/A');
    _formHandler.sectorController.text = sectorName;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            InternalPageHeader(
              title: isEditMode ? 'Editar Soldado' : 'Cadastrar Novo Soldado',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formHandler.formKey,
                  autovalidateMode: _formHandler.hasSubmitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _formHandler.pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    _formHandler.selectedImage != null
                                    ? FileImage(
                                        File(_formHandler.selectedImage!.path),
                                      )
                                    : null,
                                child: _formHandler.selectedImage == null
                                    ? Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey[500],
                                        size: 30,
                                      )
                                    : null,
                              ),

                              if (_formHandler.selectedImage != null)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: brandBlue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/switch.svg',
                                      width: 20,
                                      height: 20,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomTextFormField(
                        upperLabel: 'NOME COMPLETO',
                        hintText: 'Digite aqui',
                        controller: _formHandler.nameController,
                        validator: (value) =>
                            _formHandler.validateRequired(value, 'Nome'),
                      ),

                      const SizedBox(height: 24),

                      CustomTextFormField(
                        upperLabel: 'CPF',
                        hintText: '000.000.000-00',
                        controller: _formHandler.cpfController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_formHandler.cpfMaskFormatter],
                        validator: (value) =>
                            _formHandler.validateRequired(value, 'CPF'),
                      ),

                      const SizedBox(height: 24),

                      CustomTextFormField(
                        upperLabel: 'EMAIL',
                        hintText: 'exemplo@email.com',
                        controller: _formHandler.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _formHandler.validateEmail,
                      ),

                      const SizedBox(height: 24),

                      CustomTextFormField(
                        upperLabel: 'SETOR',
                        hintText: '',
                        readOnly: true,
                        controller: _formHandler.sectorController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            InternalPageBottom(
              buttonText: isEditMode
                  ? 'Salvar Alterações'
                  : 'Cadastrar Soldado',
              onButtonPressed: _formHandler.isSaving
                  ? null
                  : () {
                      if (isEditMode) {
                        _formHandler.updateSoldier(
                          context,
                          widget.soldierToEdit!,
                        );
                      } else {
                        _formHandler.registerSoldier(
                          context,
                          _formHandler.selectedImage,
                        );
                      }
                    },
              isLoading: _formHandler.isSaving,
              isEditMode: isEditMode,
            ),
          ],
        ),
      ),
    );
  }
}
