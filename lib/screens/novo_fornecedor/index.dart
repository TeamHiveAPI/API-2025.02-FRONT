import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/screens/novo_fornecedor/form_handler.dart';
import 'package:sistema_almox/services/supplier_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/services/sector_service.dart';
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
  final _newItemController = TextEditingController();
  final _newSetorController = TextEditingController();

  List<String> _items = [];
  List<int> _setores = [];

  List<Map<String, dynamic>> _availableSectors = [];
  int? _selectedSectorId;

  bool get isEditMode => widget.supplierToEdit != null;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSectors();
  }

  Future<void> _loadSectors() async {
    try {
      final sectors = await SectorService().fetchAllSectors();
      setState(() {
        _availableSectors = sectors;
      });
      if (isEditMode) {
        _populateFormForEdit(); 
      }
    } catch (e) {
      print('Erro ao carregar setores: $e');
    }
  }



  @override
  void dispose() {
    _formHandler.dispose();
    _newItemController.dispose();
    _newSetorController.dispose();
    super.dispose();
  }

  void _populateFormForEdit() {
    final supplier = widget.supplierToEdit!;
    _formHandler.nameController.text = supplier['frn_nome']?.toString() ?? '';
    _formHandler.cnpjController.text = supplier['frn_cnpj']?.toString() ?? '';
    _formHandler.telefoneController.text = supplier['frn_telefone']?.toString() ?? '';
    _formHandler.emailController.text = supplier['frn_email']?.toString() ?? '';
    _items = List<String>.from(supplier['frn_item'] ?? []);

    
    final setorNome = supplier['frn_setor_id']?.toString();
    final setor = _availableSectors.cast<Map<String, dynamic>?>().firstWhere(
      (s) => s?['set_nome'] == setorNome,
      orElse: () => null,
    );
    if (setor != null) _setores = [setor['id']];
  }

  Map<String, dynamic> _buildSupplierPayload() {
    if (_setores.isEmpty) {
      throw Exception('Você precisa selecionar pelo menos um setor.');
    }

    return {
      'frn_nome': _formHandler.nameController.text.trim(),
      'frn_cnpj': _formHandler.cnpjController.text.replaceAll(RegExp(r'[^\d]'), ''),
      'frn_telefone': _formHandler.telefoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
      'frn_email': _formHandler.emailController.text.trim(),
      'frn_item': _items,
      'frn_setor_id': _setores.first,
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

  void _addItem() {
    final newItem = _newItemController.text.trim();
    if (newItem.isNotEmpty) {
      setState(() {
        _items.add(newItem);
        _newItemController.clear();
      });
    }
  }

  void _removeItem(String item) {
    setState(() {
      _items.remove(item);
    });
  }

    void _addSetor() {
      if (_selectedSectorId != null && !_setores.contains(_selectedSectorId)) {
        setState(() {
          _setores.add(_selectedSectorId!);
          print('Setores agora: $_setores'); 
        });
      }
    }


    void _removeSetor(int setorId) {
      setState(() {
        _setores.remove(setorId);
      });
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
                          LengthLimitingTextInputFormatter(18), 
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
                          
                          
                          final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (digits.length > 14) {
                            
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
                        upperLabel: 'TELEFONE',
                        hintText: 'Digite o telefone (XX) XXXXX-XXXX',
                        controller: _formHandler.telefoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15), 
                        ],
                        validator: _formHandler.validatePhone,
                        onChanged: (value) {
                          final formatted = _formHandler.formatPhone(value);
                          if (formatted != value) {
                            _formHandler.telefoneController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                          
                          
                          final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (digits.length > 11) {
                            
                            final limitedDigits = digits.substring(0, 11);
                            final limitedFormatted = _formHandler.formatPhone(limitedDigits);
                            _formHandler.telefoneController.value = TextEditingValue(
                              text: limitedFormatted,
                              selection: TextSelection.collapsed(offset: limitedFormatted.length),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        upperLabel: 'E-MAIL',
                        hintText: 'Digite o e-mail',
                        controller: _formHandler.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _formHandler.validateEmail,
                      ),
                      const SizedBox(height: 24),
                      
                      const Text('ITENS FORNECIDOS', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newItemController,
                              decoration: const InputDecoration(
                                hintText: 'Digite um item e adicione',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addItem,
                            child: const Text('Adicionar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _items.map((item) {
                          return Chip(
                            label: Text(item),
                            onDeleted: () => _removeItem(item),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'SETORES FORNECIDOS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedSectorId,
                              items: _availableSectors.map((sector) {
                                return DropdownMenuItem<int>(
                                  value: sector['id'],
                                  child: Text(sector['set_nome']),
                                );
                              }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSectorId = value;
                                  });
                                  print('Selecionado: $_selectedSectorId'); 
                                },
                              decoration: const InputDecoration(
                                hintText: 'Selecione um setor',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addSetor,
                            child: const Text('Adicionar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _setores.map((setorId) {
                          final setorNome = _availableSectors.firstWhere((s) => s['id'] == setorId)['set_nome'];
                          return Chip(
                            label: Text(setorNome),
                            onDeleted: () => _removeSetor(setorId),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      InternalPageBottom(
                        buttonText: isEditMode ? 'Salvar Alterações' : 'Cadastrar Fornecedor',
                        onButtonPressed: _isSaving ? null : (isEditMode ? _updateSupplier : _registerSupplier),
                        showSecondaryButton: false,
                        isEditMode: isEditMode,
                        onDeletePressed: _isSaving ? null : _deactivateSupplier,
                        isLoading: _isSaving,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
