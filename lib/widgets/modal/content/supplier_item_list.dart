import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class ItensFornecidosModal extends StatelessWidget {
  final List<dynamic> items;

  const ItensFornecidosModal({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300.0),
          child: Flexible(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                String itemName = 'Nome não encontrado';

                if (item is Map<String, dynamic>) {
                  itemName =
                      item['nome_item'] as String? ??
                      item['nome'] as String? ??
                      'Nome indisponível';
                } else if (item is String) {
                  itemName = item;
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 24,
                        decoration: BoxDecoration(
                          color: brandBlueLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: TextStyle(
                            color: brandBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12.0),

                      Expanded(child: Text(itemName, style: TextStyle(color: text40, fontSize: 15))),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
