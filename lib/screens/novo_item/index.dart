import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_almox/core/theme/colors.dart';

import 'package:sistema_almox/screens/novo_item/form_handler.dart';
import 'package:sistema_almox/screens/novo_item/lote_section.dart';
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
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';
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

  bool get isEditMode => widget.itemToEdit != null;
  final viewingSectorId = UserService.instance.viewingSectorId;

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

  void _updateTotalQuantity() {
    if (!_formHandler.isPerishable) {
      return;
    }

    int total = 0;
    for (final lot in _formHandler.lotControllers) {
      total += int.tryParse(lot.quantityController.text) ?? 0;
    }
    _formHandler.initialQuantityController.text = total.toString();
  }

  Future<int> _getOrCreateSemGrupoId() async {
    if (viewingSectorId == null) {
      throw Exception('ID do setor não encontrado.');
    }

    final existingGroup = await _groupService.fetchGroupByName(
      'Sem Grupo',
      viewingSectorId!,
    );

    if (existingGroup != null && existingGroup['id_grupo'] != null) {
      return existingGroup['id_grupo'] as int;
    } else {
      final newGroupId = await _groupService.createGroup(
        name: 'Sem Grupo',
        sectorId: viewingSectorId!,
      );
      return newGroupId;
    }
  }

  void _populateFormForEdit() {
    final item = widget.itemToEdit!;
    _formHandler.nameController.text = item['nome']?.toString() ?? '';
    _formHandler.recordNumberController.text =
        item['num_ficha']?.toString() ?? '';
    _formHandler.unitOfMeasureController.text =
        item['unidade']?.toString() ?? '';
    _formHandler.minStockController.text =
        item['min_estoque']?.toString() ?? '0';
    _formHandler.selectedGroupId = item['id_grupo'];
    _formHandler.isPerishable = item['perecivel'] ?? false;

    final lotesData = item['lotes'];
    if (_formHandler.isPerishable &&
        lotesData is List &&
        lotesData.isNotEmpty) {
      _formHandler.lotControllers.clear();

      for (final lote in lotesData) {
        final lotController = LotFieldControllers(
          id: lote['id_lote'],
          codigoLote: lote['codigo_lote'],
          initialQuantity: lote['qtd_atual']?.toString() ?? '0',
          initialDate: lote['data_validade']?.toString() ?? '',
        );
        _formHandler.lotControllers.add(lotController);
      }
      _updateTotalQuantity();
    } else if (!(_formHandler.isPerishable) &&
        lotesData is List &&
        lotesData.isNotEmpty) {
      _formHandler.initialQuantityController.text =
          lotesData[0]?['qtd_atual']?.toString() ?? '0';
    }
  }

  Map<String, dynamic> _buildItemPayload() {
    final payload = {
      'nome': _formHandler.nameController.text.trim(),
      'num_ficha': _formHandler.recordNumberController.text.trim(),
      'unidade': _formHandler.unitOfMeasureController.text.trim(),
      'min_estoque': int.tryParse(_formHandler.minStockController.text) ?? 0,
      'id_grupo': _formHandler.selectedGroupId,
      'perecivel': _formHandler.isPerishable,
      'ativo': true,
    };

    if (viewingSectorId == 2) {
      payload['controlado'] = _formHandler.isControlled;
    }

    if (_formHandler.isPerishable) {
      payload['lotes'] = _formHandler.lotControllers.map((loteCtrl) {
        return {
          'id_lote': loteCtrl.id,
          'qtd_atual': int.tryParse(loteCtrl.quantityController.text) ?? 0,
          'data_validade': loteCtrl.dateController.text,
          'data_entrada': DateTime.now().toIso8601String().substring(0, 10),
        };
      }).toList();
    } else {
      payload['lotes'] = [
        {
          'qtd_atual':
              int.tryParse(_formHandler.initialQuantityController.text) ?? 0,
          'data_validade': null,
          'data_entrada': DateTime.now().toIso8601String().substring(0, 10),
        },
      ];
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
      // NOVA LÓGICA: Verifica se um grupo foi selecionado
      if (_formHandler.selectedGroupId == null) {
        // Se nenhum grupo foi selecionado, busca ou cria o grupo "Sem Grupo"
        final defaultGroupId = await _getOrCreateSemGrupoId();
        // Atribui o ID do grupo padrão ao handler do formulário
        _formHandler.selectedGroupId = defaultGroupId;
      }

      // A partir daqui, o código continua como antes, mas agora temos certeza
      // que _formHandler.selectedGroupId tem um valor.
      final itemPayload = _buildItemPayload();

      await ItemService.instance.createItemWithLots(itemPayload);
      showCustomSnackbar(context, 'Item cadastrado com sucesso!');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showCustomSnackbar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
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

      final item = widget.itemToEdit;
      if (item == null || item['id_item'] == null) {
        throw Exception('ID do item para edição não foi encontrado.');
      }
      final itemId = item['id_item'] as int;

      await ItemService.instance.updateItem(itemId, itemPayload);

      showCustomSnackbar(context, 'Item atualizado com sucesso!');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      print('Erro detalhado ao atualizar item: $e');

      if (mounted) {
        showCustomSnackbar(
          context,
          'Ocorreu um erro ao atualizar o item. Tente novamente.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deactivateItem() async {
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
            style: TextStyle(color: text60, fontSize: 14),
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
      await ItemService.instance.deactivateItem(itemId as int);

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
      if (viewingSectorId == null) {
        setState(() {
          _loadingError = 'ID do setor de visualização não encontrado.';
          _isLoadingGroups = false;
        });
        return;
      }

      final groupsData = await _groupService.fetchGroupsBySector(
        viewingSectorId!,
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
                              hintText: 'Digite aqui',
                              controller: _formHandler.recordNumberController,
                              validator: (value) => _formHandler
                                  .validateRequired(value, 'Nº de Ficha'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextFormField(
                              upperLabel: 'UNIDADE DE MEDIDA',
                              hintText: 'Digite aqui',
                              controller: _formHandler.unitOfMeasureController,
                              validator: (value) => _formHandler
                                  .validateRequired(value, 'Unidade'),
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
                              upperLabel: _formHandler.isPerishable
                                  ? 'QTD. INICIAL TOTAL'
                                  : 'QTD. INICIAL',
                              hintText: 'Número',
                              controller:
                                  _formHandler.initialQuantityController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              readOnly: _formHandler.isPerishable,
                              validator: (value) {
                                if (!_formHandler.isPerishable) {
                                  return _formHandler.validateRequired(
                                    value,
                                    'Qtd. Inicial',
                                  );
                                }
                                return null;
                              },
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
                      if (viewingSectorId == 2) ...[
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
                                  _formHandler.isControlled = value ?? false;
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
                                  _formHandler.isControlled = value ?? false;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: viewingSectorId == 2 ? 24.0 : 0.0),
                      if (_isLoadingGroups)
                        const ShimmerPlaceholder(height: 64)
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
                              ),
                            ),
                            const SizedBox(width: 16),
                            CustomButton(
                              customIcon: "assets/icons/addicon.svg",
                              squareMode: true,
                              onPressed: _handleNewGroup,
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      LotManagementSection(
                        initialIsPerishable: isEditMode
                            ? _formHandler.isPerishable
                            : false,
                        initialLotes: isEditMode
                            ? _formHandler.lotControllers
                            : null,
                        onChanged: (isPerishable, lotControllers) {
                          setState(() {
                            _formHandler.isPerishable = isPerishable;
                            _formHandler.lotControllers = lotControllers;

                            for (var lot in _formHandler.lotControllers) {
                              lot.quantityController.removeListener(
                                _updateTotalQuantity,
                              );
                              lot.quantityController.addListener(
                                _updateTotalQuantity,
                              );
                            }

                            _updateTotalQuantity();

                            if (!_formHandler.isPerishable) {
                              _formHandler.initialQuantityController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 24),
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
