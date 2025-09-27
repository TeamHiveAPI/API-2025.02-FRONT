import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';

import 'package:sistema_almox/screens/novo_item/form_handler.dart';
import 'package:sistema_almox/services/group_service.dart';
import 'package:sistema_almox/services/item_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/select.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/modal/content/novo_grupo_modal.dart';
import 'package:sistema_almox/widgets/modal/base_center_modal.dart';
import 'package:sistema_almox/widgets/radio_button.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class NewItemScreen extends StatefulWidget {
  final Map<String, dynamic>? itemToEdit;
  const NewItemScreen({super.key, this.itemToEdit});

  @override
  _NewItemScreenState createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final _formHandler = RegisterItemFormHandler();
  final _groupService = GroupService();
  final _itemService = StockItemService();

  bool get isEditMode => widget.itemToEdit != null;

  bool _isLoadingGroups = true;
  bool _isSaving = false;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _loadGroups();

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
    final item = widget.itemToEdit!;
    _formHandler.nameController.text = item['nome']?.toString() ?? '';
    _formHandler.recordNumberController.text =
        item['num_ficha']?.toString() ?? '';

    final unidade = item['unidade']?.toString() ?? '';
    if (unidade.startsWith('Lote')) {
      final match = RegExp(r'\((\d+)\s*un\.\)').firstMatch(unidade);
      _formHandler.unitOfMeasureController.text = match?.group(1) ?? '';
    } else {
      _formHandler.unitOfMeasureController.text = unidade;
    }

    _formHandler.initialQuantityController.text =
        item['qtd_atual']?.toString() ?? '0';
    _formHandler.minStockController.text =
        item['min_estoque']?.toString() ?? '0';
    _formHandler.selectedGroupId = item['id_grupo'];

    if (item['data_validade'] != null) {
      _formHandler.expirationDateController.text =
          item['data_validade'].toString();
      _formHandler.isControlled = item['controlado'] ?? false;
    }
  }

  Future<void> _updateItem() async {
    FocusScope.of(context).unfocus();
    setState(() => _formHandler.hasSubmitted = true);

    if (!(_formHandler.formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final itemPayload = _buildItemPayload();
      final itemId = widget.itemToEdit!['id_item'] as int;

      await _itemService.updateItem(itemId, itemPayload);
      showCustomSnackbar(context, 'Item atualizado com sucesso!');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showCustomSnackbar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deactivateItem() async {
    // 1. Validar o ID primeiro, antes de abrir qualquer diálogo
    final itemId = widget.itemToEdit?['id_item'];
    if (itemId == null) {
      if (mounted) {
        showCustomSnackbar(
          context,
          'ID do item inválido. Não é possível excluir.',
          isError: true,
        );
      }
      return;
    }

    final bool? confirmed = await showCustomDialog(
      context: context,
      title: 'Confirmar Exclusão',
      primaryButtonText: 'Excluir',
      primaryButtonDanger: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Tem certeza que deseja desativar este item?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: text60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Não será possível realizar pedidos com este item até ele ser reativado.',
            textAlign: TextAlign.center,
            style: TextStyle(color: text60, fontSize: 14),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _itemService.deactivateItem(itemId as int);

      if (mounted) {
        showCustomSnackbar(context, 'Item desativado com sucesso!');
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

  Future<void> _loadGroups() async {
    try {
      final int? viewingSectorId = UserService.instance.viewingSectorId;
      if (viewingSectorId == null) {
        setState(() {
          _loadingError = 'ID do setor de visualização não encontrado.';
          _isLoadingGroups = false;
        });
        return;
      }

      final groupsData = await _groupService.fetchGroupsBySector(
        viewingSectorId,
      );

      setState(() {
        _formHandler.groupOptions = groupsData
            .map((g) => ItemGroup(id: g['id_grupo'], nome: g['nome']))
            .toList();
        _isLoadingGroups = false;
      });
    } catch (e) {
      setState(() {
        _loadingError = 'Falha ao carregar grupos.';
        _isLoadingGroups = false;
      });
    }
  }

  Map<String, dynamic> _buildItemPayload() {
    final viewingSectorId = UserService.instance.viewingSectorId;
    final isPharmacyView = viewingSectorId == 2;

    final String unidadeDeMedida;

    if (isPharmacyView) {
      final unidadesPorLote = _formHandler.unitOfMeasureController.text;
      unidadeDeMedida = 'Lote ($unidadesPorLote un.)';
    } else {
      unidadeDeMedida = _formHandler.unitOfMeasureController.text;
    }

    final payload = {
      'nome': _formHandler.nameController.text,
      'num_ficha': int.tryParse(_formHandler.recordNumberController.text),
      'unidade': unidadeDeMedida,
      'qtd_atual':
          int.tryParse(_formHandler.initialQuantityController.text) ?? 0,
      'min_estoque': int.tryParse(_formHandler.minStockController.text) ?? 0,
      'id_grupo': _formHandler.selectedGroupId,
      'id_setor': viewingSectorId,
    };

    if (isPharmacyView) {
      payload['data_validade'] = _formHandler.expirationDateController.text;
      payload['controlado'] = _formHandler.isControlled;
    }

    return payload;
  }

  Future<void> _registerItem() async {
    FocusScope.of(context).unfocus();
    setState(() => _formHandler.hasSubmitted = true);

    if (!(_formHandler.formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final itemPayload = _buildItemPayload();

      await _itemService.createItem(itemPayload);
      showCustomSnackbar(context, 'Item cadastrado com sucesso!');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showCustomSnackbar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      _formHandler.expirationDateController.text = formattedDate;
    }
  }

  Future<void> _handleNewGroup() async {
    final bool? success = await showNewGroupModal(context);
    if (success == true) {
      await _loadGroups();

      if (mounted) {
        showCustomSnackbar(context, 'Lista de grupos atualizada.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewingSectorId = UserService.instance.viewingSectorId;
    final isPharmacyView = viewingSectorId == 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            InternalPageHeader(
              title: isEditMode ? 'Editar Item' : 'Cadastrar Novo Item',
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
                        hintText: 'Digite o nome do item',
                        controller: _formHandler.nameController,
                        validator: (value) =>
                            _formHandler.validateRequired(value, 'Nome'),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              upperLabel: 'Nº DE FICHA',
                              hintText: 'Número',
                              keyboardType: TextInputType.number,
                              controller: _formHandler.recordNumberController,
                              validator: (value) => _formHandler
                                  .validateRequired(value, 'Nº de Ficha'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextFormField(
                              upperLabel: isPharmacyView
                                  ? 'UNID. POR LOTE'
                                  : 'UNIDADE DE MEDIDA',
                              hintText: isPharmacyView ? 'Número' : 'Digite aqui',
                              controller: _formHandler.unitOfMeasureController,
                              keyboardType: isPharmacyView
                                  ? TextInputType.number
                                  : TextInputType.text,
                              inputFormatters: isPharmacyView
                                  ? [FilteringTextInputFormatter.digitsOnly]
                                  : [],
                              validator: (value) => _formHandler
                                  .validateRequired(value, 'Unidade de Medida'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              upperLabel: 'QTD. INICIAL',
                              hintText: 'Número',
                              controller:
                                  _formHandler.initialQuantityController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) => _formHandler
                                  .validateRequired(value, 'Qtd. Inicial'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextFormField(
                              upperLabel: 'ESTOQUE MÍNIMO',
                              hintText: 'Número',
                              controller: _formHandler.minStockController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) => _formHandler
                                  .validateRequired(value, 'Estoque Mínimo'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (_isLoadingGroups)
                        const Center(child: CircularProgressIndicator())
                      else if (_loadingError != null)
                        Text(
                          _loadingError!,
                          style: const TextStyle(color: deleteRed),
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: CustomDropdownInput<int>(
                                upperLabel: 'GRUPO',
                                hintText: 'Opcional',
                                value: _formHandler.selectedGroupId,
                                items: _formHandler.groupOptions.map((group) {
                                  return DropdownOption(
                                    value: group.id,
                                    label: group.nome,
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    _formHandler.selectedGroupId = newValue;
                                  });
                                },
                                validator: _formHandler.validateGroup,
                              ),
                            ),
                            const SizedBox(width: 16),
                            CustomButton(
                              customIcon:
                                  "assets/icons/addicon.svg",
                              squareMode: true,
                              onPressed: _handleNewGroup,
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),

                      if (isPharmacyView) ...[
                        CustomTextFormField(
                          upperLabel: 'DATA DE VALIDADE',
                          hintText: 'Selecione a data',
                          controller: _formHandler.expirationDateController,
                          readOnly: true,
                          onTap: _selectDate,
                          validator: (value) => _formHandler
                              .validateExpirationDate(value, viewingSectorId),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              'assets/icons/calendar.svg',
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'É CONTROLADO?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: text80,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Row(
                              children: [
                                CustomRadioButton<bool>(
                                  value: true,
                                  groupValue: _formHandler.isControlled,
                                  label: 'Sim',
                                  onChanged: (value) {
                                    setState(() {
                                      _formHandler.isControlled =
                                          value ?? false;
                                    });
                                  },
                                ),
                                const SizedBox(width: 24),
                                CustomRadioButton<bool>(
                                  value: false,
                                  groupValue: _formHandler.isControlled,
                                  label: 'Não',
                                  onChanged: (value) {
                                    setState(() {
                                      _formHandler.isControlled =
                                          value ?? false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            InternalPageBottom(
              buttonText: isEditMode ? 'Salvar Alterações' : 'Cadastrar Item',
              onButtonPressed: _isSaving
                  ? null
                  : (isEditMode ? _updateItem : _registerItem),
              isEditMode: isEditMode,
              onDeletePressed: _isSaving ? null : _deactivateItem,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
