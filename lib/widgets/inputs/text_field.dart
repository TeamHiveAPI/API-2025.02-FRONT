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
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final AutovalidateMode? autovalidateMode;
  final bool textarea;

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
    this.suffixIcon,
    this.inputFormatters,
    this.obscureText = false,
    this.autovalidateMode,
    this.textarea = false,
  }) : assert(
          label != null || upperLabel != null,
          'Você deve fornecer um Label ou UpperLabel.',
        );

  @override
  Widget build(BuildContext context) {
    final readOnlyBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    );

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
      minLines: textarea ? 3 : 1,
      maxLines: textarea ? null : 1,
      style: TextStyle(
        color: readOnly ? text60: text40,
        fontSize: 16.0
      ),
      decoration: InputDecoration(
        labelText: upperLabel == null ? label : null,
        labelStyle: const TextStyle(color: text80, fontSize: 14),
        hintText: hintText,
        hintStyle: const TextStyle(color: text80, fontSize: 14),

        filled: readOnly,
        fillColor: brightGray,
        border: readOnly ? readOnlyBorder : null,
        enabledBorder: readOnly ? readOnlyBorder : null,
        focusedBorder: readOnly ? readOnlyBorder : null,

        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefix: SizedBox(
          width: prefixIcon != null || label != null ? 0.0 : 10.0,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: textarea ? 12.0 : 8.0,
          horizontal: (label != null ? 10.0 : 0.0),
        ),
        alignLabelWithHint: textarea,
        errorStyle: const TextStyle(fontWeight: FontWeight.w600, height: 2.0),
      ),
    );

    if (upperLabel != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            upperLabel!,
            style: const TextStyle(fontSize: 15, color: text60),
          ),
          const SizedBox(height: 8.0),
          textField,
        ],
      );
    }

    return textField;
  }
}