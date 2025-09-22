import 'package:flutter/material.dart';

enum SortType {
  alphabetic,
  numeric,
  thisOrThat,
}

class TableColumn {
  final String title;
  final String dataField;
  final double widthFactor;
  final SortType? sortType;
  final String Function(dynamic)? formatter;
  final Widget Function(dynamic)? cellBuilder;
  
  final String? primarySortValue;
  final String? secondarySortValue;

  TableColumn({
    required this.title,
    required this.dataField,
    this.widthFactor = 1.0,
    this.sortType,
    this.formatter,
    this.cellBuilder,
    this.primarySortValue,
    this.secondarySortValue,
  });
}