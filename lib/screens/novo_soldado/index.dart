import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/screens/novo_soldado/form_handler.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/modal/base_center_modal.dart';
import 'package:sistema_almox/widgets/radio_button.dart';

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

    _formHandler.addListener(_onFormHandlerChange);
    _formHandler.init(widget.soldierToEdit);
  }

  @override
  void didUpdateWidget(covariant NewSoldierScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.soldierToEdit != oldWidget.soldierToEdit) {
      _formHandler.init(widget.soldierToEdit);
    }
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

  void _deactivateUser() async {
    final bool? confirmed = await showCustomDialog(
      context: context,
      title: 'Confirmar Desativação',
      primaryButtonText: 'Desativar',
      primaryButtonDanger: true,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Tem certeza que deseja desativar este usuário?',
            style: TextStyle(color: text60, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'Ele perderá o acesso ao sistema até ser reativado.',
            style: TextStyle(color: text60, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _formHandler.deactivateUser(context, widget.soldierToEdit!);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLieutenant =
        isEditMode && widget.soldierToEdit?['usr_nivel_acesso'] == 2;
    String sectorName;

    if (isLieutenant) {
      final tenantSectorId = widget.soldierToEdit?['usr_setor_id'];
      sectorName = tenantSectorId == 1
          ? 'Almoxarifado'
          : (tenantSectorId == 2 ? 'Farmácia' : 'N/A');
    } else {
      final viewingSectorId = UserService.instance.viewingSectorId;
      sectorName = viewingSectorId == 1
          ? 'Almoxarifado'
          : (viewingSectorId == 2 ? 'Farmácia' : 'N/A');
    }

    _formHandler.sectorController.text = sectorName;

    String roleName = 'Soldado';
    if (isLieutenant) {
      roleName = 'Tenente';
    }

    final String pageTitle = isEditMode
        ? 'Editar $roleName'
        : 'Cadastrar Novo $roleName';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            InternalPageHeader(title: pageTitle),
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

                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: _formHandler.pickImage,
                                  splashColor: const Color.fromARGB(
                                    16,
                                    0,
                                    0,
                                    0,
                                  ),
                                  highlightColor: const Color.fromARGB(
                                    16,
                                    0,
                                    0,
                                    0,
                                  ),
                                ),
                              ),
                            ),

                            if (_formHandler.selectedImage != null)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Material(
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  color: const Color.fromARGB(255, 70, 70, 70),
                                  elevation: 0,
                                  child: InkWell(
                                    onTap: _formHandler.clearImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
                        readOnly: isEditMode ? true : false,
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

                      if (isLieutenant)
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'É NOVO TITULAR?',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: text60,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CustomRadioButton<bool>(
                                    value: true,
                                    groupValue: _formHandler.houveTrocaDeCargo,
                                    label: 'Sim',
                                    onChanged: (value) {
                                      setState(() {
                                        _formHandler.houveTrocaDeCargo =
                                            value ?? false;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 24),
                                  CustomRadioButton<bool>(
                                    value: false,
                                    groupValue: _formHandler.houveTrocaDeCargo,
                                    label: 'Não',
                                    onChanged: (value) {
                                      setState(() {
                                        _formHandler.houveTrocaDeCargo =
                                            value ?? true;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
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
              onDeletePressed: isEditMode
                  ? (_formHandler.isSaving ? null : _deactivateUser)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
