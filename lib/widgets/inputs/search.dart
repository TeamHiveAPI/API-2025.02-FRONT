import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class GenericSearchInput extends StatefulWidget {
  final String? upperLabel;
  final String hintText;
  final TextEditingController? controller;

  final ValueChanged<String>? onSearchChanged;
  final Duration debounceDuration;

  final List<String>? suggestions;
  final ValueChanged<String>? onItemSelected;

  final String? Function(String?)? validator;

  const GenericSearchInput({
    super.key,
    this.upperLabel,
    this.hintText = 'Pesquisar',
    this.controller,
    this.onSearchChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.suggestions,
    this.onItemSelected,
    this.validator,
  });

  @override
  State<GenericSearchInput> createState() => _GenericSearchInputState();
}

class _GenericSearchInputState extends State<GenericSearchInput> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.onSearchChanged != null) {
      _controller.addListener(_onSearchTextChanged);
    }
  }

  void _onSearchTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      if (mounted) {
        widget.onSearchChanged?.call(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.onSearchChanged != null) {
      _controller.removeListener(_onSearchTextChanged);
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: widget.hintText,
      prefixIcon: const Icon(Icons.search, color: text80),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 12.0,
      ),
      errorStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        height: 2.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAutocompleteMode =
        widget.suggestions != null && widget.onItemSelected != null;

    Widget searchField;

    if (isAutocompleteMode) {
      searchField = FormField<String>(
        validator: widget.validator,
        builder: (FormFieldState<String> field) {
          return Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return widget.suggestions!.where((String option) {
                return option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
              });
            },
            onSelected: (String selection) {
              field.didChange(selection);
              FocusScope.of(context).unfocus();
              widget.onItemSelected!(selection);
            },
            fieldViewBuilder:
                (
                  BuildContext context,
                  TextEditingController fieldController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextFormField(
                    controller: fieldController,
                    focusNode: fieldFocusNode,
                    decoration: _buildInputDecoration().copyWith(
                      errorText: field.errorText,
                    ),
                  );
                },
            optionsViewBuilder:
                (
                  BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options,
                ) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Material(
                        elevation: 8.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            itemCount: options.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: Color(0xFFF5F5F5),
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  child: Text(option),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
          );
        },
      );
    } else {
      searchField = TextFormField(
        controller: _controller,
        decoration: _buildInputDecoration(),
        validator: widget.validator,
      );
    }

    if (widget.upperLabel != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.upperLabel!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF606060),
            ),
          ),
          const SizedBox(height: 8.0),
          searchField,
        ],
      );
    }

    return searchField;
  }
}
