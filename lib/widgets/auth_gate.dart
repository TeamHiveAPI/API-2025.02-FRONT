import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_almox/screens/login.dart';
import 'package:sistema_almox/widgets/main_scaffold/index.dart';
import 'package:sistema_almox/services/user_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserService>(
      builder: (context, userService, child) {
        if (userService.isLoggedIn) {
          return const MainScaffold();
        } else {
          return const Login();
        }
      },
    );
  }
}