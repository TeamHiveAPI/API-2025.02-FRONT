import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderCard extends StatelessWidget {
  final bool isSelectionMode;
  final String? title;
  final String? unit;
  final String? requested;
  final String? available;

  const OrderCard({
    super.key,
    this.isSelectionMode = true,
    this.title,
    this.unit,
    this.requested,
    this.available,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelectionMode ? const Color(0xFFF5F5F5) : const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: isSelectionMode
          ? const Center(
              child: Text(
                'Após Seleção',
                style: TextStyle(
                  color: Color(0xFF808080),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2847AE),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/novopedido.svg',
                          width: 24,
                          height: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title ?? 'Sem título',
                        style: const TextStyle(
                          color: Color(0xFF2847AE),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2847AE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        unit ?? 'Unidade de Medida',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Requisitado: ',
                      style: TextStyle(
                        color: Color(0xFF404040),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      requested ?? '0',
                      style: const TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Disponível: ',
                      style: TextStyle(
                        color: Color(0xFF404040),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      available ?? '0',
                      style: const TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}