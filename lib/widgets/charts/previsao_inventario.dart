import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class PrevisaoInventarioChart extends StatelessWidget {
  final List<FlSpot> spots;

  const PrevisaoInventarioChart({super.key, required this.spots});

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return Center(
        child: Text("Não foi possível gerar os pontos do gráfico."),
      );
    }

    final double minY = spots.map((spot) => spot.y).reduce(min);
    final double maxY = spots.map((spot) => spot.y).reduce(max);

    List<Color> gradientColors = [];
    List<double> gradientStops = [];

    if (minY < 0) {
      final zeroStop = (0 - minY) / (maxY - minY);
      gradientColors = [Colors.red, Colors.red, Colors.blue, Colors.blue];
      gradientStops = [0.0, zeroStop, zeroStop, 1.0];
    } else {
      gradientColors = [Colors.blue, Colors.blue];
      gradientStops = [0.0, 1.0];
    }

    return LineChart(
      LineChartData(
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: Colors.red.withAlpha(128),
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            gradient: LinearGradient(
              colors: gradientColors,
              stops: gradientStops,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],

        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = DateTime.fromMillisecondsSinceEpoch(
                  spot.x.toInt(),
                );
                return LineTooltipItem(
                  '${DateFormat('dd/MM/yy').format(date)}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Estoque Previsto: ${spot.y.toStringAsFixed(0)}",
                      style: TextStyle(
                        color: spot.y < 0 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {

                final style = TextStyle(color: Colors.grey[700], fontSize: 10);

                if (value == 0) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text('0', style: style),
                  );
                }

                if (value == meta.max || value == meta.min) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(meta.formattedValue, style: style),
                  );
                }

                final double range = meta.max - meta.min;
                if (range == 0) return Container();

                final double topPadding = range * 0.15;
                final double bottomPadding = range * 0.15;

                if (value < meta.max && value > meta.max - topPadding) {
                  return Container();
                }

                if (value > meta.min && value < meta.min + bottomPadding) {
                  return Container();
                }

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(meta.formattedValue, style: style),
                );
              },
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1000 * 60 * 60 * 24,

              getTitlesWidget: (value, meta) {
                final style = TextStyle(fontSize: 10, color: Colors.grey[700]);
                final DateTime currentDate =
                    DateTime.fromMillisecondsSinceEpoch(value.toInt());

                Widget buildText(DateTime date) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(DateFormat('dd/MM').format(date), style: style),
                  );
                }

                if (value == meta.min) {
                  return buildText(currentDate);
                }

                if (value == meta.max) {
                  return buildText(currentDate);
                }
                final DateTime minDate = DateTime.fromMillisecondsSinceEpoch(
                  meta.min.toInt(),
                );
                final DateTime maxDate = DateTime.fromMillisecondsSinceEpoch(
                  meta.max.toInt(),
                );

                final int quietZoneDays = 3;

                if (currentDate.difference(minDate).inDays <= quietZoneDays) {
                  return Container();
                }

                if (maxDate.difference(currentDate).inDays < quietZoneDays) {
                  return Container();
                }

                final int daysSinceStart = currentDate
                    .difference(minDate)
                    .inDays;
                if (daysSinceStart % 7 == 0) {
                  return buildText(currentDate);
                }

                return Container();
              },
            ),
          ),

          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
