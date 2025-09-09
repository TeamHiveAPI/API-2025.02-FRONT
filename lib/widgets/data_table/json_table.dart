import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sistema_almox/core/theme/colors.dart';
import 'table_column.dart';

const TextStyle _defaultCellTextStyle = TextStyle(
  color: text60,
  fontWeight: FontWeight.w600,
);
const Color _rowHighlightColor = Color(0x1A000000);
const Color _rowSplashColor = Color(0x1F000000);

enum ThisOrThatSortState { none, primaryFirst, secondaryFirst }

class DynamicJsonTable extends StatefulWidget {
  final List<Map<String, dynamic>> jsonData;
  final List<TableColumn> columns;
  final void Function(Map<String, dynamic> rowData)? onRowTap;

  const DynamicJsonTable({
    super.key,
    required this.jsonData,
    required this.columns,
    this.onRowTap,
  });

  @override
  State<DynamicJsonTable> createState() => _DynamicJsonTableState();
}

class _DynamicJsonTableState extends State<DynamicJsonTable> {
  late List<Map<String, dynamic>> _sortedData;
  String? _activeSortColumnDataField;
  bool _isAscending = true;
  bool _isTapPending = false;

  ThisOrThatSortState _thisOrThatState = ThisOrThatSortState.none;

  @override
  void initState() {
    super.initState();
    _sortedData = List.of(widget.jsonData);
  }

  @override
  void didUpdateWidget(covariant DynamicJsonTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.jsonData != oldWidget.jsonData) {
      _sortedData = List.of(widget.jsonData);
      _activeSortColumnDataField = null;
    }
  }

  dynamic _getValueFromPath(Map<String, dynamic> data, String path) {
    List<String> keys = path.split('.');
    dynamic currentValue = data;
    for (String key in keys) {
      if (currentValue is Map<String, dynamic> &&
          currentValue.containsKey(key)) {
        currentValue = currentValue[key];
      } else {
        return null;
      }
    }
    return currentValue;
  }

  void _sort(TableColumn column) {
    if (column.sortType == null) return;

    final String dataField = column.dataField;
    final bool isCurrentlyActive = _activeSortColumnDataField == dataField;

    setState(() {
      _activeSortColumnDataField = dataField;

      if (column.sortType == SortType.thisOrThat) {
        _isAscending = true;

        ThisOrThatSortState nextState = ThisOrThatSortState.primaryFirst;
        if (isCurrentlyActive) {
          if (_thisOrThatState == ThisOrThatSortState.primaryFirst) {
            nextState = ThisOrThatSortState.secondaryFirst;
          } else if (_thisOrThatState == ThisOrThatSortState.secondaryFirst) {
            nextState = ThisOrThatSortState.none;
          }
        }
        _thisOrThatState = nextState;

        if (_thisOrThatState == ThisOrThatSortState.none) {
          _sortedData = List.of(widget.jsonData);
          _activeSortColumnDataField = null;
        } else {
          _sortedData.sort((a, b) {
            final valueA = _getValueFromPath(a, dataField)?.toString();
            final valueB = _getValueFromPath(b, dataField)?.toString();
            final targetValue =
                _thisOrThatState == ThisOrThatSortState.primaryFirst
                ? column.primarySortValue
                : column.secondarySortValue;

            if (valueA == targetValue && valueB != targetValue) return -1;
            if (valueB == targetValue && valueA != targetValue) return 1;
            return 0;
          });
        }
      } else {
        _thisOrThatState = ThisOrThatSortState.none;

        if (isCurrentlyActive && !_isAscending) {
          _activeSortColumnDataField = null;
          _sortedData = List.of(widget.jsonData);
          return;
        }
        _isAscending = isCurrentlyActive ? !_isAscending : true;

        _sortedData.sort((a, b) {
          final valueA = _getValueFromPath(a, dataField);
          final valueB = _getValueFromPath(b, dataField);
          if (valueA == null) return _isAscending ? -1 : 1;
          if (valueB == null) return _isAscending ? 1 : -1;

          int comparison;
          if (column.sortType == SortType.numeric) {
            comparison = (valueA as num).compareTo(valueB as num);
          } else {
            comparison = valueA.toString().toLowerCase().compareTo(
              valueB.toString().toLowerCase(),
            );
          }
          return _isAscending ? comparison : -comparison;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sortedData.isEmpty) {
      return const Center(child: Text('Nenhum dado encontrado.'));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: coolGray, width: 2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: Column(children: [_buildHeaderRow(), ..._buildDataRows()]),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: coolGray,
      child: Row(
        children: widget.columns.map((column) {
          bool isSortable = column.sortType != null;
          bool isActiveSortColumn =
              _activeSortColumnDataField == column.dataField;

          IconData iconData = Icons.unfold_more;

          if (isActiveSortColumn) {
            if (column.sortType == SortType.thisOrThat) {
              if (_thisOrThatState == ThisOrThatSortState.primaryFirst) {
                iconData = Icons.arrow_downward;
              } else if (_thisOrThatState ==
                  ThisOrThatSortState.secondaryFirst) {
                iconData = Icons.arrow_upward;
              }
            } else {
              iconData = _isAscending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward;
            }
          }

          return Expanded(
            flex: (column.widthFactor * 100).toInt(),
            child: InkWell(
              onTap: isSortable ? () => _sort(column) : null,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                  top: 12.0,
                  bottom: 12.0,
                  right: 0.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        column.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: text60,
                        ),
                      ),
                    ),
                    if (isSortable) const SizedBox(width: 4),
                    if (isSortable)
                      if (isSortable)
                        Icon(
                          iconData,
                          size: 14,
                          color: isActiveSortColumn
                              ? text60
                              : text60.withAlpha(128),
                        ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildDataRows() {
    return _sortedData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> rowData = entry.value;

      return Material(
        color: index.isOdd ? brightGray : Colors.white,
        child: InkWell(
          onTap: () {
            if (_isTapPending) return;
            _isTapPending = true;
            Timer(const Duration(milliseconds: 250), () {
              if (mounted) {
                widget.onRowTap?.call(rowData);
                _isTapPending = false;
              }
            });
          },
          highlightColor: _rowHighlightColor,
          splashColor: _rowSplashColor,
          child: Row(
            children: widget.columns.map((column) {
              final rawValue = _getValueFromPath(rowData, column.dataField);
              final Widget cellContent;
              if (column.cellBuilder != null) {
                cellContent = column.cellBuilder!(rawValue);
              } else {
                final displayValue =
                    column.formatter?.call(rawValue) ??
                    rawValue?.toString() ??
                    '';
                cellContent = Text(displayValue, style: _defaultCellTextStyle);
              }

              return Expanded(
                flex: (column.widthFactor * 100).toInt(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 14.0,
                  ),
                  child: cellContent,
                ),
              );
            }).toList(),
          ),
        ),
      );
    }).toList();
  }
}
