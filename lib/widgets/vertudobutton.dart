import 'package:flutter/material.dart';

class VerTudoButton extends StatelessWidget {
  const VerTudoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {}, 
      child: const Text(
        'Ver Tudo',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2F4DB1),
        ),
      ),
    );
  }
}