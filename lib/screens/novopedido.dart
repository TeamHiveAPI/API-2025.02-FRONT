import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/imputgeral.dart';
import 'package:sistema_almox/widgets/titleheader.dart';
import 'package:sistema_almox/widgets/buttonaddfooter.dart';
import 'package:sistema_almox/widgets/cardpedido.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  _NewOrderScreenState createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  List<Map<String, dynamic>> inventory = [];
  List<Map<String, dynamic>> filteredItems = [];
  Map<String, dynamic>? selectedItem;
  List<Map<String, dynamic>> addedOrders = [];
  String? requestedQuantity;
  DateTime? selectedDate;
  TextEditingController searchController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadInventory();
  }

  Future<void> loadInventory() async {
    try {
      final String response = await rootBundle.loadString('lib/temp/estoque.json');
      final List<dynamic> data = jsonDecode(response);
      setState(() {
        inventory = data.cast<Map<String, dynamic>>();
        filteredItems = inventory;
      });
    } catch (e) {
      print('Erro ao carregar inventário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar o inventário')),
      );
    }
  }

  void filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredItems = inventory;
        selectedItem = null;
      } else {
        filteredItems = inventory
            .where((item) =>
                item['itemName'].toLowerCase().contains(query.toLowerCase()))
            .toList();
        selectedItem = filteredItems.isNotEmpty ? filteredItems[0] : null;
      }
    });
  }

  void addOrder() {
    if (selectedItem == null || requestedQuantity == null || requestedQuantity!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um item e informe a quantidade')),
      );
      return;
    }

    final int requested = int.tryParse(requestedQuantity!) ?? 0;
    final int available = selectedItem!['quantity'] - selectedItem!['qtdReservada'];
    if (requested <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A quantidade deve ser maior que zero')),
      );
      return;
    }
    if (requested > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantidade requisitada excede o disponível')),
      );
      return;
    }

    setState(() {
      addedOrders.add({
        'itemName': selectedItem!['itemName'],
        'unidMedida': selectedItem!['unidMedida'],
        'requested': requestedQuantity,
        'available': '$available ${selectedItem!['unidMedida']}',
        'date': selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : 'Não especificada',
      });
      // Limpar campos após adicionar
      searchController.clear();
      quantityController.clear();
      selectedItem = null;
      filteredItems = inventory;
      requestedQuantity = null;
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderComponent(title: 'Registrar Novo Pedido'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ITEM REQUISITADO Section
                    const Text(
                      'ITEM REQUISITADO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF606060),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomInput(
                      hintText: 'Digite algo',
                      iconPath: 'assets/icons/lupa.svg',
                      controller: searchController,
                      onChanged: filterItems,
                    ),
                    const SizedBox(height: 16),

                    // QUANTIDADE Section
                    const Text(
                      'QUANTIDADE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF606060),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomInput(
                      hintText: 'Digite a quantidade',
                      controller: quantityController,
                      onlyNumbers: true,
                      onChanged: (value) {
                        setState(() {
                          requestedQuantity = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // DATA DE RETIRADA Section
                    const Text(
                      'DATA DE RETIRADA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF606060),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomInput(
                      isCalendarMode: true,
                      onDateSelected: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // OrderCard Section
                    if (addedOrders.isEmpty)
                      const OrderCard(isSelectionMode: true)
                    else
                      Column(
                        children: addedOrders.map((order) {
                          return OrderCard(
                            isSelectionMode: false,
                            title: order['itemName'],
                            unit: order['unidMedida'],
                            requested: order['requested'],
                            available: order['available'],
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            FooterComponent(
              buttonText: 'Adicionar Pedido',
              onButtonPressed: addOrder,
            ),
          ],
        ),
      ),
    );
  }
}