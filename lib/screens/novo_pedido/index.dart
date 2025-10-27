import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
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

  final bool _isLoading = false;
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
    final result = await ItemPickerModal.show(
      context,
      initialSelection: _selectedItems,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedItems = result.items;
        _formHandler.searchController.clear();
        _formHandler.selectedItem = null;
        _formHandler.quantityController.clear();
      });
    }
  }

  Future<void> _submitOrder() async {
    setState(() => _formHandler.hasSubmitted = true);

    if (_selectedItems.isEmpty) {
      showCustomSnackbar(
        context,
        'Selecione ao menos um item no botão "Selecionar Itens".',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? dataRetirada;
      if (_formHandler.selectedDate != null) {
        dataRetirada = DateFormat(
          'yyyy-MM-dd',
        ).format(_formHandler.selectedDate!);
      }

      final itens = _selectedItems
          .map((s) {
            List<Map<String, dynamic>> lotes;
            int total;
            if (s.lotes.length > 1) {
              lotes = s.lotes
                  .where((l) => l.quantidade > 0)
                  .map(
                    (l) => {
                      'lote_id': l.loteId,
                      'codigo': l.codigo,
                      'quantidade': l.quantidade,
                    },
                  )
                  .toList();
              total = s.lotes.fold<int>(0, (acc, l) => acc + l.quantidade);
            } else if (s.lotes.length == 1) {
              final unico = s.lotes.first;
              final q = s.quantidadeTotal;
              final dynamic codigo = unico.codigo;
              lotes = q > 0
                  ? [
                      {
                        'lote_id': unico.loteId,
                        'codigo': codigo,
                        'quantidade': q,
                      },
                    ]
                  : [];
              total = q;
            } else {
              total = s.quantidadeTotal;
              lotes = const [];
            }
            return {'item_id': s.itemId, 'quantidade': total, 'lotes': lotes};
          })
          .where((e) => (e['quantidade'] as int) > 0)
          .toList();

      if (itens.isEmpty) {
        showCustomSnackbar(
          context,
          'Selecione quantidades válidas.',
          isError: true,
        );
        setState(() => _isSubmitting = false);
        return;
      }

      await PedidoService.instance.createPedidoMulti(
        itens: itens,
        dataRetirada: dataRetirada,
      );

      if (mounted) {
        showCustomSnackbar(context, 'Pedido registrado com sucesso!');
        final mainScaffoldState = context
            .findAncestorStateOfType<MainScaffoldState>();
        if (mainScaffoldState != null) {
          final ordersPageIndex = mainScaffoldState.findPageIndexByName(
            'Pedidos',
          );
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
                      CustomButton(
                        text: 'Selecionar Itens',
                        icon: Icons.add,
                        onPressed: _isSubmitting ? null : _openItemPicker,
                        widthPercent: 1.0,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'ITENS SELECIONADOS',
                        style: TextStyle(color: text60, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedItems.isNotEmpty) ...[
                        Column(
                          children: [
                            for (int i = 0; i < _selectedItems.length; i++) ...[
                              Builder(
                                builder: (context) {
                                  final s = _selectedItems[i];
                                  final total = s.lotes.length > 1
                                      ? s.lotes.fold<int>(
                                          0,
                                          (acc, l) => acc + l.quantidade,
                                        )
                                      : s.quantidadeTotal;

                                  int lotesSelecionadosCount = 0;
                                  if (s.lotes.length > 1) {
                                    lotesSelecionadosCount = s.lotes
                                        .where((l) => l.quantidade > 0)
                                        .length;
                                  } else if (s.lotes.length == 1) {
                                    lotesSelecionadosCount =
                                        s.quantidadeTotal > 0 ? 1 : 0;
                                  }
                                  final String countFormatado =
                                      lotesSelecionadosCount.toString().padLeft(
                                        2,
                                        '0',
                                      );
                                  final String loteText =
                                      lotesSelecionadosCount == 1
                                      ? '$countFormatado lote'
                                      : '$countFormatado lotes';

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: brandBlueLight,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(s.nome),
                                              ),
                                              const SizedBox(height: 4),
                                              if (s.lotes.isNotEmpty)
                                                Text(
                                                  loteText,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: text60,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: coolGray,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'QTD: $total',
                                                style: TextStyle(color: text40),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              s.unidade,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: text60,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(width: 8),

                                        CustomButton(
                                          squareMode: true,
                                          danger: true,
                                          onPressed: _isSubmitting
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _selectedItems.removeWhere(
                                                      (it) =>
                                                          it.itemId == s.itemId,
                                                    );
                                                  });
                                                },
                                          borderRadius: 8.0,
                                          customIcon: "assets/icons/trash.svg",
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              if (i < _selectedItems.length - 1)
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color.fromARGB(12, 0, 0, 0),
                                ),
                            ],
                          ],
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 32.0,
                            horizontal: 16.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/box.svg',
                                width: 40,
                                height: 40,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Selecione um item da lista para vê-lo aqui',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      CustomTextFormField(
                        upperLabel: 'DATA DE RETIRADA',
                        hintText: 'Opcional',
                        controller: _formHandler.dateController,
                        onTap: () async {
                          await _formHandler.selectDate(context);
                          setState(() {});
                        },
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset('assets/icons/calendar.svg'),
                        ),
                        suffixIcon:
                            (_formHandler.selectedDate != null &&
                                !_isSubmitting)
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
