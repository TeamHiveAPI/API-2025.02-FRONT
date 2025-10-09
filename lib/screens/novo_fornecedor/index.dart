import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/screens/novo_fornecedor/form_handler.dart';
import 'package:sistema_almox/services/supplier_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewSupplierScreen extends StatefulWidget {
  final Map<String, dynamic>? supplierToEdit;
  const NewSupplierScreen({super.key, this.supplierToEdit});

  @override
  _NewSupplierScreenState createState() => _NewSupplierScreenState();
}

class _NewSupplierScreenState extends State<NewSupplierScreen> {
  final _formHandler = RegisterSupplierFormHandler();

  bool get isEditMode => widget.supplierToEdit != null;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _populateFormForEdit();
    }
  }

  @override
  void dispose() {
    _formHandler.dispose();
    super.dispose();
  }

  void _populateFormForEdit() {
    final supplier = widget.supplierToEdit!;
    _formHandler.nameController.text = supplier['frn_nome']?.toString() ?? '';
    _formHandler.cnpjController.text = supplier['frn_cnpj']?.toString() ?? '';
    _formHandler.contactController.text = supplier['frn_contato']?.toString() ?? '';
  }

  Map<String, dynamic> _buildSupplierPayload() {
    return {
      'frn_nome': _formHandler.nameController.text.trim(),
      'frn_cnpj': _formHandler.cnpjController.text.replaceAll(RegExp(r'[^\d]'), ''), 
      'frn_contato': _formHandler.contactController.text.replaceAll(RegExp(r'[^\d]'), ''), 
    };
  }

  Future<void> _registerSupplier() async {
    FocusScope.of(context).unfocus();
    setState(() => _formHandler.hasSubmitted = true);

    if (!(_formHandler.formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final supplierPayload = _buildSupplierPayload();
      await SupplierService.instance.createSupplier(supplierPayload);
      showCustomSnackbar(context, 'Fornecedor cadastrado com sucesso!');
      if (mounted) Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      if (e.message.contains('supplier_cnpj_key')) {
        showCustomSnackbar(
          context,
          'O CNPJ informado já está em uso.',
          isError: true,
        );
      } else {
        showCustomSnackbar(
          context,
          'Erro no banco de dados: ${e.message}',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) showCustomSnackbar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _updateSupplier() async {
    FocusScope.of(context).unfocus();
    setState(() => _formHandler.hasSubmitted = true);

    if (!(_formHandler.formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final supplierPayload = _buildSupplierPayload();
      final supplier = widget.supplierToEdit;
      if (supplier == null || supplier['id'] == null) {
        throw Exception('ID do fornecedor para edição não foi encontrado.');
      }
      final supplierId = supplier['id'] as int;

      await SupplierService.instance.updateSupplier(supplierId, supplierPayload);
      showCustomSnackbar(context, 'Fornecedor atualizado com sucesso!');
      if (mounted) Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      if (e.message.contains('supplier_cnpj_key')) {
        showCustomSnackbar(
          context,
          'O CNPJ informado já está em uso.',
          isError: true,
        );
      } else {
        showCustomSnackbar(
          context,
          'Erro no banco de dados: ${e.message}',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(
          context,
          'Ocorreu um erro ao atualizar o fornecedor. Tente novamente.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deactivateSupplier() async {
    final supplierId = widget.supplierToEdit?['id'];
    if (supplierId == null) {
      if (mounted) {
        showCustomSnackbar(
          context,
          'ID do fornecedor inválido. Não é possível excluir.',
          isError: true,
        );
      }
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja desativar este fornecedor?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await SupplierService.instance.deactivateSupplier(supplierId as int);
      if (mounted) {
        showCustomSnackbar(context, 'Fornecedor desativado com sucesso!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, e.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            InternalPageHeader(
              title: isEditMode ? 'Editar Fornecedor' : 'Cadastrar Novo Fornecedor',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formHandler.formKey,
                  autovalidateMode: _formHandler.hasSubmitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFormField(
                        upperLabel: 'NOME',
                        hintText: 'Digite o nome do fornecedor',
                        controller: _formHandler.nameController,
                        validator: (value) =>
                            _formHandler.validateRequired(value, 'Nome'),
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        upperLabel: 'CNPJ',
                        hintText: 'Digite o CNPJ',
                        controller: _formHandler.cnpjController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(18), // 14 dígitos + 4 caracteres de formatação
                        ],
                        validator: _formHandler.validateCnpj,
                        onChanged: (value) {
                          final formatted = _formHandler.formatCNPJ(value);
                          if (formatted != value) {
                            _formHandler.cnpjController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                          
                          // Validação em tempo real
                          final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (digits.length > 14) {
                            // Remove dígitos extras
                            final limitedDigits = digits.substring(0, 14);
                            final limitedFormatted = _formHandler.formatCNPJ(limitedDigits);
                            _formHandler.cnpjController.value = TextEditingValue(
                              text: limitedFormatted,
                              selection: TextSelection.collapsed(offset: limitedFormatted.length),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        upperLabel: 'CONTATO',
                        hintText: 'Digite o telefone (XX) XXXXX-XXXX',
                        controller: _formHandler.contactController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15), // 11 dígitos + 4 caracteres de formatação
                        ],
                        validator: _formHandler.validatePhone,
                        onChanged: (value) {
                          final formatted = _formHandler.formatPhone(value);
                          if (formatted != value) {
                            _formHandler.contactController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                          
                          // Validação em tempo real
                          final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (digits.length > 11) {
                            // Remove dígitos extras
                            final limitedDigits = digits.substring(0, 11);
                            final limitedFormatted = _formHandler.formatPhone(limitedDigits);
                            _formHandler.contactController.value = TextEditingValue(
                              text: limitedFormatted,
                              selection: TextSelection.collapsed(offset: limitedFormatted.length),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            InternalPageBottom(
              buttonText: isEditMode ? 'Salvar Alterações' : 'Cadastrar Fornecedor',
              onButtonPressed: _isSaving
                  ? null
                  : (isEditMode ? _updateSupplier : _registerSupplier),
              showSecondaryButton: false,
              isEditMode: isEditMode,
              onDeletePressed: _isSaving ? null : _deactivateSupplier,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}