import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class GenericSearchInput extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final String hintText;
  final Duration debounceDuration;

  const GenericSearchInput({
    super.key,
    required this.onSearchChanged,
    this.hintText = 'Pesquisar',
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<GenericSearchInput> createState() => _GenericSearchInputState();
}

class _GenericSearchInputState extends State<GenericSearchInput> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onSearchChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchTextChanged);
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _controller.clear();
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: brightGray),
        ),
      ),
    );
  }
}