import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String? upperLabel;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final AutovalidateMode? autovalidateMode;

  const CustomTextFormField({
    super.key,
    this.label,
    this.upperLabel,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.prefixIcon,
    this.inputFormatters,
    this.obscureText = false,
    this.autovalidateMode,
  }) : assert(
         label != null || upperLabel != null,
         'Você deve fornecer um Label ou UpperLabel.',
       );

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        labelText: upperLabel == null ? label : null,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: text80,
          fontSize: 14,
        ),
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 10.0,
        ),
        errorStyle: const TextStyle(fontWeight: FontWeight.w600, height: 2.0),
      ),
    );

    if (upperLabel != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            upperLabel!,
            style: const TextStyle(
              fontSize: 15,
              color: text60,
            ),
          ),
          const SizedBox(height: 8.0),
          textField,
        ],
      );
    }

    return textField;
  }
}
