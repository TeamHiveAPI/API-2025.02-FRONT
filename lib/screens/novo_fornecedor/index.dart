import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/screens/novo_fornecedor/form_handler.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'package:sistema_almox/widgets/inputs/select.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';

class NewSupplierScreen extends StatefulWidget {
  final Map<String, dynamic>? supplierToEdit;
  const NewSupplierScreen({super.key, this.supplierToEdit});

  @override
  _NewSupplierScreenState createState() => _NewSupplierScreenState();
}

class _NewSupplierScreenState extends State<NewSupplierScreen> {
  late final SupplierFormHandler _handler;

  @override
  void initState() {
    super.initState();
    _handler = SupplierFormHandler(widget.supplierToEdit);

    _handler.addListener(_onHandlerUpdate);

    _handler.initialize();
  }

  void _onHandlerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _handler.removeListener(_onHandlerUpdate);
    _handler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            InternalPageHeader(
              title: _handler.isEditMode
                  ? 'Editar Fornecedor'
                  : 'Cadastrar Novo Fornecedor',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _handler.formKey,
                  autovalidateMode: _handler.hasSubmitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFormField(
                        upperLabel: 'RAZÃO SOCIAL',
                        hintText: 'Digite aqui',
                        controller: _handler.nameController,
                        validator: (value) =>
                            _handler.validateRequired(value, 'Nome'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              upperLabel: 'CNPJ',
                              hintText: '__.___.___ /____.__',
                              controller: _handler.cnpjController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: _handler.validateCnpj,
                              onChanged: _handler.formatAndSetCnpj,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextFormField(
                              upperLabel: 'TELEFONE',
                              hintText: '(__) ____-____',
                              controller: _handler.telefoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: _handler.validatePhone,
                              onChanged: _handler.formatAndSetPhone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        upperLabel: 'E-MAIL',
                        hintText: 'Digite aqui',
                        controller: _handler.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _handler.validateEmail,
                      ),
                      const SizedBox(height: 24),
                      CustomDropdownInput<int>(
                        upperLabel: 'SETOR FORNECIDO',
                        hintText: 'Selecione um setor',
                        value: _handler.selectedSectorId,
                        items: _handler.availableSectors.map((sector) {
                          return DropdownOption(
                            value: sector['id'] as int,
                            label: sector['set_nome'] as String,
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          _handler.setSelectedSector(newValue);
                        },
                        validator: (value) => _handler.validateRequired(
                          value?.toString(),
                          'Setor',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              upperLabel: 'LISTA de ITENS FORNECIDOS',
                              hintText: 'Digite um item',
                              controller: _handler.newItemController,
                              onSubmitted: (_) => _handler.addItem(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          CustomButton(
                            onPressed: _handler.addItem,
                            customIcon: "assets/icons/addicon.svg",
                            squareMode: true,
                          ),
                        ],
                      ),
                      SizedBox(height: _handler.items.isEmpty ? 16 : 8),
                      _handler.items.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 24.0,
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                color: coolGray,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Text(
                                  'A lista de itens está vazia.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: text80),
                                ),
                              ),
                            )
                          : Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: _handler.items.map((item) {
                                return Chip(
                                  label: Text(item),
                                  labelStyle: TextStyle(color: brandBlue),
                                  onDeleted: () => _handler.removeItem(item),
                                  backgroundColor: brandBlueLight,
                                  deleteIconColor: brandBlue,
                                  side: BorderSide.none,
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            InternalPageBottom(
              buttonText: _handler.isEditMode
                  ? 'Salvar Alterações'
                  : 'Cadastrar Fornecedor',
              onButtonPressed: _handler.isSaving
                  ? null
                  : () => _handler.save(context),
              showSecondaryButton: false,
              isEditMode: _handler.isEditMode,
              onDeletePressed: _handler.isSaving
                  ? null
                  : () => _handler.deactivateSupplier(context),
              isLoading: _handler.isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
