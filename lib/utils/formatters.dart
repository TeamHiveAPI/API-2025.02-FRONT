import 'package:intl/intl.dart';

String formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return 'N/A';
  }

  try {
    final DateTime dateObject = DateTime.parse(dateString);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateObject);
    
  } catch (e) {
    print('Erro ao formatar data: $e');
    return 'N/A';
  }
}