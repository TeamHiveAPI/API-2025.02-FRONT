import 'package:flutter/material.dart';
import 'package:sistema_almox/config/permissions.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/services/user_service.dart';
import 'package:sistema_almox/widgets/button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _toggleRole() {
    final currentRole = UserService.instance.currentUser!.role;

    final newRole = currentRole == UserRole.tenenteFarmacia
        ? UserRole.tenenteEstoque
        : UserRole.tenenteFarmacia;

    UserService.instance.login(newRole);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentRole = UserService.instance.currentUser!.role;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Página Perfil',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: text40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Perfil atual: ${currentRole.name}',
            style: const TextStyle(fontSize: 18, color: text40),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: _toggleRole,
            text: "Trocar Perfil",
          ),
        ],
      ),
    );
  }
}
