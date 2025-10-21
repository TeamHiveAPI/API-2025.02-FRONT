import 'package:flutter/material.dart';

class RegisterSupplierFormHandler {
  final formKey = GlobalKey<FormState>();
  bool hasSubmitted = false;

  final nameController = TextEditingController();
  final cnpjController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();

  void dispose() {
    nameController.dispose();
    cnpjController.dispose();
    telefoneController.dispose();
    emailController.dispose();
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

    final cnpj = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cnpj.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }

    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) {
      return 'CNPJ inválido';
    }

    if (!_validateCNPJ(cnpj)) {
      return 'CNPJ inválido';
    }

    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    final phone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (phone.length < 10 || phone.length > 11) {
      return 'Número inválido. Use: (XX) XXXXX-XXXX';
    }

    final ddd = int.tryParse(phone.substring(0, 2));
    if (ddd == null || ddd < 11 || ddd > 99) {
      return 'DDD inválido';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; 
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String formatCNPJ(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    
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

  String formatPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    
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

  bool _validateCNPJ(String cnpj) {
    final weight1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    final weight2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * weight1[i];
    }
    var remainder = sum % 11;
    var digit1 = remainder < 2 ? 0 : 11 - remainder;

    sum = 0;
    for (var i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * weight2[i];
    }
    remainder = sum % 11;
    var digit2 = remainder < 2 ? 0 : 11 - remainder;

    return int.parse(cnpj[12]) == digit1 && int.parse(cnpj[13]) == digit2;
  }

  int get maxCnpjDigits => 14;
  int get maxPhoneDigits => 11; 
}