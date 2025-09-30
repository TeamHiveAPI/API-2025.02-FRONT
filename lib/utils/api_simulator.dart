import 'table_handler_mixin.dart';

Future<PaginatedResponse> getRecentMovements({String? searchQuery}) async {
  await Future.delayed(const Duration(milliseconds: 500));

  final data = [
    {
      'item_name': 'Kit Primeiros Socorros Legal',
      'quantity': '+2',
      'responsible': 'Mauro'
    },
    {
      'item_name': 'Vestimenta',
      'quantity': '-5',
      'responsible': 'Gabriel'
    },
    {
      'item_name': 'Munição 9mm',
      'quantity': '-50',
      'responsible': 'Almeida'
    },
  ];

  List<Map<String, dynamic>> filteredData = data;

  if (searchQuery != null && searchQuery.isNotEmpty) {
    final lowerCaseQuery = searchQuery.toLowerCase();
    filteredData = data.where((item) {
      return ['item_name', 'quantity', 'responsible', 'date'].any((field) {
        final value = item[field]?.toString().toLowerCase() ?? '';
        return value.contains(lowerCaseQuery);
      });
    }).toList();
  }

  return PaginatedResponse(
    items: filteredData,
    totalCount: filteredData.length,
  );
}
