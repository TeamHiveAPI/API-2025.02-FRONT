import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';

class ConsumoSetorChart extends StatelessWidget {
  final int almoxarifadoRealTotal;
  final int almoxarifadoPrevistoTotal;
  final int farmaciaRealTotal;
  final int farmaciaPrevistoTotal;

  const ConsumoSetorChart({
    super.key,
    required this.almoxarifadoRealTotal,
    required this.almoxarifadoPrevistoTotal,
    required this.farmaciaRealTotal,
    required this.farmaciaPrevistoTotal,
  });

  @override
  Widget build(BuildContext context) {
    final double maxValue = [
      almoxarifadoRealTotal,
      almoxarifadoPrevistoTotal,
      farmaciaRealTotal,
      farmaciaPrevistoTotal,
    ].reduce((a, b) => a > b ? a : b).toDouble();

    final double valueWithMargin = maxValue * 1.2;

    final double maxY = (valueWithMargin / 50).ceil() * 50;

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black.withAlpha(200),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String label = '';
                    if (group.x == 0) {
                      label = (rodIndex == 0)
                          ? 'Consumo Real'
                          : 'Consumo Previsto';
                    } else if (group.x == 1) {
                      label = (rodIndex == 0)
                          ? 'Consumo Real'
                          : 'Consumo Previsto';
                    }
                    return BarTooltipItem(
                      '$label: ${rod.toY.toInt()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      String text;
                      if (value == 0) {
                        text = 'Almoxarifado';
                      } else if (value == 1) {
                        text = 'Farmácia';
                      } else {
                        text = '';
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8,
                        child: Text(
                          text,
                          style: const TextStyle(color: text60, fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: text40, fontSize: 10),
                        textAlign: TextAlign.left,
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  bottom: BorderSide(color: text40, width: 1),
                  left: BorderSide(color: text40, width: 1),
                ),
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: almoxarifadoRealTotal.toDouble(),
                      color: brandBlue,
                      width: 20,
                      borderRadius: BorderRadius.zero,
                    ),
                    BarChartRodData(
                      toY: almoxarifadoPrevistoTotal.toDouble(),
                      color: brandBlue.withAlpha(128),
                      width: 20,
                      borderRadius: BorderRadius.zero,
                    ),
                  ],
                  showingTooltipIndicators: [],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: farmaciaRealTotal.toDouble(),
                      color: successGreen,
                      width: 20,
                      borderRadius: BorderRadius.zero,
                    ),
                    BarChartRodData(
                      toY: farmaciaPrevistoTotal.toDouble(),
                      color: successGreen.withAlpha(128),
                      width: 20,
                      borderRadius: BorderRadius.zero,
                    ),
                  ],
                  showingTooltipIndicators: [],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.center,
      children: [
        _legendItem('Real', brandBlue),
        _legendItem('Previsto', brandBlue.withAlpha(128)),
        _legendItem('Real', successGreen),
        _legendItem('Previsto', successGreen.withAlpha(128)),
      ],
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: text60, fontSize: 12)),
      ],
    );
  }
}
