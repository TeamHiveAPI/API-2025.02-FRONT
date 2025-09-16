import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class OrderPreviewCard extends StatelessWidget {
  final bool isSelectionMode;
  final String? title;
  final String? unit;
  final String? requested;
  final String? available;

  const OrderPreviewCard({
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
        color: isSelectionMode
            ? const Color(0xFFF5F5F5)
            : const Color(0xFFF7F9FF),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: isSelectionMode
          ? const Center(
              child: Text(
                'Após Seleção',
                style: TextStyle(
                  color: text80,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
                        color: brandBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/box.svg',
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
                          color: brandBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                        color: text60,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      requested ?? '0',
                      style: const TextStyle(
                        color: text40,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Disponível: ',
                      style: TextStyle(
                        color: text60,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      available ?? '0',
                      style: const TextStyle(
                        color: text40,
                        fontWeight: FontWeight.w600,
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
