import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class DropdownOption<T> {
  final T value;
  final String label;

  const DropdownOption({required this.value, required this.label});
}

class CustomDropdownInput<T> extends StatefulWidget {
  final String? upperLabel;
  final String hintText;
  final List<DropdownOption<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const CustomDropdownInput({
    super.key,
    this.upperLabel,
    this.hintText = 'Selecione',
    required this.items,
    this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  State<CustomDropdownInput<T>> createState() => _CustomDropdownInputState<T>();
}

class _CustomDropdownInputState<T> extends State<CustomDropdownInput<T>> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  late final TextEditingController _textController;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _updateTextControllerWithValue(widget.value);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    _hideOverlay();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomDropdownInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _updateTextControllerWithValue(widget.value);
    }
  }

  void _updateTextControllerWithValue(T? value) {
    if (value == null) {
      _textController.text = '';
      return;
    }
    final selectedOption = widget.items.firstWhere(
      (option) => option.value == value,
      orElse: () => DropdownOption(value: value, label: ''),
    );
    _textController.text = selectedOption.label;
  }

  void _showOverlay(FormFieldState<T> field) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: _buildOptionsList(field),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onItemSelected(DropdownOption<T> option, FormFieldState<T> field) {
    field.didChange(option.value);
    _textController.text = option.label;
    widget.onChanged(option.value);
    _focusNode.unfocus();
  }

  Widget _buildOptionsList(FormFieldState<T> field) {
    return Material(
      elevation: 8.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: widget.items.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: coolGray),
          itemBuilder: (context, index) {
            final option = widget.items[index];
            return InkWell(
              onTap: () => _onItemSelected(option, field),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Text(option.label),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget field = FormField<T>(
      validator: widget.validator,
      initialValue: widget.value,
      builder: (FormFieldState<T> field) {
        return CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: () {
              if (_focusNode.hasFocus) {
                _focusNode.unfocus();
              } else {
                _focusNode.requestFocus();
                _showOverlay(field);
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: _textController,
                focusNode: _focusNode,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(color: text80, fontSize: 14),
                  errorText: field.errorText,
                  suffixIcon: Icon(
                    _focusNode.hasFocus
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                  ),
                  errorStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 2.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.upperLabel != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.upperLabel!,
            style: const TextStyle(fontSize: 15, color: text60),
          ),
          const SizedBox(height: 8.0),
          field,
        ],
      );
    }
    return field;
  }
}
