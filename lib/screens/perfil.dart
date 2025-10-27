import 'package:flutter/material.dart';
import 'package:sistema_almox/app_routes.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/user_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = UserService.instance.currentUser;
    final isMedico = currentUser?.idSetor == 4;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20),
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 100, color: brandBlue),
            const SizedBox(height: 20),
            Text(
              currentUser?.nome ?? 'Usuário',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: text40,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currentUser?.email ?? '',
              style: const TextStyle(fontSize: 14, color: text60),
            ),
            const SizedBox(height: 40),
            if (isMedico)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.configHorario);
                  },
                  icon: const Icon(Icons.access_time),
                  label: const Text('Configurar Horário de Trabalho'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
