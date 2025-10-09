import 'package:flutter/material.dart';

class RegisterSupplierFormHandler {
  final formKey = GlobalKey<FormState>();
  bool hasSubmitted = false;

  final nameController = TextEditingController();
  final cnpjController = TextEditingController();
  final contactController = TextEditingController();

  void dispose() {
    nameController.dispose();
    cnpjController.dispose();
    contactController.dispose();
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? validateCnpj(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    // Remove caracteres não numéricos
    final cnpj = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cnpj.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) {
      return 'CNPJ inválido';
    }

    // Validação dos dígitos verificadores
    if (!_validateCNPJ(cnpj)) {
      return 'CNPJ inválido';
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    // Remove caracteres não numéricos
    final phone = value.replaceAll(RegExp(r'[^\d]'), '');

    // Verifica se é um número brasileiro (DDD + 8 ou 9 dígitos)
    if (phone.length < 10 || phone.length > 11) {
      return 'Número inválido. Use: (XX) XXXXX-XXXX';
    }

    // Verifica se o DDD é válido (11 a 99)
    final ddd = int.tryParse(phone.substring(0, 2));
    if (ddd == null || ddd < 11 || ddd > 99) {
      return 'DDD inválido';
    }

    return null;
  }

  // Função para formatar CNPJ
  String formatCNPJ(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limita a 14 dígitos
    final limitedDigits = digits.length > 14 ? digits.substring(0, 14) : digits;
    
    if (limitedDigits.length <= 2) {
      return limitedDigits;
    } else if (limitedDigits.length <= 5) {
      return '${limitedDigits.substring(0, 2)}.${limitedDigits.substring(2)}';
    } else if (limitedDigits.length <= 8) {
      return '${limitedDigits.substring(0, 2)}.${limitedDigits.substring(2, 5)}.${limitedDigits.substring(5)}';
    } else if (limitedDigits.length <= 12) {
      return '${limitedDigits.substring(0, 2)}.${limitedDigits.substring(2, 5)}.${limitedDigits.substring(5, 8)}/${limitedDigits.substring(8)}';
    } else {
      return '${limitedDigits.substring(0, 2)}.${limitedDigits.substring(2, 5)}.${limitedDigits.substring(5, 8)}/${limitedDigits.substring(8, 12)}-${limitedDigits.substring(12)}';
    }
  }

  // Função para formatar telefone
  String formatPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limita a 11 dígitos (DDD + 9 dígitos)
    final limitedDigits = digits.length > 11 ? digits.substring(0, 11) : digits;
    
    if (limitedDigits.length <= 2) {
      return limitedDigits;
    } else if (limitedDigits.length <= 6) {
      return '(${limitedDigits.substring(0, 2)}) ${limitedDigits.substring(2)}';
    } else if (limitedDigits.length <= 10) {
      return '(${limitedDigits.substring(0, 2)}) ${limitedDigits.substring(2, 6)}-${limitedDigits.substring(6)}';
    } else {
      return '(${limitedDigits.substring(0, 2)}) ${limitedDigits.substring(2, 7)}-${limitedDigits.substring(7)}';
    }
  }

  // Algoritmo de validação de CNPJ
  bool _validateCNPJ(String cnpj) {
    // Peso para o primeiro dígito verificador
    final weight1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    // Peso para o segundo dígito verificador
    final weight2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    // Calcula o primeiro dígito verificador
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * weight1[i];
    }
    var remainder = sum % 11;
    var digit1 = remainder < 2 ? 0 : 11 - remainder;

    // Calcula o segundo dígito verificador
    sum = 0;
    for (var i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * weight2[i];
    }
    remainder = sum % 11;
    var digit2 = remainder < 2 ? 0 : 11 - remainder;

    // Verifica se os dígitos calculados conferem com os informados
    return int.parse(cnpj[12]) == digit1 && int.parse(cnpj[13]) == digit2;
  }

  // Getters para os limites máximos
  int get maxCnpjDigits => 14;
  int get maxPhoneDigits => 11; // DDD (2) + número (9)
}