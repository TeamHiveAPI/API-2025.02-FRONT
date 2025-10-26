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
  
  final Widget Function(dynamic value, Map<String, dynamic> rowData)? advancedCellBuilder;
  
  final String? primarySortValue;
  final String? secondarySortValue;

  TableColumn({
    required this.title,
    required this.dataField,
    this.widthFactor = 1.0,
    this.sortType,
    this.formatter,
    this.cellBuilder,
    this.advancedCellBuilder,
    this.primarySortValue,
    this.secondarySortValue,
  }) : assert(
         cellBuilder == null || advancedCellBuilder == null,
       );
}