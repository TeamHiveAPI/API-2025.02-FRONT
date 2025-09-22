import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/button.dart';
import 'table_column.dart';

const TextStyle _defaultCellTextStyle = TextStyle(
  color: text40,
  fontWeight: FontWeight.w600,
);
const Color _rowHighlightColor = Color(0x1A000000);
const Color _rowSplashColor = Color(0x1F000000);

enum ThisOrThatSortState { none, primaryFirst, secondaryFirst }

class DynamicJsonTable extends StatelessWidget {
  final List<Map<String, dynamic>> jsonData;
  final List<TableColumn> columns;
  final int totalResults;
  final bool canLoadMore;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final void Function(TableColumn column) onSort;
  final void Function(Map<String, dynamic> rowData)? onRowTap;

  final String? activeSortColumnDataField;
  final bool isAscending;
  final ThisOrThatSortState thisOrThatState;

  final bool showSkeleton;
  final bool hidePagination;

  const DynamicJsonTable({
    super.key,
    required this.jsonData,
    required this.columns,
    required this.totalResults,
    required this.canLoadMore,
    this.isLoading = false,
    this.onLoadMore,
    required this.onSort,
    this.onRowTap,
    this.activeSortColumnDataField,
    required this.isAscending,
    required this.thisOrThatState,
    this.showSkeleton = false,
    this.hidePagination = false,
  });

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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: coolGray, width: 2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: Column(
              children: [
                _buildHeaderRow(),
                if (jsonData.isEmpty && !isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text('Nenhum dado encontrado.')),
                  ),
                ..._buildDataRows(),
              ],
            ),
          ),
        ),
        if (totalResults > 0 && !hidePagination)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _buildFooter(),
          ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: coolGray,
      child: Row(
        children: columns.map((column) {
          bool isSortable = column.sortType != null;
          bool isActiveSortColumn =
              activeSortColumnDataField == column.dataField;

          IconData iconData = Icons.unfold_more;

          if (isActiveSortColumn) {
            if (column.sortType == SortType.thisOrThat) {
              if (thisOrThatState == ThisOrThatSortState.primaryFirst) {
                iconData = Icons.arrow_downward;
              } else if (thisOrThatState ==
                  ThisOrThatSortState.secondaryFirst) {
                iconData = Icons.arrow_upward;
              }
            } else {
              iconData = isAscending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward;
            }
          }

          return Expanded(
            flex: (column.widthFactor * 100).toInt(),
            child: InkWell(
              onTap: isSortable ? () => onSort(column) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
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
    return jsonData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> rowData = entry.value;

      Widget rowContent;

      if (showSkeleton) {
        rowContent = Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Row(
            children: columns.map((column) {
              return Expanded(
                flex: (column.widthFactor * 100).toInt(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 16.975,
                  ),
                  child: Container(
                    height: 14.0,
                    decoration: BoxDecoration(
                      color: Colors
                          .white,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      } else {
        rowContent = InkWell(
          onTap: isLoading ? null : () => onRowTap?.call(rowData),
          highlightColor: _rowHighlightColor,
          splashColor: _rowSplashColor,
          child: Row(
            children: columns.map((column) {
              final rawValue = _getValueFromPath(rowData, column.dataField);
              final Widget cellContent;
              if (column.cellBuilder != null) {
                cellContent = column.cellBuilder!(rawValue);
              } else {
                final displayValue =
                    column.formatter?.call(rawValue) ??
                    rawValue?.toString() ??
                    '';
                cellContent = Text(
                  displayValue,
                  style: _defaultCellTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }

              return Expanded(
                flex: (column.widthFactor * 100).toInt(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  child: cellContent,
                ),
              );
            }).toList(),
          ),
        );
      }

      return Material(
        color: index.isOdd ? brightGray : Colors.white,
        child: rowContent,
      );
    }).toList();
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Mostrando ${jsonData.length} de $totalResults resultados',
          style: const TextStyle(color: text80, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (canLoadMore)
          CustomButton(
            text: 'Carregar Mais',
            secondary: true,
            widthPercent: 1.0,
            onPressed: isLoading ? null : onLoadMore,
            isLoading: isLoading,
          ),
      ],
    );
  }
}
