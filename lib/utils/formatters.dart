import 'package:intl/intl.dart';

String formatDate(dynamic date) {
  if (date == null) {
    return 'N/A';
  }

  if (date is String && date == 'Em aberto') {
    return 'Em aberto';
  }

  DateTime? dateObject;

  if (date is DateTime) {
    dateObject = date;
  } else if (date is String) {
    if (date.isEmpty) {
      return 'N/A';
    }
    try {
      dateObject = DateTime.parse(date);
    } catch (e) {
      print('Erro ao formatar data a partir da String: $e');
      return 'Erro';
    }
  } else {
    print('Erro: tipo de dado inválido: ${date.runtimeType}');
    return 'Erro';
  }

  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(dateObject);
}

String formatCPF(String cpf) {
  final digits = cpf.toString().padLeft(11, '0');
  return '${digits.substring(0,3)}.${digits.substring(3,6)}.${digits.substring(6,9)}-${digits.substring(9,11)}';
}