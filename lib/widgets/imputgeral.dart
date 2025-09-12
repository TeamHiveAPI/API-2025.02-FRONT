import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatefulWidget {
  final bool isCalendarMode;
  final bool onlyNumbers;
  final String? iconPath;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<DateTime>? onDateSelected;

  const CustomInput({
    super.key,
    this.isCalendarMode = false,
    this.onlyNumbers = false,
    this.iconPath,
    this.hintText,
    this.controller,
    this.onDateSelected,
  });

  @override
  _CustomInputState createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
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
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(picked);
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isCalendarMode ? () => _selectDate(context) : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _isFocused ? const Color(0xFF2847AE) : const Color(0xFFC4C4C4),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Row(
          children: [
            if (widget.iconPath != null || widget.isCalendarMode)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SvgPicture.asset(
                  widget.isCalendarMode
                      ? 'assets/icons/calendar.svg'
                      : widget.iconPath!,
                  height: 20,
                  width: 20,
                ),
              ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.isCalendarMode,
                keyboardType: widget.onlyNumbers ? TextInputType.number : TextInputType.text,
                inputFormatters: widget.onlyNumbers
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
                decoration: InputDecoration(
                  hintText: widget.isCalendarMode ? 'Selecionar' : widget.hintText,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}