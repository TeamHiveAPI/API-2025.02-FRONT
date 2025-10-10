import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sistema_almox/core/theme/colors.dart'; // Verifique o caminho do import

class AdminHeaderCard extends StatelessWidget {
  const AdminHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 24.0, 16.0),
      decoration: BoxDecoration(
        color: brandBlue,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Administração',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Text(
                    'Gerencie o sistema com os cards abaixo.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha(190),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/icons/admin_shield.svg',
            width: 56,
            height: 56,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
