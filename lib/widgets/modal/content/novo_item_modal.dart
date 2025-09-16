import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/screens/pedidos.dart';
import 'package:sistema_almox/widgets/custom_bottom_sheet.dart';

void showNovoItemModal(BuildContext context) {
  showCustomBottomSheet(
    context: context,
    title: 'Novo Item',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context); 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_scanner,
                      size: 28, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Aumentar estoque de um item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: text40,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Via escaneamento de QR Code',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            Navigator.pop(context); 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderScreen(), 
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2,
                      size: 28, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Cadastrar do zero',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: text40,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Adicione um item novo ao estoque',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Center(
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade50,
              foregroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Voltar',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    ),
  );
}
