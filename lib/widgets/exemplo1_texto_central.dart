import 'package:flutter/material.dart';

class Exemplo1TextoCentral extends StatelessWidget {
  final String texto;
  final Color cor;

  Exemplo1TextoCentral({required this.texto, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: cor,
      ),
      textAlign: TextAlign.center,
    );
  }
}
