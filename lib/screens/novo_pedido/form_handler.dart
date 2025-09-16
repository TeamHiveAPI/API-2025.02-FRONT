import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewOrderFormHandler {
  final formKey = GlobalKey<FormState>();
  bool hasSubmitted = false;
  final searchController = TextEditingController();
  final quantityController = TextEditingController();
  final dateController = TextEditingController();

  Map<String, dynamic>? selectedItem;
  DateTime? selectedDate;

String? validateItem(String? value, List<String> validItemNames) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo obrigatório.';
  }

  final normalizedValue = value.trim().toLowerCase();
  final normalizedNames =
      validItemNames.map((e) => e.toLowerCase()).toList();

  if (!normalizedNames.contains(normalizedValue)) {
    return 'Item inválido. Selecione uma opção da lista.';
  }

  return null;
}


  String? validateQuantity(String? value) {
    if ((value == null || value.isEmpty) && !hasSubmitted) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'Campo obrigatório.';
    }

    final quantity = int.tryParse(value) ?? 0;
    if (quantity <= 0) {
      return 'A quantidade deve ser maior que zero.';
    }
    if (selectedItem != null) {
      final available =
          selectedItem!['quantity'] - selectedItem!['qtdReservada'];
      if (quantity > available) {
        return 'Quantidade excede o estoque disponível ($available).';
      }
    }
    return null;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      selectedDate = picked;
      dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void reset() {
    formKey.currentState?.reset();
    searchController.clear();
    quantityController.clear();
    dateController.clear();
    selectedItem = null;
    selectedDate = null;
  }

  void dispose() {
    searchController.dispose();
    quantityController.dispose();
    dateController.dispose();
  }
}
