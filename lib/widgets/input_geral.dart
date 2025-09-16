import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class CustomInput extends StatefulWidget {
  final bool isCalendarMode;
  final bool onlyNumbers;
  final String? iconPath;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<String>? onChanged;

  const CustomInput({
    super.key,
    this.isCalendarMode = false,
    this.onlyNumbers = false,
    this.iconPath,
    this.hintText,
    this.controller,
    this.onDateSelected,
    this.onChanged,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      readOnly: widget.isCalendarMode,
      onTap: widget.isCalendarMode ? () => _selectDate(context) : null,
      keyboardType:
          widget.onlyNumbers ? TextInputType.number : TextInputType.text,
      inputFormatters: widget.onlyNumbers
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        prefixIcon: (widget.isCalendarMode || widget.iconPath != null)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SvgPicture.asset(
                  widget.isCalendarMode
                      ? 'assets/icons/calendar.svg'
                      : widget.iconPath!,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minHeight: 20, minWidth: 20),
        hintText: widget.isCalendarMode ? 'Selecionar' : widget.hintText,
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFC4C4C4), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2847AE), width: 1.5),
        ),
      ),
    );
  }
}