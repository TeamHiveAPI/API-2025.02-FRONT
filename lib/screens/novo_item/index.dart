import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/theme/colors.dart';

import 'package:sistema_almox/screens/novo_item/form_handler.dart';
import 'package:sistema_almox/services/group_service.dart';
import 'package:sistema_almox/services/item_stock_service.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/inputs/select.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/radio_button.dart';
import 'package:sistema_almox/widgets/snackbar.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  _NewItemScreenState createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final _formHandler = RegisterItemFormHandler();
  final _groupService = GroupService();
  final _itemService = StockItemService();

  bool _isLoadingGroups = true;
  bool _isSaving = false;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groupsData = await _groupService.fetchAllGroups();
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

  @override
  void dispose() {
    _formHandler.dispose();
    super.dispose();
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
      final currentUserRole = Provider.of<UserService>(
        context,
        listen: false,
      ).currentUser!.role;
      final isPharmacyUser =
          currentUserRole == UserRole.tenenteFarmacia ||
          currentUserRole == UserRole.soldadoFarmacia;

      final itemPayload = {
        'nome': _formHandler.nameController.text,
        'num_ficha': int.tryParse(_formHandler.recordNumberController.text),
        'unidade': _formHandler.unitOfMeasureController.text,
        'qtd_atual':
            int.tryParse(_formHandler.initialQuantityController.text) ?? 0,
        'min_estoque': int.tryParse(_formHandler.minStockController.text) ?? 0,
        'id_grupo': _formHandler.selectedGroupId,
      };

      if (isPharmacyUser) {
        itemPayload['data_validade'] =
            _formHandler.expirationDateController.text;
        itemPayload['controlado'] = _formHandler.isControlled;
      }

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

  @override
  Widget build(BuildContext context) {
    final currentUserRole = Provider.of<UserService>(
      context,
      listen: false,
    ).currentUser!.role;
    final isPharmacyUser =
        currentUserRole == UserRole.tenenteFarmacia ||
        currentUserRole == UserRole.soldadoFarmacia;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const InternalPageHeader(title: 'Cadastrar Novo Item'),
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
                              upperLabel: 'UNIDADE DE MEDIDA',
                              hintText: 'Digite aqui',
                              controller: _formHandler.unitOfMeasureController,
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
                        CustomDropdownInput<int>(
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
                      const SizedBox(height: 24),

                      if (isPharmacyUser) ...[
                        CustomTextFormField(
                          upperLabel: 'DATA DE VALIDADE',
                          hintText: 'Selecione a data',
                          controller: _formHandler.expirationDateController,
                          readOnly: true,
                          onTap: _selectDate,
                          validator: (value) => _formHandler
                              .validateExpirationDate(value, currentUserRole),

                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              'assets/icons/calendar.svg',
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start,
                          children: [
                            const Text(
                              'É CONTROLADO?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: text80,
                              ),
                            ),
                            const SizedBox(
                              height: 12.0,
                            ),
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
              buttonText: 'Cadastrar Item',
              onButtonPressed: _isSaving ? null : _registerItem,
            ),
          ],
        ),
      ),
    );
  }
}
