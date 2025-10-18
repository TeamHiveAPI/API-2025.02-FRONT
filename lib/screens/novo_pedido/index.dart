import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/widgets/inputs/text_field.dart';
import 'package:sistema_almox/widgets/internal_page_header.dart';
import 'package:sistema_almox/widgets/internal_page_bottom.dart';
import 'package:sistema_almox/widgets/main_scaffold/index.dart';
import 'package:sistema_almox/widgets/snackbar.dart';
import 'package:sistema_almox/services/pedido_service.dart';
import 'package:sistema_almox/widgets/modal/content/item_picker_modal.dart';
import 'package:sistema_almox/screens/novo_pedido/form_handler.dart';

class NewOrderScreen extends StatefulWidget {
  final UserRole userRole;
  const NewOrderScreen({super.key, required this.userRole});

  @override
  NewOrderScreenState createState() => NewOrderScreenState();
}

class NewOrderScreenState extends State<NewOrderScreen> {
  late final NewOrderFormHandler _formHandler;

  // Removidos campos do fluxo antigo de item único
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<SelectedItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _formHandler = NewOrderFormHandler();
  }

  @override
  void dispose() {
    _formHandler.dispose();
    super.dispose();
  }

  Future<void> _openItemPicker() async {
    final result = await ItemPickerModal.show(context, initialSelection: _selectedItems);
    if (result != null && mounted) {
      setState(() {
        _selectedItems = result.items;
        // Clear the single-item controls when using multi
        _formHandler.searchController.clear();
        _formHandler.selectedItem = null;
        _formHandler.quantityController.clear();
      });
    }
  }

  Future<void> _submitOrder() async {
    setState(() => _formHandler.hasSubmitted = true);

    if (_selectedItems.isEmpty) {
      showCustomSnackbar(context, 'Selecione ao menos um item no botão "Selecionar Itens".', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? dataRetirada;
      if (_formHandler.selectedDate != null) {
        dataRetirada = DateFormat('yyyy-MM-dd').format(_formHandler.selectedDate!);
      }

      final itens = _selectedItems.map((s) {
        List<Map<String, dynamic>> lotes;
        int total;
        if (s.lotes.length > 1) {
          lotes = s.lotes
              .where((l) => l.quantidade > 0)
              .map((l) => {
                    'lote_id': l.loteId,
                    'quantidade': l.quantidade,
                  })
              .toList();
          total = s.lotes.fold<int>(0, (acc, l) => acc + l.quantidade);
        } else if (s.lotes.length == 1) {
          final unico = s.lotes.first;
          final q = s.quantidadeTotal;
          lotes = q > 0
              ? [
                  {
                    'lote_id': unico.loteId,
                    'quantidade': q,
                  }
                ]
              : [];
          total = q;
        } else {
          total = s.quantidadeTotal;
          lotes = const [];
        }
        return {
          'item_id': s.itemId,
          'quantidade': total,
          'lotes': lotes,
        };
      }).where((e) => (e['quantidade'] as int) > 0).toList();

      if (itens.isEmpty) {
        showCustomSnackbar(context, 'Selecione quantidades válidas.', isError: true);
        setState(() => _isSubmitting = false);
        return;
      }

      await PedidoService.instance.createPedidoMulti(itens: itens, dataRetirada: dataRetirada);

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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _openItemPicker,
                          icon: const Icon(Icons.playlist_add),
                          label: const Text('Selecionar Itens'),
                        ),
                      ),
                      if (_selectedItems.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Itens selecionados', style: TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              ..._selectedItems.map((s) {
                                final total = s.lotes.length > 1
                                    ? s.lotes.fold<int>(0, (acc, l) => acc + l.quantidade)
                                    : s.quantidadeTotal;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text('${s.nome} (${s.unidade})')),
                                      Text('Qtd: $total'),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
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
                        suffixIcon: (_formHandler.selectedDate != null && !_isSubmitting)
                            ? IconButton(
                                tooltip: 'Limpar data',
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _formHandler.selectedDate = null;
                                    _formHandler.dateController.clear();
                                  });
                                },
                              )
                            : null,
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
