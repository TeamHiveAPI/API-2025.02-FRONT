import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class TextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? hintText;
  final String? Function(String?)? validator;

  const TextField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = brandBlue;
    final errorColor = deleteRed;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,

      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: text80
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2.0,
          ),
        ),
         errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: errorColor,
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: errorColor,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}