import 'package:flutter/material.dart';

enum SortType {
  alphabetic,
  numeric,
}

class TableColumn {
  final String title;
  final String dataField;
  final double widthFactor;
  final SortType? sortType;

  final Widget Function(dynamic value)? cellBuilder;
  final String Function(dynamic)? formatter;
  
  final TextStyle? textStyle;

  TableColumn({
    required this.title,
    required this.dataField,
    required this.widthFactor,
    this.sortType,
    this.cellBuilder,
    this.formatter,
    this.textStyle,
  });
}