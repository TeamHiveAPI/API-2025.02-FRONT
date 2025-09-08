import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'table_column.dart';

const TextStyle _defaultCellTextStyle = TextStyle(
  color: text60,
  fontWeight: FontWeight.w600,
);
const Color _rowHighlightColor = Color(0x1A000000);
const Color _rowSplashColor = Color(0x1F000000);

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
    bool isCurrentlyActive = _activeSortColumnDataField == dataField;

    if (isCurrentlyActive && !_isAscending) {
      setState(() {
        _activeSortColumnDataField = null;
        _sortedData = List.of(widget.jsonData);
      });
      return;
    }
    bool newAscendingState = isCurrentlyActive ? !_isAscending : true;

    setState(() {
      _activeSortColumnDataField = dataField;
      _isAscending = newAscendingState;
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

          return Expanded(
            flex: (column.widthFactor * 100).toInt(),
            child: InkWell(
              onTap: isSortable ? () => _sort(column) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 14.0,
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
                      Icon(
                        isActiveSortColumn
                            ? (_isAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward)
                            : Icons.unfold_more,
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
          onTap: () => widget.onRowTap?.call(rowData),
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
