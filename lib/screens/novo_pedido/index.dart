import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/constants/database.dart';
import 'package:sistema_almox/screens/novo_pedido/form_handler.dart';
import 'package:sistema_almox/widgets/inputs/search.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/cards/order_preview.dart';
import 'package:sistema_almox/widgets/main_scaffold/index.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:sistema_almox/services/pedido_service.dart';

class NewOrderScreen extends StatefulWidget {
  final UserRole userRole;
  const NewOrderScreen({super.key, required this.userRole});

  @override
  NewOrderScreenState createState() => NewOrderScreenState();
}

class NewOrderScreenState extends State<NewOrderScreen> {
  late final NewOrderFormHandler _formHandler;

  final Key _searchKey = UniqueKey();
  List<Map<String, dynamic>> inventory = [];
  List<String> itemNamesForSuggestions = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _formHandler = NewOrderFormHandler();
    _formHandler.searchController.addListener(_onSearchTextChanged);
    _loadAvailableItems();
  }

  void _onSearchTextChanged() {
    if (_formHandler.searchController.text.isEmpty &&
        _formHandler.selectedItem != null) {
      setState(() {
        _formHandler.selectedItem = null;
      });
    }
  }

  @override
  void dispose() {
    _formHandler.searchController.removeListener(_onSearchTextChanged);
    _formHandler.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableItems() async {
    setState(() => _isLoading = true);
    
    try {
      final items = await PedidoService.instance.getAvailableItems();
      
      setState(() {
        inventory = items.map((item) => {
          'id': item['id_item'],
          'itemName': item[ItemFields.nome],
          'unidMedida': item[ItemFields.unidade],
          'quantity': item['qtd_atual'] ?? 0,
          'qtdReservada': item['qtd_reservada'] ?? 0,
        }).toList();
        
        itemNamesForSuggestions = inventory
            .map((item) => item['itemName'].toString())
            .toList();
      });
    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, 'Erro ao carregar itens: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitOrder() async {
    setState(() => _formHandler.hasSubmitted = true);

    if (!(_formHandler.formKey.currentState?.validate() ?? false)) {
      showCustomSnackbar(context, 'O formulário contém erros.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final selectedItem = _formHandler.selectedItem!;
      final requestedQuantity = int.parse(_formHandler.quantityController.text);
      final selectedDate = _formHandler.selectedDate;

      String? dataRetirada;
      if (selectedDate != null) {
        dataRetirada = DateFormat('yyyy-MM-dd').format(selectedDate);
      }

      await PedidoService.instance.createPedido(
        itemId: selectedItem['id'],
        quantidade: requestedQuantity,
        dataRetirada: dataRetirada,
      );

      if (mounted) {
        showCustomSnackbar(context, 'Pedido registrado com sucesso!');
        final mainScaffoldState = context.findAncestorStateOfType<MainScaffoldState>();
        if (mainScaffoldState != null) {
          final ordersPageIndex = mainScaffoldState.findPageIndexByName('Pedidos');
          mainScaffoldState.onItemTapped(ordersPageIndex);
        }
        Navigator.of(context).pop();
      }

    } catch (e) {
      if (mounted) {
        showCustomSnackbar(context, e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
   if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const InternalPageHeader(title: 'Registrar Novo Pedido'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formHandler.formKey,
                  autovalidateMode: _formHandler.hasSubmitted
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenericSearchInput(
                        key: _searchKey,
                        upperLabel: 'ITEM REQUISITADO',
                        hintText: 'Pesquisar',
                        controller: _formHandler.searchController,
                        suggestions: itemNamesForSuggestions,
                        onItemSelected: (String selectedItemName) {
                          _formHandler.searchController.text = selectedItemName;
                          setState(() {
                            _formHandler.selectedItem = inventory.firstWhere(
                              (item) => item['itemName'] == selectedItemName,
                            );
                          });
                          _formHandler.formKey.currentState?.validate();
                        },
                        validator: (value) => _formHandler.validateItem(
                          value,
                          itemNamesForSuggestions,
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        upperLabel: 'QUANTIDADE',
                        hintText: 'Digite a quantidade',
                        controller: _formHandler.quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: _formHandler.validateQuantity,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 24),
                      OrderPreviewCard(
                        isSelectionMode:
                            _formHandler.selectedItem == null ||
                            _formHandler.quantityController.text.isEmpty,
                        title: _formHandler.selectedItem?['itemName'],
                        unit: _formHandler.selectedItem?['unidMedida'],
                        requested: _formHandler.quantityController.text,
                        available: _formHandler.selectedItem != null
                            ? '${(_formHandler.selectedItem!['quantity'] - (_formHandler.selectedItem!['qtdReservada'] as int? ?? 0))} ${_formHandler.selectedItem!['unidMedida']}'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        upperLabel: 'DATA DE RETIRADA',
                        hintText: 'Selecionar (Opcional)',
                        controller: _formHandler.dateController,
                        readOnly: true,
                        onTap: () async {
                          await _formHandler.selectDate(context);
                          setState(() {});
                        },
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset('assets/icons/calendar.svg'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            InternalPageBottom(
              buttonText: _isSubmitting ? 'Registrando...' : 'Registrar Pedido',
              onButtonPressed: _isSubmitting ? null : _submitOrder,
            ),
          ],
        ),
      ),
    );
  }
}
