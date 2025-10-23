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
      return 'Campo obrigatório';
    }

    final normalizedValue = value.trim().toLowerCase();
    final normalizedNames = validItemNames.map((e) => e.toLowerCase()).toList();

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
      return 'Campo obrigatório';
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
    // Permitir seleção apenas de hoje em diante (sem datas no passado)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = (selectedDate != null && !selectedDate!.isBefore(today))
        ? selectedDate!
        : today;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
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
